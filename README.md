# ESXi Ubuntu AutoProvision Toolkit

本工具集面向 DevOps 和自动化部署场景，基于 Cloud-Init、govc、Packer 等组件，支持在 VMware ESXi 上批量安装 Ubuntu Server 虚拟机。

---

## 🧩 功能特性

- 自定义 Ubuntu Server ISO（支持 Cloud-Init）
- 自动填充 `user-data`, `meta-data`, `network-config`
- 自动探测网卡名、支持静态 IP / DHCP
- 支持导入现成 Cloud-Init YAML 模板
- govc 自动上传 ISO 并创建 VM（支持模板化参数）
- 批量生成多台 VM（支持多主机名/IP 配置 YAML）
- 支持选择 Ubuntu 官方版本（22.04 / 20.04 等）
- 使用 Packer 构建 ESXi VM 模板（可集成到 CI/CD）
- GitHub Actions CI：打包 + Artifact 发布

---

## 📁 默认目录结构

- `~/iso`：生成的 Ubuntu 安装 ISO 存放目录
- `~/templates`：Cloud-Init 模板目录（用于填充）

---

## 🔧 环境准备

支持系统：**macOS**, **Ubuntu Linux**

执行依赖安装：

```bash
bash scripts/install.sh
```

---

## 🧙 使用方法

### 1. 交互式创建自定义 ISO

```bash
bash scripts/generate_iso.sh
```

按提示输入：

- Ubuntu 版本
- 主机名 / 用户名
- 是否使用 DHCP（或输入静态 IP 等参数）
- SSH 公钥路径

自动生成的 ISO 存放在 `~/iso/<hostname>.iso`

---

### 2. 批量生成多台 VM ISO

准备 `examples/batch_config.yaml`：

```yaml
instances:
  - hostname: node1
    username: devops
    ip: 192.168.1.101
  - hostname: node2
    username: admin
    dhcp: true
```

执行批量处理：

```bash
bash scripts/generate_batch.sh examples/batch_config.yaml
```

---

### 3. 上传 ISO 并创建 VM（govc）

配置 govc 环境变量：

```bash
export GOVC_URL='https://user:pass@esxi-host/sdk'
export GOVC_DATASTORE='datastore1'
export GOVC_NETWORK='VM Network'
export GOVC_INSECURE=1
```

上传 ISO 并自动创建 VM：

```bash
bash scripts/create_vm.sh node1.iso
```

---

### 4. Packer 模板构建（可选）

编辑 `packer/ubuntu.json`，执行：

```bash
packer build packer/ubuntu.json
```

---

## ✅ CI/CD 支持（GitHub Actions）

支持自定义 Ubuntu ISO 打包后上传为 GitHub Release Artifact。

---

## 📄 模板变量说明

模板路径：`~/templates/`

- `user-data.template`：支持变量 `__USERNAME__`、`__PUBKEY__`
- `meta-data.template`：支持变量 `__HOSTNAME__`
- `netplan.template`：会根据 DHCP/静态模式动态替换

---

## 📦 官方 Ubuntu ISO 支持版本

- Ubuntu Server 22.04 LTS
- Ubuntu Server 20.04 LTS
- Ubuntu Server 24.04 LTS（可选）

---

## 🧪 示例目录

```bash
examples/
├── batch_config.yaml
scripts/
├── install.sh
├── generate_iso.sh
├── generate_batch.sh
├── create_vm.sh
```

---

## 🤝 欢迎贡献

- Issues / PR 均可
- 适用于内部 DevOps、自动化部署、测试集群预配置等场景