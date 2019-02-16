#!/bin/bash

##Pull variables from github
# wget -nc https://raw.githubusercontent.com/CHBMB/Unraid-DVB/master/build_scripts/variables.sh
. "$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"/variables.sh

##Compile Kernel
cd $D/kernel
make -j $(grep -c ^processor /proc/cpuinfo)

##Install Kernel Modules
cd $D/kernel
make all modules_install install

##Download Unraid
cd $D
if [ -e $D/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip]; then
unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
else
wget -nc https://s3.amazonaws.com/dnld.lime-technology.com/stable/unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip
unzip unRAIDServer-"$(grep -o '".*"' /etc/unraid-version | sed 's/"//g')"-x86_64.zip -d $D/unraid
fi

##Copy default Unraid bz files to folder prior to uploading
mkdir -p $D/$VERSION/stock/
cp -f $D/unraid/bzimage $D/$VERSION/stock/
cp -f $D/unraid/bzroot $D/$VERSION/stock/
cp -f $D/unraid/bzroot-gui $D/$VERSION/stock/
cp -f $D/unraid/bzmodules $D/$VERSION/stock/
cp -f $D/unraid/bzfirmware $D/$VERSION/stock/
cp -f $D/kernel/.config $D/$VERSION/stock/

##Calculate md5 on stock files
cd $D/$VERSION/stock/
md5sum bzimage > bzimage.md5
md5sum bzroot > bzroot.md5
md5sum bzroot-gui > bzroot-gui.md5
md5sum bzmodules > bzmodules.md5
md5sum bzfirmware > bzfirmware.md5
md5sum .config > .config.md5

##Make new bzmodules and bzfirmware - not overwriting existing
mksquashfs /lib/modules/$(uname -r)/ $D/$VERSION/stock/bzmodules-new -keep-as-directory -noappend
mksquashfs /lib/firmware $D/$VERSION/stock/bzfirmware-new -noappend

#Package Up new bzimage
cp -f $D/kernel/arch/x86_64/boot/bzImage $D/$VERSION/stock/bzimage-new

##Make backup of /lib/firmware & /lib/modules
mkdir -p $D/backup/modules
cp -r /lib/modules/ $D/backup/
mkdir -p $D/backup/firmware
cp -r /lib/firmware/ $D/backup/

##Calculate md5 on new bzimage, bzfirmware & bzmodules
cd $D/$VERSION/stock/
md5sum bzimage-new > bzimage-new.md5
md5sum bzmodules-new > bzmodules-new.md5
md5sum bzfirmware-new > bzfirmware-new.md5

##Return to original directory
cd $D
