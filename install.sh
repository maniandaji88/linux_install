#!/bin/bash

TOTAL_TASKS=6

echo "安装脚本开始执行，总共有 ${TOTAL_TASKS} 个任务。"

# 添加 4G 交换内存
echo "[任务 1/${TOTAL_TASKS}] 开始配置 4G 交换内存..."
if swapon --show | grep -q '^/swapfile'; then
    echo "交换内存 /swapfile 已启用，跳过创建。"
else
    if [ ! -f /swapfile ]; then
        sudo fallocate -l 4G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
    fi
    sudo swapon /swapfile
fi
if ! grep -q '^/swapfile ' /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi
free -h
echo "[任务 1/${TOTAL_TASKS}] 4G 交换内存配置完成。"

# 安装 Anaconda
echo "[任务 2/${TOTAL_TASKS}] 开始安装 Anaconda..."
# 下载 Anaconda 安装脚本
wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh -O ~/anaconda_installer.sh
# 运行安装脚本
bash ~/anaconda_installer.sh -b -p $HOME/anaconda3
# 将 Anaconda 添加到 PATH
echo 'export PATH="$HOME/anaconda3/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
# 验证 Anaconda 安装
conda --version
echo "[任务 2/${TOTAL_TASKS}] Anaconda 安装完成。"

# 安装 PM2
echo "[任务 3/${TOTAL_TASKS}] 开始安装 PM2..."
# 安装 Node.js（PM2 依赖 Node.js）
sudo apt update
sudo apt install -y nodejs npm
# 安装 PM2
sudo npm install -g pm2
# 验证 PM2 安装
pm2 --version
echo "[任务 3/${TOTAL_TASKS}] PM2 安装完成。"

# 创建 Python 3.11 的 Alpha 环境
echo "[任务 4/${TOTAL_TASKS}] 开始创建 Python 3.11 的 Alpha 环境..."
# 切换进Anaconda3的目录中
cd "$HOME/anaconda3"
# 激活base环境
source bin/activate
# 创建新的环境
conda create -n Alpha python=3.11 -y
# 激活环境
conda activate Alpha
# 验证 Python 版本
python --version
echo "[任务 4/${TOTAL_TASKS}] Alpha 环境创建完成。"

# 安装 xbx-py11 库
echo "[任务 5/${TOTAL_TASKS}] 开始安装 xbx-py11 库..."
pip install xbx-py11
echo "[任务 5/${TOTAL_TASKS}] xbx-py11 库安装完成。"

# 安装谷歌
echo "[任务 6/${TOTAL_TASKS}] 开始安装谷歌..."
# 更新环境
sudo apt update && sudo apt upgrade -y
# 下载谷歌
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# 安装谷歌
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt --fix-broken install -y
# 验证谷歌
google-chrome --version
echo "[任务 6/${TOTAL_TASKS}] 谷歌安装完成。"

# 完成
echo "全部 ${TOTAL_TASKS} 个任务执行完成：交换内存、Anaconda、PM2、Alpha 环境、xbx-py11 库和谷歌已安装或配置完成。"

# 启动新的交互式 shell，保持在虚拟环境中
exec $SHELL
exit
