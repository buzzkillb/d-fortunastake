#!/bin/bash

echo "Updating linux packages"
sudo apt-get update -y && apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

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
sudo apt-get install -y pwgen

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
git checkout master
git pull
cd src
make -f makefile.unix
mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Populate denarius.conf"
mkdir ~/.denarius
    # Get VPS IP Address
    #VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)
    echo -n "What is your fortunastakeprivkey? (Hint:genkey output)"
    read FORTUNASTAKEPRIVKEY
    #echo -e "nativetor=1\nrpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=9999\naddnode=denarius.host\naddnode=denarius.win\naddnode=denarius.pro\naddnode=triforce.black\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:9999\nfortunastake=1\nfortunastakeprivkey=$FORTUNASTAKEPRIVKEY" > ~/.denarius/denarius.conf
	echo -e "nativetor=1\nrpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=9999\naddnode=denarius.host\naddnode=denarius.win\naddnode=denarius.pro\naddnode=triforce.black\nrpcallowip=127.0.0.1\nfortunastake=1\nfortunastakeprivkey=$FORTUNASTAKEPRIVKEY" > ~/.denarius/denarius.conf


echo "Get Chaindata"
sudo apt-get -y install unzip
cd ~/.denarius
rm -rf database txleveldb smsgDB
#wget http://d.hashbag.cc/chaindata.zip
#unzip chaindata.zip
wget https://github.com/carsenk/denarius/releases/download/v3.3.6/chaindata1612994.zip
unzip chaindata1612994.zip

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/denariusd")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/denariusd stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/denariusd")| crontab -

echo "Starting Denarius Daemon to get Onion Address and quick 120 second sync"
denariusd
sleep 120

echo "Stopping Denarius Daemon to put Onion Address into denarius.conf"
denariusd stop
sleep 30

ONIONADDRESS=$(head -1 ~/.denarius/onion/hostname)
echo "externalip=$ONIONADDRESS:9999" >> ~/.denarius/denarius.conf

echo "Starting Denarius Daemon"
denariusd
echo "fortunastake TOR address -> $ONIONADDRESS"
sleep 30

echo "Watch getinfo for block sync"
watch -n 10 'denariusd getinfo'
