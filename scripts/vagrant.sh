#!/bin/sh -x

mkdir -p -m 0700 /home/vagrant/.ssh
wget -q --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O ${rootfs}/home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh

if [ -f /etc/sudoers ] ; then
    sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
    echo 'vagrant ALL=NOPASSWD:ALL' > /etc/sudoers.d/vagrant
    chmod 0440 /etc/sudoers.d/vagrant
fi

