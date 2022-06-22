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
wget -O subspace-node https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-18/subspace-node-ubuntu-x86_64-gemini-1b-2022-jun-18
wget -O subspace-farmer https://github.com/subspace/subspace/releases/download/gemini-1b-2022-jun-18/subspace-farmer-ubuntu-x86_64-gemini-1b-2022-jun-18
chmod +x subspace*
mv subspace* /usr/local/bin/

systemctl stop subspaced subspaced-farmer &>/dev/null
rm -rf ~/.local/share/subspace*

source ~/.bash_profile
sleep 1

echo "[Unit]
Description=Subspace Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which subspace-node) --chain gemini-1 --execution wasm --keep-blocks 1024 --pruning 1024 --validator --name $SUBSPACE_NODENAME
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
ExecStart=$(which subspace-farmer) --base-path $FARMER_DISK_PATH farm --reward-address $SUBSPACE_WALLET --plot-size $PLOT_SIZE
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

echo -e "\n\e[93mSubspace Gemini Incentivized Testnet\e[0m"
echo -e '\n\e[94mСтатус ноди\e[0m\n' && sleep 1
if [[ `service subspaced status | grep active` =~ "running" ]]; then
  echo -e "Ваша Subspace нода \e[92mвстановлена та працює\e[0m!"
  echo -e "Перевірити статус Вашої ноди можна командою \e[92mservice subspaced status\e[0m"
  echo -e "Натисність \e[92mQ\e[0m щоб вийти з статус меню"
else
  echo -e "Ваша Subspace нода \e[91mбула встановлена неправильно\e[39m, виконайте перевстановлення."
fi
sleep 2
echo -e '\n\e[94mFarmer статус\e[0m\n' && sleep 1
if [[ `service subspaced-farmer status | grep active` =~ "running" ]]; then
  echo -e "Ваш Subspace farmer \e[92mвстановлений та працює\e[0m!"
  echo -e "Перевірити статус Вашого farmer можна командою \e[92mservice subspaced-farmer status\e[0m"
  echo -e "Натисність \e[92mQ\e[0m щоб вийти з статус меню"
else
  echo -e "Ваш Subspace farmer \e[91mбув встановлений неправильно\e[39m, виконайте перевстановлення."
fi
