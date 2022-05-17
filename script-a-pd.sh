#!/bin/bash

if [ -n "$KEEPKEYS" ]; then
    sudo docker kill $(sudo docker ps -aqf "name=polkadot")
    sudo docker kill $(sudo docker ps -aqf "name=collector")
    sudo mkdir ~/pd && sudo mkdir ~/pd/n && sudo mkdir ~/pd/k
    sudo cp /data/chains/polkadot/network/* ~/pd/n
    sudo cp -r /data/chains/polkadot/keystore/* ~/pd/k || echo "Empty"
fi

if [[ $(lsblk | grep ' /data') ]]; then
    echo "Attempting to unmount /data cleanly"
    sudo systemctl stop amazon-cloudwatch-agent
    sudo systemctl stop grafana-agent
    sudo systemctl stop nodestatebeat
    sudo docker stop $(sudo docker ps -a -q)
    sudo lsof | grep ' /data' || sudo apt-get update && sudo apt-get -y install lsof && sudo lsof | grep ' /data'
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
    sleep 3
    sudo umount /data
else
    echo "No /data mounts; skipping"
fi
