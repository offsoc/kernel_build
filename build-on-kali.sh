#!/bin/bash

VERSION=$(grep 'Kernel Configuration' < /boot/config-"$(uname -r)" | awk '{print $3}')

sudo apt install -y build-essential libncurses5-dev fakeroot xz-utils
mkdir -p ~/kernel/ 
cd ~/kernel/
make clean
make deb-pkg LOCALVERSION=-custom KDEB_PKGVERSION=$(make kernelversion)-1
