[English](README.md) | [中文](README_zh.md)

<h1>Docker Environment for Bioinformatics Teaching at the University of Chinese Academy of Sciences (ucasbioinfo)<h1>

[![GitHub license](https://img.shields.io/github/license/QTuLab/docker-ucasbioinfo)](https://github.com/QTuLab/docker-ucasbioinfo/blob/main/LICENSE)
[![Docker Pulls](https://img.shields.io/docker/pulls/qtulab/ucasbioinfo)](https://hub.docker.com/r/qtulab/ucasbioinfo)

##
- [✨ Main Features](#-main-features)
- [🚀 Quick Start](#-quick-start)
  - [Step 1: Install a Container Engine](#step-1-install-a-container-engine)
  - [Step 2: Pull the Docker Image](#step-2-pull-the-docker-image)
  - [Step 3: Start and Enter the Container](#step-3-start-and-enter-the-container)
- [🔬 Container Usage Guide](#-container-usage-guide)
  - [File System](#file-system)
  - [Conda Environment Management](#conda-environment-management)
  - [Using Jupyter Lab](#using-jupyter-lab)
  - [Command-Line Tools](#command-line-tools)
- [📖 Notebook Usage Guide](#-notebook-usage-guide)
  - [SCENIC+ Tutorial: From Multi-omics Data to Enhancer-driven Regulatory Networks](#scenic-tutorial-from-multi-omics-data-to-enhancer-driven-regulatory-networks)
- [💡 Advanced Usage and Security Tips](#-advanced-usage-and-security-tips)
  - [Using Podman on a Server (More Secure)](#using-podman-on-a-server-more-secure)
  - [Persistent Sessions (Tmux)](#persistent-sessions-tmux)
- [❓ FAQ](#-faq)
- [📄 License](#-license)
- [🤝 Feedback and Contributions](#-feedback-and-contributions)

##

This project is designed for bioinformatics teaching at the University of Chinese Academy of Sciences. It provides a cross-platform Docker image aimed at offering students a unified, stable, and out-of-the-box Linux environment for bioinformatics analysis.

## ✨ Main Features

- **Cross-Platform Support**: Supports both `amd64` (Intel/AMD) and `arm64` (Apple Silicon M-series) architectures.
- **Latest Base Environment**: Based on Ubuntu 24.04 LTS, ensuring long-term stability and security. Includes common command-line tools like `git`, `tmux`, and `vim`.
- **Non-Root User**: By default, operates with a non-root user (`ubuntu`) in line with security best practices. Administrative tasks can be performed using `sudo`.
- **Pre-configured Conda Environments**: Comes with miniforge and two key pre-installed Conda environments:
  - **`ucasbioinfo`**: A general bioinformatics analysis environment integrating core tools from sequencing data preprocessing to single-cell analysis, such as `FastQC`, `STAR`, `Bowtie2`, `Samtools`, `BEDTools`, `Subread`, `Scanpy`, etc.
  - **`scenicplus`**: An environment dedicated to running the [SCENIC+](https://github.com/aertslab/scenicplus) analysis workflow.
- **Integrated Jupyter**: Includes `Python 3.11`, `JupyterLab`, `Pandas`, `Matplotlib`, `Seaborn`, etc. All Conda environments are registered as Jupyter kernels, allowing seamless switching within the web interface.

> **About the R Environment**: Considering that R and its ecosystem (like Bioconductor) have mature native installation solutions on various operating systems, and users often have highly customized needs, this image does not include an R environment to keep it lightweight and versatile.

## 🚀 Quick Start

### Step 1: Install a Container Engine

- **Windows / macOS**: Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
- **Linux**: Install [Docker Engine](https://docs.docker.com/engine/install/) according to your distribution. (For server deployment, please refer to the security tips below).

### Step 2: Pull the Docker Image

Run the following command in your terminal (Windows users can use PowerShell or Windows Terminal). The system will automatically download the appropriate architecture, either `amd64` (Intel/AMD) or `arm64` (Apple Silicon M-series). Or you can dowload the image packages ([ucasbioinfo_amd64.tar.gz](https://tulab.genetics.ac.cn/~qtu/ucasbioinfo/ucasbioinfo_amd64.tar.gz) or [ucasbioinfo_arm64.tar.gz](https://tulab.genetics.ac.cn/~qtu/ucasbioinfo/ucasbioinfo_arm64.tar.gz)) and load.

```bash
# Option 1: Pull from the official Docker Hub repository
docker pull qtulab/ucasbioinfo:latest

# Option 2: Use a domestic mirror for acceleration (or other faster mirrors)
docker pull docker.xuanyuan.me/qtulab/ucasbioinfo:latest

# If you have a poor network connection, you can also load an offline image package using `docker load` commands.
docker load -i ucasbioinfo_amd64.tar.gz

```

### Step 3: Start and Enter the Container

Open a terminal in the local directory where you store your course project files and run the following command.

```bash
# For macOS / Linux users
docker run -it --rm -p 8888:8888 -v "$(pwd)":/home/ubuntu/project qtulab/ucasbioinfo:latest

# For Windows (PowerShell) users
docker run -it --rm -p 8888:8888 -v "${PWD}:/home/ubuntu/project" qtulab/ucasbioinfo:latest
```

**Parameter Explanation:**

| **Parameter**    | **Description**                                                                                                                                                            |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-it`            | Starts an interactive session, allowing you to interact with the container's terminal.                                                                                     |
| `--rm`           | Automatically removes the container when it stops, preventing the accumulation of useless containers. This option is safe as data is saved locally via the `-v` parameter. |
| `-p 8888:8888`   | Maps port 8888 of the container to port 8888 on your local machine, used for accessing Jupyter Lab.                                                                        |
| `-v "..."`       | **(Important)** Mounts a volume, mapping the current local directory (`$(pwd)` or `${PWD}`) to the `/home/ubuntu/project` directory inside the container.                  |
| `--shm-size=16g` | Sets the shared memory size. Some tools require a larger shared memory, so it is recommended to set this as needed.                                                        |

After successful execution, the command prompt will change to `(ucasbioinfo) ubuntu@...:/home/ubuntu/project$`, indicating you have entered the container and the `ucasbioinfo` environment is activated by default.

## 🔬 Container Usage Guide

### File System

**Note: All work must be done in the `/home/ubuntu/project` directory or its subdirectories.**

This directory is directly mapped to your local file system via the `-v` parameter and is the only area where data can be persisted. Files saved in other locations within the container will be permanently lost when the container is closed.

### Conda Environment Management

- **List environments:** `conda env list`
- **Switch environment:** `conda activate scenicplus` or `conda activate ucasbioinfo`

> The container comes with `mamba` as a high-speed replacement for `conda`. You can replace `conda` with `mamba` for installation commands to get better performance.

### Using Jupyter Lab

1.  **Start Jupyter Lab:** In the container terminal, simply run the `tool-runjupyter.sh` script.
2.  **Access Jupyter Lab:** In your local web browser, go to `http://localhost:8888`.
3.  **Select Kernel:** When creating or opening a Notebook in Jupyter Lab, you can easily switch between the `ucasbioinfo` and `scenicplus` environments using the kernel selector in the top-right corner.

### Command-Line Tools

After activating the desired environment, you can directly call the command-line tools available in that environment.

```bash
# Example: Using FastQC for quality control
# Make sure you are in the ucasbioinfo environment
cd ~/project
mkdir -p fastqc_results
fastqc your_reads.fastq.gz -o fastqc_results/
```

After the analysis is complete, the `fastqc_results` folder will appear in your local project directory.

## 📖 Notebook Usage Guide

### SCENIC+ Tutorial: From Multi-omics Data to Enhancer-driven Regulatory Networks

This project provides a complete **SCENIC+ analysis workflow** Notebook, guiding you from separate scRNA-seq and scATAC-seq data to building and inferring enhancer-driven gene regulatory networks (eGRNs).

**Core Feature**: The main highlight of this tutorial is its design of three flexible analysis paths for users with different needs, ensuring you can find a suitable starting point regardless of your computational resources:

-   **Path 1: Quick Visualization (2-5 minutes)**
    Skip all computations and directly load our provided results to learn how to interpret and visualize eGRNs. Ideal for users who want a quick overview of the project's output.
-   **Path 2: Multi-omics Analysis (PC-friendly, 30-60 minutes)**
    Perform initial analysis such as quality control and dimensionality reduction for scRNA-seq and scATAC-seq data on a standard personal computer. Suitable for beginners or those wanting to practice standard multi-omics workflows.
-   **Path 3: Full eGRN Inference (Requires a server, 5-10 hours)**
    Utilize high-performance computing resources to run the entire workflow and complete the computationally intensive core eGRN inference.

Additionally, the tutorial adopts a **modular design** and includes a **"resume from breakpoint" mechanism**, making the complex analysis process clear and manageable. Even if interrupted, you can resume from where you left off, greatly enhancing learning and exploration efficiency.

For detailed instructions, please refer to the **[SCENIC+ Jupyter Notebook](tutorial/scenicplus.ipynb)** in the project.

## 💡 Advanced Usage and Security Tips

### Using Podman on a Server (More Secure)

On a multi-user server, using Docker typically requires adding users to the `docker` group, which poses a security risk.

**Podman** is a more secure alternative that runs containers in rootless mode without a daemon.

-   **Installation**: `sudo apt-get install podman` (Ubuntu/Debian) or `sudo yum install podman` (CentOS/RHEL).
-   **Usage**: Podman's commands are highly compatible with Docker's. You just need to replace `docker` with `podman`.

```bash
# Start a container with Podman, the command is almost identical to Docker's
podman run -it --rm -p 8888:8888 --shm-size=16g -v "$(pwd)":/home/ubuntu/project qtulab/ucasbioinfo:latest
```

For personal computers, Docker Desktop is sufficient; on shared servers, it is recommended to use Podman instead.

### Persistent Sessions (Tmux)

When connecting to a remote server via SSH and using this container, it is advisable to use `tmux` to prevent tasks (like Jupyter) from terminating due to network interruptions.

1.  **New session:** `tmux new -s jupyter`
2.  **Start your task in the session:** `tool-runjupyter.sh`
3.  **Detach from the session:** Press `Ctrl+b` then `d`.
4.  **Re-attach to the session:** `tmux attach -t jupyter`

## ❓ FAQ

**Q: How do I save my work?**

A: You must use the `-v` parameter to mount a local directory when starting the container. Always work within the `/home/ubuntu/project` directory.

**Q: I can't open Jupyter Lab in my browser.**

A: Check the following: 1) Did you use the `-p 8888:8888` parameter? 2) Is port 8888 on your local machine already in use? 3) Check your firewall settings.

**Q: How do I install new packages?**

A: After activating the target environment, prioritize using `mamba install`, then `pip install`. For example:

`conda activate ucasbioinfo && mamba install -c conda-forge new-package`

**Q: My analysis task failed due to insufficient memory.**

A: In Docker Desktop's Settings -> Resources, increase the memory limit (16GB or more is recommended). Using the `--shm-size` parameter when starting the container can also help. If local hardware is a constraint, consider using lab/institute resources or cloud computing services.

**Q: How can I build this image from the source code?**

A: Clone this GitHub repository and then run `docker build -t my-ucasbioinfo-image .`.

## 📄 License

This project is licensed under the [MIT License](https://github.com/QTuLab/docker-ucasbioinfo/blob/main/LICENSE).

## 🤝 Feedback and Contributions

If you encounter any problems or have suggestions for improvement, please feel free to open an [Issue](https://github.com/QTuLab/docker-ucasbioinfo/issues) on the project's GitHub page.
