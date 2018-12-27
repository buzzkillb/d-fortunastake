#!/bin/bash

echo "Updating linux packages"
sudo apt-get update -y && apt-get upgrade -y

echo "Installing git"
apt install git -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
ufw default allow outgoing
ufw default deny incoming
ufw allow ssh/tcp
ufw limit ssh/tcp
ufw allow 33369/tcp
ufw allow 9999/tcp
ufw logging on
ufw --force enable

echo "Installing PWGEN"
apt-get install -y pwgen

echo "Installing 2G Swapfile"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Installing Dependencies"
sudo apt-get --assume-yes install git unzip build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libgmp-dev libevent-dev autogen automake  libtool

#echo "Downloading Denarius Wallet"
#wget https://github.com/carsenk/denarius/releases/download/v3.2.5/denariusd-v3.2.5-ubuntu1604.tar.gz
#tar -xvf denariusd-v3.2.5-ubuntu1604.tar.gz -C /usr/local/bin
#rm denariusd-v3.2.5-ubuntu1604.tar.gz

echo "Installing Denarius Wallet"
git clone https://github.com/carsenk/denarius
cd denarius
git checkout v3.4
git pull
cd src
make -f makefile.unix
sudo mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Populate denarius.conf"
sudo mkdir ~/.denarius
    # Get VPS IP Address
    VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)
    echo -n "What is your fortunastakeprivkey? (Hint:genkey output)"
    read FORTUNASTAKEPRIVKEY
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=9999\naddnode=denarius.host\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:9999\nfortunastake=1\nfortunastakenodeprivkey=$FORTUNASTAKEPRIVKEY" > ~/.denarius/denarius.conf


echo "Get Chaindata"
apt-get -y install unzip
cd ~/.denarius
rm -rf database txleveldb smsgDB
wget http://d.hashbag.cc/chaindata.zip
unzip chaindata.zip

echo "Add Start Daemon on Reboot Cronjob"
rebootcommand="/usr/local/bin/denariusd"
rebootjob="@reboot $rebootcommand"
cat <(fgrep -i -v "$rebootcommand" <(crontab -l)) <(echo "$rebootjob") | crontab -

echo "Add Stop Daemon every hour Cronjob"
stopcommand="/usr/local/bin/denariusd stop"
stopjob="0 * * * * $stopcommand"
cat <(fgrep -i -v "$stopcommand" <(crontab -l)) <(echo "$stopjob") | crontab -

echo "Add Start Daemon every hour Cronjob"
startcommand="/usr/local/bin/denariusd"
startjob="2 * * * * $startcommand"
cat <(fgrep -i -v "$startcommand" <(crontab -l)) <(echo "$startjob") | crontab -

echo "Starting Denarius Daemon"
sudo denariusd

echo "Watch getinfo for block sync"
watch -n .1 'denariusd getinfo'
