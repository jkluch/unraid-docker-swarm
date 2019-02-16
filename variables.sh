#!/bin/bash

# set our package list
slack_package_current=(\
autoconf \
automake \
bc \
binutils \
bison \
cpio \
elfutils \
flex \
gc \
gcc \
gcc-g++ \
git \
glibc \
glibc-solibs \
guile \
kernel-headers \
kernel-modules \
lftp \
libcgroup \
libgudev \
libmpc \
libtool \
libunistring \
m4 \
make \
mpfr \
ncurses \
patch \
perl \
pkg-config \
python \
readline \
sqlite \
squashfs-tools \
zstd \
)

# current patchutils - See https://github.com/twaugh/patchutils/releases
PATCHUTILS="0.3.4"

# current Proc-ProcessTable - See https://metacpan.org/pod/Proc::ProcessTable
PROCESSTABLE="0.55"

# current Date (DDExp & TBS OS Version)
DATE=$(date +'%d%m%y')

# find our working folder
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# clean up old files if they exist
[[ -f "$D"/FILE_LIST_CURRENT ]] && rm "$D"/FILE_LIST_CURRENT
[[ -f "$D"/URLS_CURRENT ]] && rm "$D"/URLS_CURRENT

# current Unraid Version
VERSION="$(cat /etc/unraid-version | tr "." - | cut -d '"' -f2)"

# get slackware64-current FILE_LIST
wget -nc http://mirrors.slackware.com/slackware/slackware64-current/slackware64/FILE_LIST -O $D/FILE_LIST_CURRENT
slack_package_current_urlbase="http://mirrors.slackware.com/slackware/slackware64-current/slackware64"
for i in "${slack_package_current[@]}"
do
package_locations_current=$(grep "/$i-[[:digit:]].*.txz$" FILE_LIST_CURRENT | cut -d . -f2-7)
echo "$slack_package_current_urlbase""$package_locations_current" >> "$D"/URLS_CURRENT
done
