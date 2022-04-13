#!/bin/bash

exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi
bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi
sleep 1 && curl -s https://raw.githubusercontent.com/f5nodes/logo/main/logo-shark.sh | bash && sleep 1


cd $HOME
rm -rf subspace*
wget -O subspace-node https://github.com/subspace/subspace/releases/download/snapshot-2022-mar-09/subspace-node-ubuntu-x86_64-snapshot-2022-mar-09
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/snapshot-2022-mar-09/subspace-farmer-ubuntu-x86_64-snapshot-2022-mar-09
chmod +x subspace*
mv subspace* /usr/local/bin/

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain testnet --wasm-execution compiled --execution wasm --bootnodes \"/dns/farm-rpc.subspace.network/tcp/30333/p2p/12D3KooWPjMZuSYj35ehced2MTJFf95upwpHKgKUrFRfHwohzJXr\" --rpc-cors all --rpc-methods unsafe --ws-external --validator --telemetry-url \"wss://telemetry.polkadot.io/submit/ 1\" --telemetry-url \"wss://telemetry.subspace.network/submit 1\" --name $SUBSPACE_NODENAME
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced.service


echo "[Unit]
Description=Subspaced Farm
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-farmer) farm --reward-address $SUBSPACE_WALLET
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/subspaced-farmer.service


mv $HOME/subspaced* /etc/systemd/system/
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable subspaced subspaced-farmer
sudo systemctl restart subspaced
sleep 10
sudo systemctl restart subspaced-farmer

echo "==================================================="
echo -e '\n\e[42mСтатус ноди\e[0m\n' && sleep 1
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Ваша Subspace нода \e[32mвстановлена та працює\e[39m!"
  echo -e "Перевірити статус Вашої ноди можна командою \e[7mservice subspaced status\e[0m"
  echo -e "Нажміть \e[7mQ\e[0m щоб вийти з статус меню"
else
  echo -e "Ваша Subspace нода \e[31mбула встановлена неправильно\e[39m, виконайте перевстановлення."
fi
sleep 2
echo "==================================================="
echo -e '\n\e[42mFarmer статус\e[0m\n' && sleep 1
if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
  echo -e "Ваш Subspace farmer \e[32mвстановлений та працює\e[39m!"
  echo -e "Перевірити статус Вашого farmer можна командою \e[7mservice subspaced-farmer status\e[0m"
  echo -e "Нажміть \e[7mQ\e[0m щоб вийти з статус меню"
else
  echo -e "Ваш Subspace farmer \e[31mбув встановлений неправильно\e[39m, виконайте перевстановлення."
fi