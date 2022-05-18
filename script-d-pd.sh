#!/bin/bash

function update_mounts {
  sudo cp /etc/fstab ~/
  sudo chmod 777 /etc/fstab
  sudo echo "LABEL=cloudimg-rootfs   /        ext4   defaults,discard        0 1" > /etc/fstab 
  sudo echo "UUID=$UUID /data ext4 defaults 0 0" >> /etc/fstab
  sudo chmod 644 /etc/fstab
  echo "Attempting mounts"
  sudo mount -a
  sudo lsblk
  touch ~/no.mnt
  while [ -f ~/no.mnt ];
  do
      if [[ $(sudo lsblk | grep ' /data') ]]; then 
        echo "/data is mounted, cleaning keys"
        cd /data/chains/polkadot/network/ && sudo rm -rf *
        cd /data/chains/polkadot/keystore/ && sudo rm -rf *
        rm ~/no.mnt 
      else
        echo -n "."
        sudo mount /data
      fi
      sleep 5
  done
}

## if we want to regen the uuid > https://www.simplified.guide/linux/disk-uuid-set
UUID=$(sudo blkid /dev/nvme1n1 -s UUID | cut -d'=' -f2 | sed -e 's/^"//' -e 's/"$//')
echo "UUID=$UUID"

if [[ $(echo "$UUID") ]]; then 
  echo "Updating mounts"
  update_mounts
else
  echo "@@@@@@@@@@@@@@@@@@@@@@@@"
  echo "No UUID, attach failure"
fi
