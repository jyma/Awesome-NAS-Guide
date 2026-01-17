# 第四章：娱乐篇 —— 打造 4K 家庭影音中心 (Netflix 自建指南)

> **摘要**：本章将把你的 NAS 打造成一个自动化的影音工厂。
>
> **你将获得**：
>
> 1. **自动追剧**：想看什么在手机上点个“订阅”，NAS 自动下载、整理、刮削海报。
> 2. **极速下载**：通过 IPv6 和优化设置，跑满千兆宽带。
> 3. **全平台播放**：在电视、手机、iPad 上流畅播放 4K HDR 蓝光原盘。
> 4. **海报墙**：比爱奇艺更精美的私人影视库界面。

---

## 4.1 准备工作：文件目录与网络基石

在安装软件之前，规划好文件目录结构至关重要。混乱的目录会导致自动化软件无法识别，甚至无法实现“硬链接”（Hardlink）。

### 4.1.1 黄金目录结构 (TRaSH Guides 标准)

为了支持原子搬运（Atomic Moves）和硬链接（即下载一份文件，整理后不占用双倍空间），建议采用如下结构：

1. **创建共享文件夹**：在 NAS 文件管理器中创建一个名为 `Media` 的顶级共享文件夹。
2. **建立子目录**：

    ```text
    /vol1/1000/Media
    ├── downloads          <-- PT/BT 下载软件的保存路径
    │   ├── movies         <-- 下载的电影
    │   ├── tv             <-- 下载的剧集
    │   └── anime          <-- 下载的动漫
    └── library            <-- 最终展示给 Jellyfin/Plex 的媒体库
        ├── movies         <-- 自动整理后的电影 (硬链接)
        ├── tv             <-- 自动整理后的剧集 (硬链接)
        └── anime          <-- 自动整理后的动漫 (硬链接)
    ```

    > **⚠️ 原理解析**：下载器把文件下载到 `downloads`，自动化软件通过“硬链接”把文件“指”到 `library`。**物理上文件只存在一份**，但你在两个文件夹里都能看到它。删除其中一个，文件依然存在；只有两个都删了，空间才释放。

### 4.1.2 搞定 IPv6 公网访问 (内网穿透的终结者)

国内家庭宽带几乎没有公网 IPv4，但 IPv6 覆盖率极高。这是玩转 PT 和外网播放的基础。

1. **光猫/路由器设置**：
    * 登录主路由后台，找到 IPv6 设置。
    * 模式选择：**Native (原生)** 或 **Passthrough (穿透)**。
    * 防火墙：**暂时关闭 IPv6 防火墙**，或者设置允许入站连接（这一点非常关键，否则外网连不进来）。
2. **部署 DDNS-Go (动态域名解析)**：
    IPv6 地址很长且会变，我们需要一个域名来锁定它。

    ```bash
    # 使用 Host 模式，让容器直接获取 IPv6 地址
    docker run -d \
      --name ddns-go \
      --restart=always \
      --net=host \
      -v /opt/ddns-go:/root \
      jeessy/ddns-go
    ```

3. **配置 DDNS**：
    * 访问 `http://NAS-IP:9876`。
    * 选择 DNS 服务商 (阿里云/腾讯云/Cloudflare)，填入 API Key。
    * **IPv4**：取消勾选“是否启用”。
    * **IPv6**：勾选“是否启用”，在“通过接口获取”中选择你的网卡 (通常是 eth0)。
    * 保存，看到“解析成功”即完成。

---

## 4.2 下载中心：qBittorrent (满速优化版)

### 4.2.1 Docker 部署

推荐使用 `linuxserver` 镜像，极其稳定。

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

* **WebUI 地址**：`http://NAS-IP:8080`
* **初始账号**：`admin`
* **初始密码**：查看日志获取 (`docker logs qbittorrent`) 或默认为 `adminadmin`。

### 4.2.2 核心优化设置 (解决下载慢/无速度) 🚀

进入 qBittorrent -> **Tools (工具)** -> **Options (选项)**：

1. **Connection (连接)**：
    * **监听端口**：随机生成一个端口（例如 `56789`）。
    * **路由器转发**：务必在路由器防火墙/端口转发设置中，放行这个端口（TCP+UDP）。
    * **连接限制**：
        * 全局最大连接数：`2000` (大宽带大胆设)
        * 每个种子最大连接数：`200`
2. **BitTorrent (BT 协议)**：
    * **隐私**：**必须取消勾选**“启用匿名模式 (Enable anonymous mode)”。这个选项会导致很多 PT 站红种。
    * **队列**：勾选“不要计算慢速做种的时间”，防止任务被卡住。
3. **Advanced (高级)**：
    * **磁盘缓存 (Disk Cache)**：设置为 `-1` (自动) 或根据内存大小设置 (如 `1024 MiB`)。这能保护硬盘，防止频繁读写。
    * **验证 HTTPS Tracker 证书**：**取消勾选** (防止证书错误导致无法连接 Tracker)。
    * **网络接口**：如果没速度，尝试绑定到 `eth0` 或对应的 IPv6 接口。
4. **Tracker 添加 (仅限下载磁力链接)**：
    如果你主要下载 BT（非 PT），请去 GitHub 搜索 `trackerslist`，把最新的 Tracker 列表粘贴到设置里，能显著增加连接用户数。

---

## 4.3 自动化大脑：MoviePilot (MP)

告别“找资源-下载-改名-刮削”的手工时代。MoviePilot 是集大成者，实现了“订阅即播放”。

### 4.3.1 准备工作 (必做)

1. **TMDB API Key**：注册 [The Movie Database](https://www.themoviedb.org/)，在设置里申请 API Key。
2. **认证站点**：你需要至少一个 PT 站账号，或者使用“IYUU”作为认证站点。
3. **CookieCloud**：在 Chrome/Edge 浏览器安装插件，同步站点 Cookie 到云端。

### 4.3.2 部署 (Docker Compose)

在 `/vol1/1000/DockerConfig/moviepilot` 目录下新建 `docker-compose.yml`：

```yaml
version: '3.3'
services:
  moviepilot:
    image: jxxghp/moviepilot:latest
    container_name: moviepilot
    restart: always
    # Host 模式能更好解决刮削网络问题
    network_mode: host
    volumes:
      - /vol1/1000/DockerConfig/moviepilot/config:/config
      - /vol1/1000/DockerConfig/moviepilot/core:/moviepilot/.cache/ms-playwright
      # ⚠️ 注意：这里直接挂载 Media 根目录，为了实现硬链接
      - /vol1/1000/Media:/media
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - NG_PORT=3000      # WEB 访问端口
      - PORT=3001         # API 端口
      - PUID=0
      - PGID=0
      - UMASK=022
      - PROXY_HOST=       # 如果有软路由代理地址，填这就行，比如 [http://192.168.1.5:7890](http://192.168.1.5:7890)
      - TMDB_API_KEY=     # 填入你的 TMDB API Key
      - AUTH_SITE=iyuu    # 认证站点
      - IYUU_SIGN=        # IYUU Token
```

### 4.3.3 关键配置流程

1. **设置下载器**：
    * 类型选择 `qBittorrent`。
    * 地址：`http://127.0.0.1:8080` (因为是 Host 模式)。
    * **下载路径**：`/media/downloads` (对应容器内的路径)。
2. **设置媒体库**：
    * 电影路径：`/media/library/movies`
    * 剧集路径：`/media/library/tv`
3. **目录同步**：
    * 开启“自动整理”。设置源目录为 `/media/downloads`，目标目录为 `/media/library`。
    * **传输方式**：务必选择 **硬链接 (Hardlink)**。

---

## 4.4 终极呈现：Jellyfin 影音服务器

### 4.4.1 Docker 部署 (开启核显硬解)

推荐使用 `nyanmisaka` 维护的版本，对 Intel 核显驱动支持极佳。

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

> **💡 参数解析**：`--device /dev/dri:/dev/dri` 是直通 CPU 核显的关键，没有这行，播放 4K 会卡成 PPT。

### 4.4.2 开启硬件转码 (Transcoding)

进入 Jellyfin 控制台 -> **播放 (Playback)** -> **转码 (Transcoding)**：

1. **硬件加速**：选择 **Intel QuickSync (QSV)** (如果你是 AMD CPU 选 VAAPI)。
2. **启用解码**：把 H.264, HEVC, VC1, AV1, VP9 全部勾选。
3. **启用硬件编码**：同样勾选。
4. **保存**。

### 4.4.3 刮削器设置 (让海报墙更美)

进入控制台 -> **媒体库** -> 添加媒体库：

* **内容类型**：电影/节目。
* **文件夹**：选择 `/media/movies` 等。
* **元数据下载器**：勾选 TheMovieDb。
* **图片下载器**：勾选 TheMovieDb。
* **保存**。Jellyfin 会自动识别 MP 整理好的标准文件名，下载精美海报。

---

## 4.5 最佳观看姿势：客户端推荐 📺

有了服务端，还需要好的客户端才能解码 4K HDR/杜比视界。**不要用 Jellyfin 官方客户端**，体验一般。

| 平台               | 推荐 APP                  | 说明                                   | 是否收费        |
| :----------------- | :------------------------ | :------------------------------------- | :-------------- |
| **iOS / Apple TV** | **Infuse**                | 宇宙最强播放器，画质无敌，支持杜比视界 | 订阅制 (贵但值) |
| **iOS / Apple TV** | **VidHub**                | Infuse 的平替，功能类似，刮削速度快    | 免费/一次性买断 |
| **Android TV**     | **Jellyfin (官方)**       | 电视端官方版尚可，需配合 Exoplayer     | 免费            |
| **Android 手机**   | **Findroid**              | 第三方开源客户端，界面原生，解码强     | 免费            |
| **Windows/Mac**    | **Jellyfin Media Player** | 专门开发的桌面端，支持直通模式         | 免费            |

---

## ✅ 本章小结

恭喜！你现在拥有了一套媲美 Netflix 的私人流媒体系统：

1. **MoviePilot** 负责从 PT 站抓取资源并整理。
2. **qBittorrent** 负责在后台默默下载。
3. **Jellyfin** 负责管理海报墙和转码。
4. 你只需要躺在沙发上，打开 **Infuse**，享受 4K 电影带来的视觉盛宴。

👉 **下一章：[应用篇 —— 搭建 HomeLab 智能家居与效率工具](05-homelab.md)**
