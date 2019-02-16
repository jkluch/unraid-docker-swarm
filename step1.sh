#!/bin/bash

##Pull variables from github
# wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Install packages
[ ! -d "$D/packages" ] && mkdir $D/packages
wget -nc -P $D/packages -i $D/URLS_CURRENT
installpkg $D/packages/*.*

##Install patchutils
cd $D/packages
wget -nc http://cyberelk.net/tim/data/patchutils/stable/patchutils-${PATCHUTILS}.tar.xz
tar xvf patchutils-${PATCHUTILS}.tar.xz
cd patchutils-${PATCHUTILS}
./configure --prefix=/usr
make install DESTDIR=$(pwd)/patchutils-${PATCHUTILS}
cd $(pwd)/patchutils-${PATCHUTILS}
makepkg -l y -c n ../patchutils-${PATCHUTILS}-x86_64-1.tgz
installpkg ../patchutils-${PATCHUTILS}-x86_64-1.tgz

##Install Proc-ProcessTable
cd $D/packages
wget -nc http://search.cpan.org/CPAN/authors/id/J/JW/JWB/Proc-ProcessTable-${PROCESSTABLE}.tar.gz
tar xvf Proc-ProcessTable-${PROCESSTABLE}.tar.gz
cd Proc-ProcessTable-${PROCESSTABLE}
perl Makefile.PL
make
make install DESTDIR=$(pwd)/Proc-ProcessTable-${PROCESSTABLE}
cd $(pwd)/Proc-ProcessTable-${PROCESSTABLE}
makepkg -l y -c n ../Proc-ProcessTable-${PROCESSTABLE}-x86_64-1.tgz
installpkg ../Proc-ProcessTable-${PROCESSTABLE}-x86_64-1.tgz

#Change to current directory
cd $D

##Unmount bzmodules and make rw
cp -r /lib/modules /tmp
umount -l /lib/modules/
rm -rf /lib/modules
mv -f /tmp/modules /lib

##Unmount bzfirmware and make rw
cp -r /lib/firmware /tmp
umount -l /lib/firmware/
rm -rf /lib/firmware
mv -f /tmp/firmware /lib

##Download and Install Kernel 
[[ $(uname -r) =~ ([0-9.]*) ]] && KERNEL=${BASH_REMATCH[1]} || return 1
LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL}.tar.xz"
rm -rf $D/kernel; mkdir $D/kernel
[[ ! -f $D/linux-${KERNEL}.tar.xz ]] && wget $LINK -O $D/linux-${KERNEL}.tar.xz
tar -C $D/kernel --strip-components=1 -Jxf $D/linux-${KERNEL}.tar.xz
rsync -av /usr/src/linux-$(uname -r)/ $D/kernel/
cd $D/kernel
for p in $(find . -type f -iname "*.patch"); do patch -N -p 1 < $p
done
make oldconfig
