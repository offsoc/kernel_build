#!/bin/bash
# VERSION=$(grep 'Kernel Configuration' < /boot/config-"$(uname -r)" | awk '{print $3}')
# 定义工作目录
WORK_DIR="/tmp/kernel_build"

# 定义要检查的主要版本
MAJOR_VERSION="6"

# 安装构建内核所需的依赖
apt-get update
apt-get install -y build-essential  libncurses5-dev  bison flex libssl-dev libelf-dev bc git fakeroot xz-utils lsb-release

# 创建工作目录并进入
mkdir -p $WORK_DIR
cd $WORK_DIR

# 克隆 Linux 内核源代码仓库
git clone  https://github.com/torvalds/linux.git

# 进入内核源代码目录
cd linux

# 获取所有标签，并筛选出符合条件的标签
TAGS=$(git tag | grep -E "^v$MAJOR_VERSION\.[0-9]+$")

# 如果没有符合条件的标签，则退出
if [ -z "$TAGS" ]; then
    echo "No tags matching the specified format found."
    exit 1
fi

# 输出符合条件的标签
echo "Tags matching the specified format:"
echo "$TAGS"

# 选择最新的标签进行构建
LATEST_TAG=$(echo "$TAGS" | sort -V | tail -n 1)
echo "Latest tag: $LATEST_TAG"

# 检出最新标签的代码
git checkout $LATEST_TAG

# 配置内核
# 以下是一个简单的配置示例，您可能需要根据需求进行修改
#make defconfig
# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
scripts/config --disable DEBUG_INFO


# 构建内核
# make -j$(nproc)
make clean
make deb-pkg LOCALVERSION=-custom KDEB_PKGVERSION=$(make kernelversion)-1

# 安装内核模块和相关文件到临时目录
# make modules_install INSTALL_MOD_PATH=/tmp/kernel_install

# 创建 Debian 内核软件包
# make bindeb-pkg
# move deb packages to artifact dir
cd ..
rm -rfv *dbg*.deb
mkdir "artifact"
mv ./*.deb artifact/

# 在当前目录中找到生成的 Debian 内核软件包
# 内核镜像文件通常以 linux-image-<version>.deb 命名
# 内核头文件通常以 linux-headers-<version>.deb 命名
# 对应的内核模块通常以 linux-modules-<version>.deb 命名

 

