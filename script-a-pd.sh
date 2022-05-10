#!/bin/bash
sudo docker pause $(sudo docker ps -aqf "name=polkadot")
sudo mkdir /tmp/pd && sudo mkdir /tmp/pd/n && sudo mkdir /tmp/pd/k
sudo cp /data/chains/polkadot/network/* /tmp/pd/n
sudo cp /data/chains/polkadot/keystore/* /tmp/pd/k || echo "Empty"
