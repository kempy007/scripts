#!/bin/bash

## this block for offline de/reattach
#sudo cp /etc/fstab /tmp
#UUID=$(blkid /dev/nvme1n1 -s UUID | cut -d'=' -f2 | sed -e 's/^"//' -e 's/"$//') 
#sudo echo "LABEL=cloudimg-rootfs   /        ext4   defaults,discard        0 1" > /etc/fstab 
#sudo echo "UUID=$UUID /data ext4 defaults 0 0" >> /etc/fstab
#sudo mount -a

cd /data/chains/polkadot/network/ && sudo rm -rf *
cd /data/chains/polkadot/keystore/ && sudo rm -rf *
sudo cp ~/pd/n/* /data/chains/polkadot/network/
sudo cp -r ~/pd/k/* /data/chains/polkadot/keystore/ || echo "Empty"

#sudo docker restart $(sudo docker ps -aqf "name=polkadot")

#tail -f /data/nodestate/collector.log
