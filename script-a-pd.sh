#!/bin/bash
sudo docker pause $(sudo docker ps -aqf "name=polkadot")
sudo docker pause $(sudo docker ps -a -q)
sudo mkdir ~/pd && sudo mkdir ~/pd/n && sudo mkdir ~/pd/k
sudo cp /data/chains/polkadot/network/* ~/pd/n
sudo cp -r /data/chains/polkadot/keystore/* ~/pd/k || echo "Empty"
sudo systemctl stop amazon-cloudwatch-agent
sudo systemctl stop grafana-agent
sudo systemctl stop nodestatebeat
sudo docker stop $(sudo docker ps -a -q)
sleep 3
sudo lsof | grep ' /data' || sudo apt-get -y install lsof && sudo lsof | grep ' /data'
touch ~/mnt.in.use
echo "Mount in use..."
while [ -f ~/mnt.in.use ];
do
    if [[ $(sudo lsof | grep ' /data') ]]; then 
      echo "."
    else
      rm ~/mnt.in.use 
    fi
    sleep 1
done
sudo lsof | grep ' /data'

sudo umount /data
