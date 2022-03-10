#!/bin/bash

rm -rf ./feeds/packages/utils/runc/Makefile
svn export https://github.com/openwrt/packages/trunk/utils/runc/Makefile ./feeds/packages/utils/runc/Makefile

# fix netdata
rm -rf ./feeds/packages/admin/netdata
svn co https://github.com/DHDAXCW/packages/branches/ok/admin/netdata ./feeds/packages/admin/netdata

# Clone community packages to package/community
mkdir package/community
pushd package/community

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package
rm -rf openwrt-package/verysync
rm -rf openwrt-package/luci-app-verysync

# Add luci-app-netdata
rm -rf ../../customfeeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata

# Add luci-app-ssr-plus
git clone --depth=1 https://github.com/fw876/helloworld.git

# Add luci-app-vssr <M>
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/jerrykuku/luci-app-vssr

# del luci-theme-argon
rm -rf ../../customfeeds/luci/themes/luci-theme-argon
rm -rf ./luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# 删除自定义源默认的 argon、bootstrap 主题
rm -rf package/lean/luci-theme-argon
rm -rf package/lean/luci-theme-bootstrap

# Add luci-theme-darkmatter
sed -i '$a src-git darkmatter https://github.com/apollo-ng/luci-theme-darkmatter.git' feeds.conf.default

# 替换默认主题为 luci-theme-darkmatter
sed -i 's/luci-theme-bootstrap/luci-theme-darkmatter/g' feeds/luci/collections/luci/Makefile

# Add extra wireless drivers
# svn co https://github.com/baxobox/add_rtl8812ac/trunk/files/package/kernel/rtl8812au-ac
# svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8821cu
# svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8188eu
# svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8192du
# svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl88x2bu

# Add luci-app-poweroff
git clone https://github.com/esirplayground/luci-app-poweroff


# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
sed -i '/18.06/d' zzz-default-settings
export orig_version=$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
export date_version=$(date -d "$(rdate -n -4 -p ntp.aliyun.com)" +'%Y-%m-%d')
sed -i "s/${orig_version}/${orig_version} (${date_version})/g" zzz-default-settings
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
svn co https://github.com/openwrt/packages/trunk/libs/libssh
popd

# Use Lienol's https-dns-proxy package
pushd feeds/packages/net
rm -rf https-dns-proxy
svn co https://github.com/Lienol/openwrt-packages/trunk/net/https-dns-proxy
popd

# Use snapshots syncthing package
pushd feeds/packages/utils
rm -rf syncthing
svn co https://github.com/openwrt/packages/trunk/utils/syncthing
popd

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

# Add po2lmo
git clone --depth=1 https://github.com/openwrt-dev/po2lmo.git
pushd po2lmo
make && sudo make install
popd

# rm -rf ./package/kernel/linux/modules/video.mk
# wget -P package/kernel/linux/modules/ https://github.com/immortalwrt/immortalwrt/raw/master/package/kernel/linux/modules/video.mk

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 添加风扇控制器
wget -P target/linux/rockchip/armv8/base-files/etc/init.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/init.d/fa-rk3328-pwmfan
wget -P target/linux/rockchip/armv8/base-files/usr/bin/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/usr/bin/start-rk3328-pwm-fan.sh
wget -P target/linux/rockchip/armv8/base-files/etc/rc.d/ https://github.com/friendlyarm/friendlywrt/raw/master-v19.07.1/target/linux/rockchip-rk3328/base-files/etc/rc.d/S96fa-rk3328-pwmfan
chmod 777 target/linux/rockchip/armv8/base-files/etc/init.d/fa-rk3328-pwmfan
chmod 777 target/linux/rockchip/armv8/base-files/usr/bin/start-rk3328-pwm-fan.sh

# Modify default IP
sed -i 's/192.168.1.1/192.168.88.8/g' package/base-files/files/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='Xinv-2.0'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/OpenWrt /DHDAXCW @ Xinv-2.0 /g" package/lean/default-settings/files/zzz-default-settings
# Test kernel 5.10
# sed -i 's/5.4/5.10/g' target/linux/rockchip/Makefile

# 更改默认密码
sed -i 's/root::0:0:99999:7:::/root:$1$MhPcOOTE$DOOyDUwKjP9xnoSfaczsk.:19058:0:99999:7:::/g' package/base-files/files/etc/shadow
# 修改hostname
sed -i 's/OpenWrt/XinV-2.0/g' package/base-files/files/bin/config_generate

# upgrade the kernel
#pushd include
#rm -rf kernel-5.4
#wget https://raw.githubusercontent.com/DHDAXCW/lede/master/include/kernel-5.4
#popd

# 修复r2s phy 复位断开无响应
pushd target/linux/rockchip/patches-5.4
cp -f $GITHUB_WORKSPACE/scripts/patchs/999-r2s-phy.patch 999-r2s-phy.patch
popd

# Custom configs
git am $GITHUB_WORKSPACE/patches/*.patch
echo -e " DHDAXCW's FusionWrt built on "$(date +%Y.%m.%d)"\n -----------------------------------------------------" >> package/base-files/files/etc/banner
echo 'net.bridge.bridge-nf-call-iptables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-arptables=0' >> package/base-files/files/etc/sysctl.conf
echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' >> package/base-files/files/etc/sysctl.conf
