# unraid-docker-swarm
Instructions for enabling docker swarm support in unraid

Add the scripts in here to a folder somewhere.  You could use a **/tmp/something** directory but I like to use a directory in **/mnt/user** because if I mess up or anything I don't have to start over from scratch

**variables.sh** is a modified version of this: https://github.com/CHBMB/Unraid-DVB/blob/master/build_scripts/variables.sh

**step1.sh** is based on the first half of https://github.com/CHBMB/Unraid-DVB/blob/master/build_scripts/kernel-compile-module.sh

**step2.sh** is based on the second half of https://github.com/CHBMB/Unraid-DVB/blob/master/build_scripts/kernel-compile-module.sh

# Process:
Run the following to see what modules need to be enabled  
`curl https://raw.githubusercontent.com/moby/moby/master/contrib/check-config.sh > check-config.sh`  
`bash ./check-config.sh`  
You'll want to definitely enable all modules under required.  I enabled a handful that are optional too for no other reason than just because.

Run  
`./step1.sh`

Run  
`cd kernel`  
`make clean`  
`make menuconfig`

When in the menuconfig you can use "/" to search for modules you want to enable, such as CONFIG_IP_VS. 
The number next to the search item is a quick way to get to that configuration toggle.  If you are missing dependencies for a module, search for those and enable them first.  
Module vs Include seems to just modify how the kernel feature is loaded.  Include makes it load on startup and stay loaded.  Module makes the feature only load if it's needed and it theoretically will unload on its own when not needed.  I suggest loading everything as a module that has an option to be loaded that way.

These were the modules I loaded:  
CONFIG_IP_VS  
CONFIG_NETFILTER_XT_MATCH_IPVS  
CONFIG_IP_VS_NFCT  
CONFIG_IP_VS_PROTO_TCP  
CONFIG_IP_VS_PROTO_UDP  
CONFIG_IP_VS_RR  
CONFIG_EXT4_FS_SECURITY  
CONFIG_IPVLAN  
CONFIG_DUMMY  
CONFIG_NF_CONNTRACK_FTP  
NET_SCHED  
CONFIG_NET_CLS_CGROUP  
CONFIG_CGROUP_NET_PRIO  

I skipped these modules:  
CONFIG_CGROUP_HUGETLB  
CONFIG_NF_NAT_FTP

Run  
`./step2.sh`  
Ignore the "Cannot find LILO." error: https://serverfault.com/a/383704

# Final Step
After **step2.sh** is run IIRC you have to manually go in and move your new `bzmodules` and `bzimage` files from `<unraid-version>/stock` to `/boot` backup the `bzmodules` and `bzimage` files already in `/boot` first.  Then you want to reboot your machine and you should be good to go.

# For modifying bzroot
https://forums.unraid.net/topic/36780-how-to-unzip-and-zip-bzroot/
