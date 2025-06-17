[English](README.md) | [中文](README_zh.md)

<h1>中国科学院大学生物信息学教学 Docker 环境 (ucasbioinfo)<h1>

[![GitHub license](https://img.shields.io/github/license/QTuLab/docker-ucasbioinfo)](https://github.com/QTuLab/docker-ucasbioinfo/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/qtulab/ucasbioinfo)](https://hub.docker.com/r/qtulab/ucasbioinfo)

[TOC]

该项目为中国科学院大学生物信息学教学设计，提供一个跨平台的 Docker 镜像，旨在为学生提供统一、稳定、开箱即用的 Linux 生物信息学分析环境。

## ✨ 主要特性

- **跨平台支持**: 同时支持 `amd64`​ (Intel/AMD) 和 `arm64`​ (Apple Silicon M-series) 架构。
- **最新基础环境**: 基于 Ubuntu 24.04 LTS，确保了长期的稳定性和安全性，包含了 `git`​, `tmux`​, `vim`​ 等常用命令行工具。
- **非 Root 用户**: 默认使用非 root 用户 (`ubuntu`​) 操作，符合安全最佳实践。也可以通过 `sudo`​ 执行必要的管理任务。
- **预置 Conda 环境**: 内置 miniforge，并预装了两个关键的 Conda 环境：

  - ​**​`ucasbioinfo`​**​: 通用生信分析环境，集成了从测序数据预处理到单细胞分析的核心工具，如 `FastQC`​, `STAR`​, `Bowtie2`​, `Samtools`​, `BEDTools`​, `Subread`​, `Scanpy`​ 等。
  - ​**​`scenicplus`​**​: 专用于运行 [SCENIC+](https://github.com/aertslab/scenicplus) 的分析环境。
- **集成 Jupyter**: 包括 `Python 3.11`​, `JupyterLab`​, `Pandas`​, `Matplotlib`​, `Seaborn`​ 等。所有 Conda 环境均已注册为 Jupyter 内核，方便在网页界面中无缝切换。

> **关于 R 环境**：考虑到 R 语言及其生态（如 Bioconductor）在各操作系统上均有成熟的本地安装方案，且用户通常有高度自定义的需求，本镜像未包含 R 环境，以保持其轻量化和通用性。

## 🚀 快速开始

### 第 1 步: 安装容器引擎

- **Windows / macOS**: 下载并安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)。
- **Linux**: 根据你的发行版安装 [Docker Engine](https://docs.docker.com/engine/install/)。（服务器部署请参考下文的安全提示）

### 第 2 步: 拉取 Docker 镜像

在终端（Windows 用户可使用 PowerShell 或 Windows Terminal）中运行以下命令，系统会自动下载对应的`amd64`​ (Intel/AMD) 或 `arm64`​ (Apple Silicon M-series) 架构。也可以直接下载镜像包（[ucasbioinfo_amd64.tar.gz](https://tulab.genetics.ac.cn/~qtu/ucasbioinfo/ucasbioinfo_amd64.tar.gz) 或 [ucasbioinfo_arm64.tar.gz](https://tulab.genetics.ac.cn/~qtu/ucasbioinfo/ucasbioinfo_arm64.tar.gz)）然后加载。

```
# 方式一：从 Docker Hub 官方仓库拉取
docker pull qtulab/ucasbioinfo:latest

# 方式二：使用国内镜像加速（或者其他更快的镜像）
docker pull docker.xuanyuan.me/qtulab/ucasbioinfo:latest

# 方式三：如果网络不佳，还可以通过 `docker load` 命令加载离线镜像包。
docker load -i ucasbioinfo_amd64.tar.gz

```

### 第 3 步: 启动并进入容器

在你存放课程项目文件的本地目录中打开终端，运行以下命令。

```
# 对于 macOS / Linux 用户
docker run -it --rm -p 8888:8888 -v "$(pwd)":/home/ubuntu/project qtulab/ucasbioinfo:latest

# 对于 Windows (PowerShell) 用户
docker run -it --rm -p 8888:8888 -v "${PWD}:/home/ubuntu/project" qtulab/ucasbioinfo:latest

```

**参数解释:**

|**参数**|**说明**|
| -------| -------|
|​`-it`​|启动一个交互式会话，允许你与容器的终端进行交互。|
|​`--rm`​|容器停止后自动删除，避免产生无用的容器。由于数据已通过`-v`​参数保存在本地，此选项是安全的。|
|​`-p 8888:8888`​|将容器的 8888 端口映射到本地计算机的 8888 端口，用于访问 Jupyter Lab。|
|​`-v "..."`​| **(重要)** 挂载卷，将本地当前目录 (`$(pwd)`​或`${PWD}`​) 映射到容器内的`/home/ubuntu/project`​目录。|
|​`--shm-size=16g`​|设置共享内存大小。某些工具需要较大的共享内存，建议根据需要设置。|

成功运行后，命令行提示符会变为 `(ucasbioinfo) ubuntu@...:/home/ubuntu/project$`​，表明你已进入容器，并默认激活了 `ucasbioinfo`​ 环境。

## 🔬 容器使用指南

### 文件系统

**注意：所有工作都必须在**  **​`/home/ubuntu/project`​**​ **目录或其子目录中进行。**

该目录通过 `-v`​ 参数直接映射到你的本地文件系统，是唯一能够实现数据持久化的区域。保存在容器内其他位置的文件，将在容器关闭后永久丢失。

### Conda 环境管理

- **查看环境:**  `conda env list`​
- **切换环境:**  `conda activate scenicplus`​ 或 `conda activate ucasbioinfo`​

> 容器预置了 `mamba`​ 作为 `conda`​ 的高速替代品，安装类的 `conda`​ 命令可替换为 `mamba`​ 以获得更好的性能。

### Jupyter Lab 的使用

1. **启动 Jupyter Lab:**  在容器终端中，直接运行 `tool-runjupyter.sh`​ 脚本。
2. **访问 Jupyter Lab:**  在你本地计算机的浏览器中访问 `http://localhost:8888`​。
3. **选择内核 (Kernel):**  在 Jupyter Lab 中创建或打开 Notebook 时，你可以在右上角的内核选择器中轻松切换 `ucasbioinfo`​ 和 `scenicplus`​ 环境。

### 命令行工具

激活所需环境后，可以直接调用该环境中的命令行工具。

```
# 示例：使用 FastQC 进行质控
# 确保在 ucasbioinfo 环境下
cd ~/project
mkdir -p fastqc_results
fastqc your_reads.fastq.gz -o fastqc_results/

```

分析完成后，`fastqc_results`​ 文件夹会出现在本地计算机的项目目录中。

## 📖 Notebook 使用指南

### SCENIC+ 教程：从双组学数据到增强子调控网络

本项目提供了一个完整的 **SCENIC+ 分析流程** Notebook，引导你从独立的 scRNA-seq 和 scATAC-seq 数据出发，构建并推断出增强子驱动的基因调控网络 (eGRN)。

**核心特性**：该教程最大的特点是为不同需求的用户设计了三条灵活的分析路径，无论你的计算资源如何，都能找到适合你的学习起点：

- 路径一：快速可视化 (仅需 2-5 分钟)  
  跳过所有计算，直接加载我们提供的结果，学习如何解读和可视化 eGRN。适合希望快速了解项目产出的用户。
- 路径二：双组学分析 (PC友好, 30-60 分钟)  
  在普通个人电脑上，即可完成 scRNA-seq 和 scATAC-seq 数据的质控、降维等初步分析。适合初学者或希望练习标准双组学流程的用户。
- 路径三：完整 eGRN 推断 (需要服务器, 5-10 小时)  
  利用高性能计算资源，走完整个流程，完成计算密集的核心 eGRN 推断。

此外，教程采用**模块化设计**并内置了 **“断点续跑”机制**，让复杂的分析流程变得清晰、可控，即使中途中断也能从断点处继续，极大地提升了学习和探索的效率。

详细操作步骤，请查看项目中的 **[SCENIC+ Jupyter Notebook](tutorial/scenicplus.ipynb)**。

## 💡 高级用法与安全提示

### 在服务器上使用 Podman (更安全)

在多用户服务器上，使用 Docker 通常需要将用户加入 `docker`​ 组，这存在一定的安全风险。

**Podman** 是一个更安全的选择，它无需守护进程，可以在非 root 模式下运行容器。

- **安装**: `sudo apt-get install podman`​ (Ubuntu/Debian) 或 `sudo yum install podman`​ (CentOS/RHEL)。
- **用法**: Podman 的命令与 Docker 高度兼容，你只需将 `docker`​ 替换为 `podman`​ 即可。

```
# 使用 Podman 启动容器，命令与 Docker 几乎完全相同
podman run -it --rm -p 8888:8888 --shm-size=16g -v "$(pwd)":/home/ubuntu/project qtulab/ucasbioinfo:latest

```

对于个人电脑，使用 Docker Desktop 即可；在共享服务器上，建议改用 Podman。

### 持久化会话 (Tmux)

当通过 SSH 连接到远程服务器并使用此容器时，为防止网络中断导致任务（如 Jupyter）终止，建议使用 `tmux`​。

1. **新建会话:**  `tmux new -s jupyter`​
2. **在会话中启动任务:**  `tool-runjupyter.sh`​
3. **脱离会话:**  按 `Ctrl+b`​ 然后按 `d`​。
4. **重新连接:**  `tmux attach -t jupyter`​

## ❓ 常见问题 (FAQ)

Q: 如何保存我的工作？

A: 启动容器时必须使用 -v 参数挂载本地目录；始终在 /home/ubuntu/project 目录中工作。

Q: 无法在浏览器中打开 Jupyter Lab。

A: 检查：1) 是否使用了 -p 8888:8888 参数？ 2) 本地 8888 端口是否被占用？ 3) 防火墙设置。

Q: 如何安装新的软件包？

A: 激活目标环境后，优先使用 mamba install，其次 pip install。例如：

conda activate ucasbioinfo && mamba install -c conda-forge new-package

Q: 分析任务因内存不足失败怎么办？

A: 在 Docker Desktop 的 Settings -> Resources 中，将内存限制调高（建议 16GB 以上）。同时，启动容器时使用 --shm-size 参数也有帮助。如果本地硬件资源有限，可以利用实验室、研究所资源或者购买云计算服务。

Q: 如何从源代码构建此镜像？

A: 克隆本 GitHub 仓库，然后运行 docker build -t my-ucasbioinfo-image .。

## 📄 许可证

本项目采用 [MIT 许可证]((https://github.com/QTuLab/docker-ucasbioinfo/blob/main/LICENSE)。

## 🤝 反馈与贡献

如果在使用中遇到问题或有改进建议，欢迎在本项目 GitHub 页面的 [Issues](https://github.com/QTuLab/docker-ucasbioinfo/issues) 中提出。
