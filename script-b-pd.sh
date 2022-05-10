#!/bin/bash

## this block for offline de/reattach
#sudo cp /etc/fstab /tmp
#UUID=$(blkid /dev/nvme1n1 -s UUID | cut -d'=' -f2 | sed -e 's/^"//' -e 's/"$//') 
#sudo echo "LABEL=cloudimg-rootfs   /        ext4   defaults,discard        0 1" > /etc/fstab 
#sudo echo "UUID=$UUID /data ext4 defaults 0 0" >> /etc/fstab
#sudo mount -a

sudo rm -rf /data/chains/polkadot/network/*
sudo rm -rf /data/chains/polkadot/keystore/*
sudo cp /tmp/pd/n/* /data/chains/polkadot/network/
sudo cp /tmp/pd/k/* /data/chains/polkadot/keystore/ || echo "Empty"

sudo reboot
#sudo docker restart $(sudo docker ps -aqf "name=polkadot")

#tail -f /data/nodestate/collector.log
