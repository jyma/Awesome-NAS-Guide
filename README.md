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

### 第三章：备份篇 —— 苹果生态与数据归档
>
> **🌟 实现功能**：彻底释放手机和电脑空间，数据多版本回溯，告别“存储焦虑”。

* **3.1 MacBook Time Machine (时间机器)**
  * Samba 协议优化：开启 `vfs_fruit` 模块提升 Mac 读写速度。
  * 配额管理：防止备份文件无限制通过，挤占电影空间。
* **3.2 手机照片管理 (Immich 实战)**
  * Docker 部署 Immich：替代 Google Photos/iCloud。
  * 硬件加速：开启核显转码与 AI 识图功能。
  * **多用户策略**：实现全家人的照片既能备份，又互不偷看。

### 第四章：娱乐篇 —— 影音与下载
>
> **🌟 实现功能**：利用移动宽带的大内网优势，挂机下载 4K 蓝光电影，并建立精美的海报墙。

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

### 第六章：安全篇 —— 容灾与加密
>
> **🌟 实现功能**：构建“3-2-1”备份体系，即使家里发生火灾/被盗，数据依然在云端安然无恙。

* **6.1 本地敏感数据加密**
  * 利用 Rclone 自带的 Crypt 功能对文件夹进行混淆加密。
* **6.2 网盘冷备份实战**
  * **Rclone 配置**：挂载阿里云盘/115/OneDrive。
  * **定时脚本**：编写 Crontab，每晚凌晨 3 点自动将加密数据增量上传至网盘。

---
