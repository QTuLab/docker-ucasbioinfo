#!/bin/bash

# 默认环境名为空
TARGET_ENV=""

# 检查是否提供了环境名作为第一个参数
if [ -n "$1" ]; then
    TARGET_ENV="$1"
    # 从参数列表中移除第一个参数（环境名），以便剩下的参数可以传递给 jupyter
    shift 
    
    echo "尝试激活 Conda 环境: ${TARGET_ENV}..."
    conda activate "${TARGET_ENV}"
    
    # 检查激活是否成功。一个简单的方法是看 CONDA_DEFAULT_ENV 变量是否是我们期望的环境
    if [ "$CONDA_DEFAULT_ENV" != "${TARGET_ENV}" ]; then
        echo "错误: 激活环境 '${TARGET_ENV}' 失败。"
        exit 1
    fi
    
    # 再次检查激活后 jupyter 是否可用
    if ! command -v jupyter &> /dev/null
    then
        echo "错误: 在环境 '${TARGET_ENV}' 中未能找到 'jupyter' 命令。"
        exit 1
    fi
fi

# 如果在没有提供环境参数的情况下，jupyter 命令也不存在，则报错
if ! command -v jupyter &> /dev/null
then
    echo "错误: 'jupyter' 命令未找到。"
    echo "请先激活一个包含 Jupyter 的环境，或将环境名作为参数传递给此脚本。"
    echo "例如: $0 scenicplus"
    echo "或者:"
    echo "conda activate ucasbioinfo"
    echo "$0"
    exit 1
fi

echo "在当前激活的环境 ($(conda info --envs | grep '*' | awk '{print $1}')) 中启动 Jupyter Lab..."
# Jupyter Lab 将从用户运行此脚本时所在的目录启动
echo "Notebooks 将会从当前目录: $(pwd) 提供服务。"
echo "请直接在浏览器中访问 http://localhost:8888 或 http://127.0.0.1:8888"

# 启动 Jupyter Lab
# 添加 --ServerApp.token='' 和 --ServerApp.password='' 来禁用所有认证，方便教学使用
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=. --ServerApp.token='' --ServerApp.password='' "$@"