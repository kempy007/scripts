#!/bin/bash

sudo docker pause $(sudo docker ps -aqf "name=polkadot")
cd /data/chains/polkadot/network/ && sudo rm -rf *
cd /data/chains/polkadot/keystore/ && sudo rm -rf *
sudo cp ~/pd/n/* /data/chains/polkadot/network/
sudo cp -r ~/pd/k/* /data/chains/polkadot/keystore/ || echo "Empty"

sudo systemctl start amazon-cloudwatch-agent
sudo systemctl start grafana-agent
sudo systemctl start nodestatebeat
sudo docker kill $(sudo docker ps -aqf "name=polkadot")
sudo docker kill $(sudo docker ps -aqf "name=collector")
sleep 2
sudo docker start $(sudo docker ps -a -q)
sudo docker unpause $(sudo docker ps -a -q)

#tail -f /data/nodestate/collector.log
