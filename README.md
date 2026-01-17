# 🚀 Awesome-NAS-Guide: NAS入门指南

## 🎯 功能实现清单 (What You Will Build)

> 💡 **图例说明**：✅ 已完成文档 | 🚧 编写/折腾中 | ⏳ 计划中

跟随本教程，你将不仅拥有一个存储设备，更将获得一个**全能的家庭数据中心**。我们将逐一解锁以下成就：

### 🍎 1. 核心资产保护 (Backup & Recovery)

* ✅ **省下 iCloud 订阅费**：部署 Immich/MT Photos，实现全家 iPhone/Android 照片自动备份，支持 Live Photo 与 AI 智能搜图。
* ✅ **Mac 无感保护**：基于 Samba/AFP 协议优化，体验像原厂一样丝滑的 Time Machine (时间机器) 无线备份。
* 🚧 **多端文件同步**：部署 Syncthing/Verysync，实现公司电脑、家里 NAS、手机三端文件实时同步，替代坚果云。
* ✅ **数据保险箱**：本地敏感数据加密后，利用 Rclone 自动同步到阿里云盘/115，构建 "3-2-1" 容灾体系。

### 🎬 2. 极致影音娱乐 (Home Media Center)

* ✅ **影音自由**：通过 qBittorrent + MoviePilot 实现自动追剧、自动下载、自动刮削海报，打造私人 Netflix。
* 🚧  **全格式播放**：部署 Jellyfin/Plex/Emby，利用核显硬件解码，在外网也能流畅观看 4K HDR 蓝光电影。
* 🚧  **私人 Spotify**：部署 Navidrome/Audiobookshelf，管理你的无损音乐和有声书库，支持手机端流媒体播放。
* 🚧  **电子书库**：部署 Calibre-Web，将 NAS 变成你的私人 Kindle 书库，支持推送到阅读器。

### 🌐 3. 网络与安全 (Network & Security)

* ✅ **打破内网限制**：解决无公网 IPv4 痛点，通过 IPv6 + DDNS 实现全球任意地点高速访问家庭网络。
* 🚧  **全屋去广告**：部署 AdGuard Home，从 DNS 层面拦截全屋设备的视频广告和追踪器，保护家人隐私。
* 🚧 **密码管家**：自建 Vaultwarden (Bitwarden)，将所有账号密码握在自己手里，告别 LastPass 收费。
* ⏳ **安全访问网关**：配置 Nginx Proxy Manager (NPM)，自动申请 SSL 证书，实现 HTTPS 访问，隐藏真实端口。

### 🏠 4. 智慧生活与自动化 (Smart Home)

* ✅ **智能家居中枢**：部署 Home Assistant，打破品牌壁垒，将小米/涂鸦设备接入 Apple HomeKit，用 Siri 控制全屋。
* 🚧 **自动化脚本**：编写自动化逻辑（如：硬盘温度过高 -> 小爱音箱报警 + 自动开启散热风扇）。
* 🚧 **家庭看板**：部署 Homepage/Dashy，为全家人提供一个漂亮的导航页，一键直达所有服务。

### 💻 5. 极客与生产力 (For Geeks)

* ⏳ **云端开发环境**：部署 Code-Server (VS Code 网页版)，在 iPad 上随时随地写代码。
* ⏳ **私人代码仓库**：部署 Gitea/GitLab，托管你的个人项目代码。
* 🚧 **轻量级笔记**：部署 Memos/SiYuan/Notion-Next，拥有完全属于自己的知识库。
* 🚧 **Docker 游乐场**：学会使用 Portainer 管理容器，尝试运行各种有趣的开源项目（如 Minecraft 服务器、幻兽帕鲁服务器）。
* 🚧 **本地 AI 模型**：(进阶) 部署 Ollama + OpenWebUI，利用闲置算力运行本地大语言模型，保护对话隐私。

---

## 📚 教程目录与实施路线图

### [第一章：地基篇 —— 硬件与系统](./docs/01-hardware-and-system.md)
>
> **🌟 实现功能**：建立完整的硬件认知体系，避开 SMR 硬盘坑，并选择最适合你的操作系统（fnOS/Unraid）。

* **[1.1 核心决策与硬件选购](./docs/01-hardware-and-system.md#11-核心决策我该选择哪条路-the-three-paths)**
  * **三大流派抉择**：成品 NAS (买软件送硬件) vs DIY (极致性价比) vs 企业级 (噪音劝退)。
  * **CPU 天梯榜**：为什么 **Intel N100** 是 2026 年的国民神 U？(兼顾 N5105/J4125 捡垃圾方案)。
  * **硬盘避坑指南**：坚决拒绝 SMR 叠瓦盘，家用首选红盘 Plus/酷狼，企业级推荐 HC550。
* **[1.2 系统架构与部署](./docs/01-hardware-and-system.md#15-2026年的系统格局四分天下-os-comparison)**
  * **四国争霸**：fnOS (飞牛)、群晖、Unraid 与 TrueNAS 的详细优劣对比与人群推荐。
  * **文件系统**：Ext4 vs Btrfs (快照防勒索) vs ZFS 的选择逻辑。
* **[1.3 存储策略](./docs/01-hardware-and-system.md#16-存储策略与-raid-科普-storage-strategy)**
  * **RAID 模式科普**：Basic、RAID 1 与 RAID 5 的区别，以及 Unraid 独特的校验机制。
  * **3-2-1 备份法则**：谨记“RAID 不是备份”，构建原件+双介质+异地灾备的体系。

### [第二章：网络篇 —— 穿透内网，连接世界](./docs/02-network.md)
>
> **🌟 实现功能**：告别无公网 IPv4 焦虑，掌握四种主流穿透方案，利用 IPv6/隧道技术实现全球高速访问。

* **[2.1 网络环境诊断与决策](./docs/02-network.md#21-网络环境诊断由于你根本没有公网-ipv4)**
  * **残酷现实**：如何自测是否处于“大内网” (NAT) 环境？
  * **四种方案对比**：IPv6 (极速直连) vs Tailscale (私密管理) vs Cloudflare Tunnel (网页建站) vs FRP (公网分享)。
* **[2.2 核心前置：光猫改桥接](./docs/02-network.md#22-核心前置光猫改桥接-bridge-mode)**
  * **性能释放**：为什么必须由路由器拨号？(避免双层 NAT，提升稳定性)。
  * **实战操作**：从联系装维师傅到硬核破解光猫超级密码的两种路径。
* **[2.3 IPv6 配置与防火墙](./docs/02-network.md#23-开启-ipv6通往自由的钥匙)**
  * **路由器设置**：Native/PPPoE 模式与 SLAAC 分配方式的通用配置标准。
  * **防火墙陷阱**：如何放行 IPv6 端口？(解决 99% 新手连不通的元凶)。
* **[2.4 DDNS 动态域名解析](./docs/02-network.md#24-给-nas-一个名字ddns-动态域名解析)**
  * **原生支持**：fnOS/群晖系统自带 DDNS 的快速配置。
  * **DDNS-Go (Docker)**：通吃所有域名商 (Cloudflare/阿里云/腾讯云) 的可视化管理神器。
* **[2.5 备用方案与进阶](./docs/02-network.md#27-备用方案cloudflare-tunnel-零配置安全免费)**
  * **Cloudflare Tunnel**：无需公网 IP、无需端口映射、自带 SSL 证书的零信任隧道搭建指南。
  * **FRP / Tailscale**：构建“IPv6 主力 + 隧道保底”的 Combo 组合拳，确保永不失联。

### [第三章：备份篇 —— 苹果生态与数据归档](./docs/03-backup.md)
>
> **🌟 实现功能**：彻底释放手机和电脑空间，数据多版本回溯，告别“存储焦虑”。

* **[3.1 MacBook Time Machine (时间机器)](./docs/03-backup.md#31-macbook-time-machine-时间机器--给电脑一颗后悔药)**
  * **SMB 协议优化**：开启 `vfs_fruit` 模块，让 NAS 完美兼容 macOS 元数据，提升读写速度。
  * **安全与配额**：创建专用账户隔离勒索病毒，设置存储配额防止备份文件占满硬盘。
* **[3.2 原生相册方案 (飞牛/群晖 + iOS 自动化)](./docs/03-backup.md#32-原生方案飞牛群晖相册--ios-快捷指令-真无感备份)**
  * **零门槛部署**：无需 Docker，开箱即用，适合不想维护容器的新手。
  * **真·无感备份**：利用 iOS 快捷指令 (Shortcuts)，实现“回家充电即自动备份”，彻底解决 iPhone 后台不运行的问题。
* **[3.3 手机照片管理 (Immich 实战)](./docs/03-backup.md#33-手机照片管理-immich-实战--谷歌相册的完美替代)**
  * **Docker 部署**：替代 Google Photos/iCloud 的终极自托管方案。
  * **硬件加速**：激活 Intel N100 核显 (OpenVINO)，实现 4K 视频转码与毫秒级 AI 识图。
  * **家庭隐私**：多用户隔离与共享相册策略，既能分享宝宝照片，又能保护个人隐私。

### 第四章：娱乐篇 —— 影音与下载
>
> **🌟 实现功能**：破除家庭宽带大内网，挂机下载 4K 蓝光电影，并建立精美的海报墙。

* **4.1 下载中心 (PT/BT)**
  * **qBittorrent 优化**：针对 IPv6 环境的连接数与端口设置，解决上传没速度的问题。
  * 自动化工具：MoviePilot / Nastool 的配置，实现“想看什么，点一下就自动下载”。
* **4.2 家庭影院 (Jellyfin/Plex)**
  * 媒体库权限管理：不让孩子看到不该看的电影。
  * 硬解转码：在外网流畅播放 4K 高码率视频。

### 第五章：生活篇 —— 智能家居中枢
>
> **🌟 实现功能**：打破品牌壁垒，用 Siri 控制小米设备，用自动化逻辑接管生活。

* **5.1 Home Assistant (HA) 部署**
  * Docker 还是虚拟机？选择最稳定的运行方式。
* **5.2 设备接入与桥接**
  * HomeKit Bridge：将非 HomeKit 设备（如米家、涂鸦）反向接入苹果“家庭”App。
* **5.3 实用自动化案例**
  * *案例*：NAS 硬盘温度过高 -> 小爱音箱语音播报 + 自动开启散热风扇。

### [第六章：安全篇 —— 容灾与加密](./docs/06-security.md)
>
> **🌟 实现功能**：构建符合工业标准的 **"3-2-1" 备份体系**，利用 Rclone + Alist 将 NAS 变成自动化的加密堡垒。

* **[6.1 核心防线：数据黑箱 (Rclone + Alist)](./docs/06-security.md#61-核心防线rclone-crypt-加密-数据黑箱)**
  * **协议网关 (Alist)**：部署 Alist 作为中间件，解决国内网盘 API 变动难题，统一将阿里云盘/115 转换为标准 WebDAV 协议。
  * **透明加密 (Crypt)**：利用 Rclone Crypt 模块在上传前对文件名和内容进行高强度 AES-256 加密，云厂商只能看到乱码，彻底杜绝隐私泄露。
* **[6.2 自动化备份实战](./docs/06-security.md#62-自动化编写-crontab-定时脚本)**
  * **生产级脚本**：内置 `rclone_autobackup.sh` 脚本，集成 **文件锁 (File Lock)** 防冲突机制与 **脏数据清洗** 逻辑。
  * **无人值守**：配合 Crontab 实现每日凌晨增量冷备份，利用 `--size-only` 参数大幅提升海量小文件的扫描效率。
* **[6.3 灾难恢复演练](./docs/06-security.md#63-灾难恢复演练-restore)**
  * **恢复测试**：模拟 NAS 物理损坏场景，从云端解密并拉取数据，验证备份的有效性（没有经过恢复测试的备份都是无效的）。

---

## 📬 反馈与交流 (Feedback & Contact)

> 💡 **独行快，众行远**。折腾 NAS 的乐趣不仅在于点亮服务，更在于分享与交流。

这篇文档还在持续更新中（🚧 Construction in Progress）。

如果你在搭建过程中遇到了**文档未覆盖的深坑**，或者有**更好的硬件/软件方案**想要分享，欢迎加入技术交流群！

如有意向，请扫描下方二维码添加我的微信：

div align="center">
  <table>
    <tr>
      <td align="center" width="220">
        <img src="./assets/wechat_qr.png" width="200" alt="个人微信">
        <br>
        <b>👨‍💻 个人微信</b><br>
        <span style="font-size: 12px;">(ID: mje)</span>
      </td>
      <td align="center" width="220">
        <img src="./assets/wechat_group.png" width="200" alt="NAS技术交流群">
        <br>
        <b>👥 NAS 技术交流群</b><br>
        <span style="font-size: 12px;">(群聊过期请加个人号)</span>
      </td>
    </tr>
  </table>
</div>

📝 **入群方式**：

1. 直接扫描右侧 **群二维码** 加入（如果二维码未过期）。
2. 如果群码失效，请扫描左侧添加 **个人微信**，备注 **"NAS"** 或 **"Github"**，我会手动拉你入群。

在这里我们可以讨论：

* 🛠️ 硬件选购避坑与各种“捡垃圾”心得
* 🚀 PT 站点交流与保种技巧
* 🧩 Docker 容器的进阶玩法
* 🐛 教程文档的勘误与改进建议
