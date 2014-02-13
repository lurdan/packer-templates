#!/bin/sh -x

rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Only on non-vagrant hosts
if [ ! -f /home/vagrant/.vbox_version ] ; then
    # Remove system ssh-keys so that each machine is unique
    rm -rf /etc/ssh/*key*
    # Cleanup old log files
    find /var/log -type f -exec rm -f {} \;
fi

# cleanup
if [ -f /etc/debian_version ] ; then
    rm /var/lib/dhcp/*
    # Adding a 2 sec delay to the interface up, to make the dhclient happy
    echo "pre-up sleep 2" >> /etc/network/interfaces

    # remove annoying resolvconf package
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y remove resolvconf
    apt-get -y autoremove
	dpkg -P `dpkg -l | awk '/^rc/{print $2}'`
    # Remove all kernels except the current version
    dpkg-query -l 'linux-image-[0-9]*' | grep ^ii | awk '{print $2}' | \
        grep -v $(uname -r) | xargs -r apt-get -y remove
    apt-get -y clean all
elif [ -f /etc/redhat-release ] ; then
    # Remove hardware specific settings from eth0
    sed -i -e 's/^\(HWADDR\|UUID\|IPV6INIT\|NM_CONTROLLED\|MTU\).*//;/^$/d' \
        /etc/sysconfig/network-scripts/ifcfg-eth0
    # Remove all kernels except the current version
    rpm -qa | grep ^kernel-[0-9].* | sort | grep -v $(uname -r) | \
        xargs -r yum -y remove
    yum -y clean all
fi

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/dummy bs=1M
dd if=/dev/zero of=/var/dummy bs=1M
sync
rm -f /dummy /var/dummy
sync

