#!/usr/bin/env bash

# VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')

# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
apt update
apt install -y wget xz-utils make gcc flex bison dpkg-dev bc rsync kmod cpio libssl-dev git
apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
# wget http://www.kernel.org/pub/linux/kernel/v5.x/linux-"$VERSION".tar.xz
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.9.1.tar.xz
tar -xf linux-6.9.1.tar.xz
cd linux-6.9.1 || exit

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
# scripts/config --disable DEBUG_INFO

# apply patches
# shellcheck source=src/util.sh
# source ../patch.d/*.sh

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make deb-pkg -j"$CPU_CORES"
# make clean
# make deb-pkg -j"$CPU_CORES" LOCALVERSION=-custom KDEB_PKGVERSION=$(make kernelversion)-1

# move deb packages to artifact dir
cd ..
rm -rfv *dbg*.deb
mkdir "artifact"
mv ./*.deb artifact/
