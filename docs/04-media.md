# 第四章：娱乐篇 —— 打造全能家庭媒体中心

> **摘要**：本章将把你的 NAS 进化为一个 24 小时工作的娱乐中枢。告别各种会员费，把数据掌握在自己手中。
>
> **🌟 本章目标**：
>
> 1. **🎬 影音自由**：通过 `qBittorrent` + `MoviePilot` 实现自动化追剧、下载、刮削，打造私人 Netflix。
> 2. **📺 全格式播放**：部署 `Jellyfin`，利用核显硬件解码，在外网也能流畅观看 4K HDR 蓝光电影。
> 3. **🎵 私人 Spotify**：部署 `Navidrome` 和 `Audiobookshelf`，管理无损音乐和有声书，支持手机端流媒体播放。
> 4. **📚 电子书库**：部署 `Calibre-Web`，将 NAS 变成你的私人 Kindle 书库，支持一键推送到阅读器。

---

## 4.1 影音基石：下载与自动化 (Video Freedom)

我们要实现的效果是：**你在手机上订阅一部电影，NAS 自动下载、自动改名、自动下载海报，然后通知你“可以看了”。**

### 4.1.1 黄金目录结构 (关键步骤) ⚠️

**这是自动化成功与否的基石**。为了让自动化软件能通过“硬链接 (Hardlink)”秒级整理文件且不占用双倍空间，目录结构必须规范。

1. **创建共享文件夹**：在 NAS 文件管理器中创建一个名为 `Media` 的顶级共享文件夹。
2. **建立子目录结构**：

    ```text
    /vol1/1000/Media
    ├── downloads          <-- [下载区] qBittorrent 只能读写这里
    │   ├── movies
    │   ├── tv
    │   └── anime
    └── librar            <-- [展示区] Jellyfin/Emby 读取这里
        ├── movies         <-- 自动整理后的电影 (硬链接)
        ├── tv             <-- 自动整理后的剧集 (硬链接)
        └── anime          <-- 自动整理后的动漫 (硬链接)
    ```

    > **💡 硬链接原理解析**：
    > 硬链接就像给同一个文件起了两个名字。
    > * 文件 A 在 `downloads` 文件夹（用于保种）。
    > * MoviePilot 在 `library` 文件夹创建了一个文件 B 指向同一个物理数据块。
    > * **删除 A，B 还在；删除 B，A 还在。** 只有 A 和 B 都删了，空间才释放。这让你既能保持 PT 做种，又能拥有完美的海报墙，且**不额外占用空间**。

### 4.1.2 下载中心：qBittorrent 优化版

**1. Docker 部署 (Host 模式)**
Host 模式能让 qB 直接获取 IPv6 地址，极大提升连接性。

```bash
docker run -d \
  --name=qbittorrent \
  --net=host \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Asia/Shanghai \
  -e WEBUI_PORT=8080 \
  -v /vol1/1000/DockerConfig/qbittorrent:/config \
  -v /vol1/1000/Media/downloads:/downloads \
  --restart=always \
  linuxserver/qbittorrent:latest
```

**2. 关键优化 (解决无速度问题) 🚀**
进入 WebUI (`http://NAS-IP:8080`，默认账号 `admin` / `adminadmin`) -> **Tools** -> **Options**：

* **Connection (连接)**：
  * **监听端口**：随机生成一个端口（例如 `54321`）。
  * **路由器转发**：**务必**登录主路由后台，在端口转发/虚拟服务器中，添加这个端口（协议选 TCP+UDP），指向你的 NAS IP。
* **BitTorrent (BT)**：
  * **隐私**：**必须取消勾选**“启用匿名模式 (Enable anonymous mode)”。（勾选会导致很多 PT 站无法识别你的客户端，导致红种）。
  * **队列**：勾选“不要计算慢速做种时间”，防止任务被挂起。
* **Advanced (高级)**：
  * **网络接口**：通常留空；如果遇到有 IPv6 地址但没速度，尝试指定绑定到 `eth0` 或 `bond0`。

### 4.1.3 自动化大脑：MoviePilot (MP)

MoviePilot 是自动化的核心，它负责指挥 qBittorrent 下载，并整理文件。

**1. 准备工作 (必做)**

* **注册 TMDB**：访问 [The Movie Database](https://www.themoviedb.org/)，注册账号 -> 设置 -> API -> 申请 API Key (选择 Developer)。
* **获取 PT 站 Cookie**：你需要至少一个 PT 站账号，或者使用 IYUU 账号作为认证站点。

**2. 部署 MoviePilot**
在 `/vol1/1000/DockerConfig/moviepilot` 下创建 `docker-compose.yml`：

```yaml
version: '3.3'
services:
  moviepilot:
    image: jxxghp/moviepilot:latest
    container_name: moviepilot
    restart: always
    # Host 模式能更好解决刮削网络问题，并直接连接 qB
    network_mode: host
    volumes:
      - /vol1/1000/DockerConfig/moviepilot/config:/config
      - /vol1/1000/DockerConfig/moviepilot/core:/moviepilot/.cache/ms-playwright
      # ⚠️ 注意：这里必须挂载 Media 根目录，只有这样才能实现硬链接
      - /vol1/1000/Media:/media
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - NG_PORT=3000          # WEB 访问端口
      - PORT=3001             # API 端口
      - PUID=0
      - PGID=0
      - UMASK=022
      - TMDB_API_KEY=YOUR_KEY # 【必填】你的 TMDB API Key
      - AUTH_SITE=iyuu        # 认证站点，推荐填 iyuu
      - IYUU_SIGN=YOUR_TOKEN  # IYUU 的 Token
```

### 3. 核心配置流程

1. **访问后台**：`http://NAS-IP:3000` (初始账号 `admin`，密码在 `docker logs moviepilot` 日志中查看)。
2. **下载器设置**：
    * 类型：`qBittorrent`
    * Host：`http://127.0.0.1:8080` (因为 MoviePilot 也是 Host 模式，直接填本机回环地址即可)
    * **下载路径**：`/media/downloads` (注意：这里要填容器内的路径)
3. **媒体库设置**：
    * 电影路径：`/media/library/movies`
    * 剧集路径：`/media/library/tv`
4. **目录整理 (关键)**：
    * 开启“自动整理”。
    * **整理方式**：务必选择 **硬链接 (Link)**。
    * 如果设置正确，你会发现下载完成后，`/media/library` 里瞬间出现了整理好的文件，而硬盘空间并没有减少。

---

## 4.2 家庭影院：Jellyfin (全格式播放)

海报墙有了，现在我们要解决“怎么看”的问题，特别是如何在外网流畅播放 4K 视频。

### 4.2.1 部署并开启核显硬解

我们使用 `nyanmisaka` 维护的特供版，对中文和驱动支持更好。

```bash
docker run -d \
  --name=jellyfin \
  --restart=always \
  --net=host \
  --device /dev/dri:/dev/dri \
  -v /vol1/1000/DockerConfig/jellyfin:/config \
  -v /vol1/1000/Media/library:/media \
  nyanmisaka/jellyfin:latest
```

> **💡 参数解析**：
>
> * `--device /dev/dri:/dev/dri`：这是直通 Intel 核显的关键参数。
> * **AMD 用户注意**：如果使用 AMD CPU，参数通常为 `--device /dev/dri/renderD128:/dev/dri/renderD128`。

### 4.2.2 硬件转码设置 (Transcoding)

进入 Jellyfin 控制台 -> **播放 (Playback)** -> **转码 (Transcoding)**：

1. **硬件加速**：
    * **Intel CPU** (N100, N5105, i3-8100 等)：选择 **Intel QuickSync (QSV)**。
    * **AMD CPU**：选择 **Video Acceleration API (VAAPI)**。
2. **启用解码**：
    * 把 H.264, HEVC, VC1, AV1, VP9 等所有选项全部勾选。
    * **启用硬件编码**：同样勾选。
3. **验证方法**：
    * 关闭手机 WiFi，使用 4G/5G 网络打开 Jellyfin App。
    * 播放一部 4K 高码率电影。
    * 在播放界面选择画质为 `1080P - 10Mbps`。
    * 回到电脑端 Jellyfin 控制台查看仪表盘。如果“转码”一栏显示有 `(QSV)` 或 `(VAAPI)` 字样，且 CPU 占用率低于 30%，说明硬解配置成功！

### 4.2.3 媒体库权限管理 (家长控制)

为了不让孩子看到不适合的内容（比如《权力的游戏》）：

1. **新建用户**：控制台 -> 用户 -> 新增用户（如 `Kids`）。
2. **设置密码**：给家长 `admin` 账号设置强密码，`Kids` 账号可设简单密码。
3. **目录访问控制**：
    * 点击 Kids 用户 -> **媒体库访问**。
    * **只勾选** `动漫` 或 `教育` 文件夹。
    * **取消勾选** `movies` 和 `tv` 文件夹。
4. **功能限制**：
    * **取消勾选** “允许删除媒体” (防止熊孩子误删文件)。
    * **取消勾选** “允许修改配置”。

---

## 4.3 私人 Spotify：音乐与有声书

NAS 不仅能存电影，更是绝佳的无损音乐服务器。

### 4.3.1 纯音乐服务：Navidrome

Navidrome 轻量、快速，兼容 Subsonic 协议，这意味着你可以使用几十种成熟的第三方 APP 连接它。

**Docker 部署命令：**

```bash
docker run -d \
   --name navidrome \
   --restart=always \
   -p 4533:4533 \
   -e ND_SCANSCHEDULE=1h \
   -e ND_LOGLEVEL=info \
   -e ND_MUSICFOLDER=/music \
   -v /vol1/1000/DockerConfig/navidrome:/data \
   -v /vol1/1000/Music:/music \
   deluan/navidrome:latest
```

* **推荐客户端**：
  * **iOS**: `Substreamer` (免费/好用), `Amperfy` (简约), `play:Sub` (老牌)。
  * **Android**: `Symfonium` (强烈推荐，界面极其精美，缓存机制完美)。
  * **Web**: 直接浏览器访问 `http://NAS-IP:4533`。

### 4.3.2 有声书神器：Audiobookshelf

这是目前体验最好的有声书和播客服务器，专门针对“听书”场景优化。

**Docker 部署命令：**

```bash
docker run -d \
  --name audiobookshelf \
  --restart=always \
  -p 13378:80 \
  -v /vol1/1000/DockerConfig/audiobookshelf/config:/config \
  -v /vol1/1000/DockerConfig/audiobookshelf/metadata:/metadata \
  -v /vol1/1000/Audiobooks:/audiobooks \
  ghcr.io/advplyr/audiobookshelf:latest
```

* **亮点功能**：
  * **m4b 章节支持**：完美识别单一文件中的章节信息。
  * **断点续听**：你在网页上听到第 5 章第 3 分钟，打开手机 App 自动接着听。
  * **播客下载**：可以直接订阅 RSS 播客源，自动下载到 NAS 保存。

---

## 4.4 随身图书馆：Calibre-Web (电子书库)

将你硬盘里成千上万本 epub/mobi/pdf 电子书管理起来，并一键推送到 Kindle。

### 4.4.1 准备工作 (重要！)

Calibre-Web 并不是一个电子书编辑器，它是一个**展示器**。它需要依赖一个现成的 Calibre 数据库文件 (`metadata.db`)。

1. 在电脑（Windows/Mac）上安装 **Calibre** 官方软件。
2. 添加几本书，确保生成了 `metadata.db` 文件。
3. 将电脑上的整个 Calibre 库文件夹（包含 `.db` 文件）上传到 NAS 的 `/vol1/1000/Books` 目录中。

### 4.4.2 部署 Calibre-Web

```bash
docker run -d \
  --name=calibre-web \
  --restart=always \
  -e PUID=0 \
  -e PGID=0 \
  -e TZ=Asia/Shanghai \
  -p 8083:8083 \
  -v /vol1/1000/DockerConfig/calibre-web:/config \
  -v /vol1/1000/Books:/books \
  linuxserver/calibre-web:latest
```

### 4.4.3 核心配置：一键推送到 Kindle

1. **初始化**：
    * 浏览器访问 `http://NAS-IP:8083` (默认账号 `admin` / `admin123`)。
    * 首次登录会让你选择数据库位置，输入 `/books` 即可。
2. **配置邮件服务器 (SMTP)**：
    * 进入 **管理权限** -> **编辑邮件服务器设置**。
    * 这里以 QQ 邮箱为例：
        * 主机名: `smtp.qq.com`
        * 端口: `465` (加密: SSL/TLS)
        * 用户名: 你的 QQ 号
        * 密码: QQ 邮箱的授权码 (不是 QQ 密码，需在 QQ 邮箱设置里开启 SMTP 获取)。

3. **配置用户 Kindle 邮箱**：
    * 点击右上角用户图标 -> 在 **Kindle E-Mail** 栏填入你的亚马逊接收邮箱 (例如 `xxx@kindle.cn`)。
4. **实战使用**：
    * 在网页书库中点开一本书。
    * 点击 **"发送到 Kindle"** 按钮。
    * 等待 1-2 分钟，你的 Kindle 就会自动下载这本书了（记得要把你刚才配置的发送邮箱加入亚马逊的信任列表）。

---

## ✅ 本章小结

经过这一章的配置，你的 NAS 已经彻底改变了你的娱乐方式：

* **观影**：MoviePilot + Jellyfin 让你拥有了私人的、无广告的、自动更新的 4K 影院。
* **听歌**：Navidrome 让你抛弃 Apple Music/Spotify，随时随地享受无损私有库。
* **阅读**：Audiobookshelf 和 Calibre-Web 承包了你的通勤和睡前时光。

你的数据中心已经初具规模，接下来，我们要利用 NAS 强大的性能，为你的生活和工作效率赋能。

👉 **下一章：[第五章 应用篇 —— 搭建 HomeLab 智能家居与效率工具](05-homelab.md)**
