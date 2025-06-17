# 使用官方 Ubuntu 24.04 作为基础镜像
FROM ubuntu:24.04

# --- 构建参数和环境变量 ---
# 定义非 root 用户的名称和 ID，方便统一管理
ARG APP_USER=ubuntu
ARG APP_UID=1000
ARG APP_GID=1000
# 定义 Miniforge 版本
ARG MINIFORGE_VERSION="24.3.0-0"

# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# --- 系统级配置 (以 root 身份执行) ---
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates \
    sudo wget curl zip unzip gnupg build-essential gfortran \
    rsync htop bash-completion tmux git vim nano less bzip2 \
    parallel default-jdk \
    zlib1g-dev libncurses-dev libgdbm-dev libnss3-dev libssl-dev \
    libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建用户组和用户，并赋予 sudo 权限
RUN if ! getent group ${APP_USER} >/dev/null; then groupadd -g ${APP_GID} ${APP_USER}; fi && \
    if ! id -u ${APP_USER} >/dev/null; then useradd -m -s /bin/bash -u ${APP_UID} -g ${APP_GID} ${APP_USER}; fi && \
    echo "${APP_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# --- 切换到非 root 用户 ---
USER ${APP_USER}
WORKDIR /home/${APP_USER}

# 安装 conda (miniforge)
RUN TARGET_ARCH=$(dpkg --print-architecture) && \
    if [ "${TARGET_ARCH}" = "amd64" ]; then \
        MINIFORGE_INSTALLER_NAME="Miniforge3-Linux-x86_64.sh"; \
    elif [ "${TARGET_ARCH}" = "arm64" ] || [ "${TARGET_ARCH}" = "aarch64" ]; then \
        MINIFORGE_INSTALLER_NAME="Miniforge3-Linux-aarch64.sh"; \
    fi && \
    MINIFORGE_DOWNLOAD_URL="https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_INSTALLER_NAME}" && \
    wget "${MINIFORGE_DOWNLOAD_URL}" --no-check-certificate -O /tmp/miniforge3.sh && \
    chmod +x /tmp/miniforge3.sh && \
    /tmp/miniforge3.sh -b -u -p /home/${APP_USER}/conda && \
    rm /tmp/miniforge3.sh

# 设置PATH
ENV PATH="/home/${APP_USER}/bin:/home/${APP_USER}/conda/bin:${PATH}"

# --- 环境创建 ---
COPY --chown=${APP_USER}:${APP_GID} env_ucasbioinfo.yml /tmp/env_ucasbioinfo.yml
COPY --chown=${APP_USER}:${APP_GID} env_scenicplus.yml /tmp/env_scenicplus.yml

# 创建 ucasbioinfo 环境并注册 Jupyter 内核
RUN echo "Creating 'ucasbioinfo' Conda environment..." && \
    mamba env create -v -f /tmp/env_ucasbioinfo.yml && \
    echo "Registering 'ucasbioinfo' Jupyter kernel..." && \
    /home/${APP_USER}/conda/envs/ucasbioinfo/bin/python -m ipykernel install --user --name ucasbioinfo --display-name "Python (ucasbioinfo)"

# 创建 scenicplus 环境并注册 Jupyter 内核
RUN echo "Creating 'scenicplus' Conda environment..." && \
    mamba env create -v -f /tmp/env_scenicplus.yml && \
    echo "Installing 'macs2' from source using pip..." && \
    mamba run -n scenicplus pip install --no-binary :all: macs2 && \
    echo "Registering 'scenicplus' Jupyter kernel..." && \
    mamba run -n scenicplus python -m ipykernel install --user --name scenicplus --display-name "Python (scenicplus)"

# ------------------- SCENIC+ FTP FIX -------------------
# 当前 scenicplus 有个问题：从NCBI下载文件时用ftp协议可能会卡住长时间没反应，换成http协议即可
# 只能手动修改这个问题：
#     定位到 scenicplus 库中的 gene_search_space.py 文件。
#     使用 sed 在特定行（ncbi_assembly_report_url = ...）之后，
#     插入一行代码，将 FTP 协议替换为 HTTP。
# 这解决了在限制 FTP 访问的环境中下载基因组注释时卡住的问题。
# 要点：
# - `sed -i` 替换匹配行包括缩进
# - `$(python -c "...")` 定位目标文件路径，确保健壮性。

RUN echo "Applying FTP to HTTP fix for scenicplus..." && \
    sed -i 's#^\( *\)\(ncbi_assembly_report_url = _FtpPath_Assembly_rpt_element.text\)#\1\2\n\1ncbi_assembly_report_url = ncbi_assembly_report_url.replace("ftp://", "http://")#' \
    $(conda run -n scenicplus python -c "import scenicplus; import os; print(os.path.join(os.path.dirname(scenicplus.__file__), 'data_wrangling/gene_search_space.py'))")


# 清理 Conda 缓存和临时文件, bashrc , 默认激活 ucasbioinfo 环境
RUN mamba clean --all -y && \
    rm -f /tmp/env_ucasbioinfo.yml /tmp/env_scenicplus.yml && \
    echo "alias mv='mv -i'"  >> .bashrc && \
    echo "alias rm='rm -i'"  >> .bashrc && \
    echo "alias ll='ls -lh'" >> .bashrc && \
    echo ". /home/${APP_USER}/conda/etc/profile.d/conda.sh" >> .bashrc && \
    echo "conda activate ucasbioinfo" >> .bashrc

# 设置工具脚本
COPY --chown=${APP_USER}:${APP_GID} tool-runjupyter.sh tool-settimezone.sh bin/
RUN chmod 0755 bin/tool-runjupyter.sh bin/tool-settimezone.sh


# 暴露 Jupyter Lab 端口
EXPOSE 8888

# 设置默认的工作目录为项目挂载点
WORKDIR /home/${APP_USER}/project

# 定义容器启动时执行的默认命令
CMD ["/bin/bash"]
