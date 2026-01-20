# 🚀 qBittorrent 无公网 IP 直连指南

## 📖 简介

如果你使用的是**移动/铁通/长城宽带**，或者身处**大内网**环境（只有内网 IPv4），在挂 PT 或 BT 下载时，通常会遇到以下痛点：

* **红灯/黄灯**：qBittorrent 底部图标显示连接状态不佳。
* **无法连接**：PT 站显示“可连接：否 (No)”。
* **没上传速度**：因为外网用户无法主动连接你，你只能连接别人，导致抢上传极其困难。

本项目提供了一套**“开箱即用”**的解决方案：

1. **核心工具**：基于 `natmap` 进行 UDP 打洞，利用运营商 NAT 特性获取临时的公网端口。
2. **智能脚本**：`update.sh` 会自动识别你的 NAS 是普通电脑 (x86_64) 还是 ARM 设备 (aarch64)，并自动修改 qBittorrent 端口、配置防火墙、向 Tracker 强制汇报。
3. **零维护**：配置一次，永久自动运行。即使端口变化，脚本也会在毫秒级内完成切换，几乎无感。

---

## 📂 文件结构说明

[本目录 (scripts/natmap/)](../scripts)已经内置了所有需要的文件：

```text
/natmap/
├── x86_64/
│   └── natmap          <-- 内置的 Intel/AMD 机型二进制文件
├── aarch64/
│   └── natmap          <-- 内置的 树莓派/ARM 机型二进制文件
└── update.sh           <-- 核心智能脚本 (无需选择架构，自动识别)
```

## 🛠️ 部署步骤

### 第一步：上传文件到 NAS

为了方便配置，我们建议将文件统一放在 NAS 的根目录 `/natmap` 下。

1. **下载**：将本仓库中的 [(scripts/natmap/)](../scripts) 文件夹下载到NAS 的根目录 `/` 下
2. **检查路径**：
    确保下传后的路径结构如下（本教程以此路径为示例）：
    * `/natmap/update.sh`
    * `/natmap/x86_64/natmap`
    * `/natmap/aarch64/natmap`

### 第二步：修改账号配置

我们需要修改脚本，填入你的 qBittorrent 账号密码，以便脚本能控制 qB 改端口。

1. **SSH 连接到 NAS** (切换到 root 用户: `sudo -i`)。
2. **编辑脚本**：

    ```bash
    vi /natmap/update.sh
    ```

3. **修改顶部的配置区域**：
    按 `i` 进入编辑模式，修改以下内容为你自己的信息：

    ```bash
    # =======================================================
    # 1. 用户配置区域 (请根据实际情况修改)
    # =======================================================
    
    # ... (其他参数保持默认即可)

    # qBittorrent 配置
    QB_HOST="192.168.5.18"   # 你的 qB 访问 IP (如果是本机推荐填 127.0.0.1)
    QB_PORT="8085"           # 你的 qB WebUI 端口
    QB_USER="admin"          # qB 用户名
    QB_PASS="admin"       # qB 密码
    ```

4. **保存退出**：按 `Esc` 键，输入 `:wq` 并回车。

### 第三步：赋予执行权限

执行以下命令，让脚本拥有运行权限：

```bash
chmod +x /natmap/update.sh
```

---

## 🚀 第三步：设置开机自启 (Systemd)

为了让它开机自动在后台运行，并防止掉线，我们需要创建一个系统服务。

1. **创建服务文件**：

    ```bash
    vi /etc/systemd/system/natmap.service
    ```

2. **写入以下内容** (直接复制粘贴)：

    ```ini
    [Unit]
    Description=NATMap Autostart Service
    After=network-online.target
    Wants=network-online.target

    [Service]
    # 工作目录 (必须指向你上传的文件夹)
    WorkingDirectory=/natmap

    # 启动命令 (直接运行智能脚本，它会自动选择正确的 natmap 版本启动)
    ExecStart=/natmap/update.sh

    # 崩溃重启策略 (防止意外退出)
    Restart=always
    RestartSec=5
    User=root

    [Install]
    WantedBy=multi-user.target
    ```

3. **启动服务**：
    依次执行以下命令：

    ```bash
    # 1. 重载服务配置
    systemctl daemon-reload
    # 2. 设置开机自启
    systemctl enable natmap
    # 3. 立即启动
    systemctl start natmap
    ```

---

## ✅ 验证是否成功

### 1. 查看运行状态

输入以下命令：

```bash
systemctl status natmap
```

* **成功标志**：看到绿色的 `Active: active (running)`。
* **架构确认**：日志中会显示 `系统架构: x86_64` (或 aarch64)，说明脚本已正确识别你的设备。

### 2. 查看 qBittorrent 状态

* **图标变化**：打开 qBittorrent 网页版，底部的连接图标应变为 **绿色插头 (Online)**。
* **端口变化**：去 `工具 -> 选项 -> 连接` 查看监听端口，它应该已经被修改为一个随机的高位端口（如 4xxxx）。

### 3. 查看实时日志 (可选)

如果你想看着它工作，可以输入：

```bash
journalctl -u natmap -f
```

如果看到 `NATMap 回调触发: 新公网端口 xxxxx` 和 `完成！所有设置已生效`，恭喜你，你的 NAS 已经成功直连公网！

---

## ❓ 常见问题 (FAQ)

**Q: 我需要手动下载 natmap 二进制文件吗？**
A: **不需要**。本目录已经内置了编译好的 `x86_64` 和 `aarch64` 静态版本，脚本会自动调用，如果您的CPU不在此类，则需要根据 CPU 架构进行下载。

**Q: 端口经常变正常吗？**
A: **正常**。这是运营商 NAT 的特性。我们的脚本设置了 10 秒心跳保活，能最大程度维持端口。即使端口变了，脚本也会在 1 秒内自动通知 qB 切换，对 PT 挂机几乎无影响。

**Q: 为什么日志提示“未找到二进制程序”？**
A: 请检查你是否把文件夹放到了 `/natmap`。如果你的路径不是这个，请修改 `/etc/systemd/system/natmap.service` 中的 `WorkingDirectory` 路径。
