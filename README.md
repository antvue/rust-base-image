# Rust Base Image

这是一个基于 Alpine Linux 的 Rust 基础镜像，预装了 `tokio-console` 工具。

## 镜像特性

- 基于 Alpine Linux，镜像体积小
- 预装 glibc 支持，兼容大多数 Rust 应用
- 内置 `tokio-console` 工具，用于 Tokio 应用的监控和调试
- 静态链接编译，确保在 Alpine 环境中的兼容性
- 中文时区设置（Asia/Shanghai）

## 构建方式

### 1. 使用构建脚本 (推荐)

```bash
# 基本构建
./build.sh

# 构建并启用 squash（需要 Docker 实验功能）
./build.sh -s

# 构建并推送到 Docker Hub
./build.sh -p

# 构建、squash 并推送，指定标签
./build.sh -s -p -t v1.0.0

# 自定义镜像名称和标签
./build.sh -i myuser/myimage -t v1.0.0

# 构建到本地仓库
./build.sh -i localhost:5000/myimage -t latest

# 查看帮助
./build.sh -h
```

### 2. 使用 Makefile

```bash
# 查看所有可用命令
make help

# 基本构建
make build

# 构建并启用 squash
make build-squash

# 构建并推送
make build-and-push

# 构建、squash 并推送
make build-squash-and-push

# 指定标签构建
make tag TAG=v1.0.0

# 自定义镜像名称和标签
make build IMAGE_NAME=myuser/myimage TAG=v1.0.0

# 测试镜像
make test

# 进入容器 shell
make shell

# 清理镜像
make clean
```

### 3. 直接使用 Docker 命令

```bash
# 基本构建
docker build -t antvue/rust-base-image:latest .

# 启用 squash 构建（需要实验功能）
docker build --squash -t antvue/rust-base-image:latest .

# 推送到 Docker Hub
docker push antvue/rust-base-image:latest
```

## 使用镜像

### 拉取镜像

```bash
docker pull antvue/rust-base-image:latest
```

### 运行容器

```bash
# 运行 shell
docker run --rm -it antvue/rust-base-image:latest sh

# 测试 tokio-console
docker run --rm antvue/rust-base-image:latest tokio-console --version
```

### 作为基础镜像

```dockerfile
FROM antvue/rust-base-image:latest

# 复制你的应用
COPY target/release/your-app /usr/local/bin/your-app

# 设置入口点
ENTRYPOINT ["/usr/local/bin/your-app"]
```

## Docker Squash 功能

Squash 功能可以将多层镜像压缩为单层，减少镜像大小。要使用此功能，需要启用 Docker 的实验功能：

### 启用 Docker 实验功能

1. 编辑 `/etc/docker/daemon.json`：
```json
{
  "experimental": true
}
```

2. 重启 Docker 服务：
```bash
sudo systemctl restart docker
```

3. 验证实验功能已启用：
```bash
docker version --format '{{.Server.Experimental}}'
```

## 环境变量

镜像预设了以下环境变量：

- `LANG="C.UTF-8"`
- `LANGUAGE="zh_CN.UTF-8"`
- `LC_ALL="en_US.UTF-8"`
- `RUST_LOG="info"`
- `TZ="Asia/Shanghai"`

## 预装工具

- `tokio-console`: Tokio 运行时监控工具
- `glibc`: GNU C 库支持
- 基本的 Alpine 工具链

## 开发工作流

```bash
# 开发流程：构建 + 测试
make dev

# 发布流程：构建（squash）+ 推送 + 测试  
make release

# 自定义标签发布
make tag-squash TAG=v1.2.3
make push TAG=v1.2.3
```

## 故障排除

### tokio-console 无法运行

如果遇到 "not found" 错误，确保：
1. 镜像是使用最新的 Dockerfile 构建的
2. 二进制文件使用了 musl 静态链接
3. 容器中存在 `/usr/local/bin/tokio-console` 文件

### Squash 功能不可用

确保：
1. Docker 实验功能已启用
2. Docker 版本支持 squash 功能
3. 使用 `--squash` 参数构建

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个镜像。

## 许可证

MIT License