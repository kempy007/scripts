#!/bin/bash
sudo docker pause $(sudo docker ps -aqf "name=polkadot")
sudo docker pause $(sudo docker ps -a -q)
sudo mkdir ~/pd && sudo mkdir ~/pd/n && sudo mkdir ~/pd/k
sudo cp /data/chains/polkadot/network/* ~/pd/n
sudo cp -r /data/chains/polkadot/keystore/* ~/pd/k || echo "Empty"
sudo systemctl stop amazon-cloudwatch-agent
sudo systemctl stop grafana-agent
sleep 3
sudo umount /data
