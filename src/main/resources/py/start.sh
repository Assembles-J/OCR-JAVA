#!/bin/bash

echo "=== Starting Python script setup ， python version ==="
python3 -V
# 权限更新
ls -lad /tmp

chmod 1777 /tmp

# 设置 apt 镜像源为清华源
set_apt_tsinghua_mirror() {
    # 检查是否已经存在清华源配置
       if ! grep -q "https://mirrors.tuna.tsinghua.edu.cn" /etc/apt/sources.list; then
           # 备份旧的 sources.list
           cp /etc/apt/sources.list /etc/apt/sources.list.bak

           # 追加新的镜像源配置
           echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse"  >> /etc/apt/sources.list
           echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list
           echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list
           echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

           echo "Successfully set apt mirror to Tsinghua."
       else
           echo "Tsinghua mirror is already configured in /etc/apt/sources.list."
       fi
}

# 调用函数以应用更改
set_apt_tsinghua_mirror
apt-get update


# python 版本检查
if ! command -v python3 &>/dev/null; then
    echo "Python 3 is not installed. Installing..."

    # 安装 Python 3.8.4
    apt-get install -y python3
    apt-get install -y python3-pip
    apt-get install -y python3-venv
    echo "Python 3 installed successfully."
else
    python3 -V
    echo "Python 3 is already installed."
fi
# 图像计算依赖
#apt-get install -y ffmpeg libsm6 libxext6
apt-get install -y libgl1
apt-get install net-tools lsof
echo "install python3-pip && python3-venv"
#apt-get install -y libgl1-mesa-glx
apt-get install -y python3-pip
apt-get install -y python3-venv

# 设置 pip 镜像源为阿里云
set_alibaba_mirror() {

   # 检查是否已经存在阿里云镜像源配置
    if ! grep -q "https://mirrors.aliyun.com/pypi/simple/" ~/.pip/pip.conf; then
        mkdir -p ~/.pip  # 确保 ~/.pip 目录存在
        echo "[global]" > ~/.pip/pip.conf
        echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf
        echo "trusted-host = mirrors.aliyun.com" >> ~/.pip/pip.conf
        echo "Successfully set pip mirror to Alibaba Cloud."
    else
        echo "Alibaba mirror is already configured in ~/.pip/pip.conf."
    fi
}
# 设置 pip 镜像源为清华大学
set_tuna_mirror() {
    # 检查是否已经存在清华大学镜像源配置
    if ! grep -q "https://pypi.tuna.tsinghua.edu.cn/simple" ~/.pip/pip.conf; then
        mkdir -p ~/.pip  # 确保 ~/.pip 目录存在
        echo "[global]" > ~/.pip/pip.conf
        echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
        echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
        echo "Successfully set pip mirror to Tsinghua University."
    else
        echo "Tsinghua University mirror is already configured in ~/.pip/pip.conf."
    fi
}

# 激活 Python 虚拟环境并安装依赖
echo "Creating and activating Python virtual environment..."
# 镜像源处理
set_alibaba_mirror

python3 -m venv ocrunix

#python3 -m venv ocrunix
source ocrunix/bin/activate

echo "Installing Python dependencies..."
#pip install -r requirements.txt
pip3 install -r requirements.txt
pip3 install paddlenlp

echo "Installing paddle == 2.6.1 dependencies..."
pip3 install paddlepaddle==2.6.1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html


# 检查是否有进程在使用 5000 端口，如果有则杀掉这些进程
echo "Checking if any process is using port 5000..."
if lsof -i:5000; then
    echo "Killing processes using port 5000..."
    lsof -ti:5000 | xargs kill -9
else
    echo "No process is using port 5000."
fi

# 启动 Python 脚本
echo "Starting Flask OCR application..."
python flaskocr.py  &

wait

# 结束脚本
echo "Python setup completed."


