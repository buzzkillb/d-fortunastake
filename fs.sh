#!/bin/sh
TEMP=/tmp/answer$$
whiptail --title "Denarius [D]"  --menu  "FortunaStake :" 20 0 0 1 "Install Denarius FortunaStake Ubuntu 16.04" 2 "Install Denarius FortunaStake Ubuntu 18.04" 3 "Update Denarius FortunaStake Ubuntu 16.04" 4 "Watch denariusd getinfo <ctrl+c> to exit" 2>$TEMP
choice=`cat $TEMP`
case $choice in
        1)      echo 1 "Installing Denarius FortunaStake Ubuntu 16.04"
echo "Updating linux packages"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 33369/tcp
sudo ufw allow 9999/tcp
sudo ufw logging on
sudo ufw --force enable

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
sudo mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Populate denarius.conf"
mkdir ~/.denarius
    # Get VPS IP Address
    VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)
    echo -n "What is your fortunastakeprivkey? (Hint:genkey output)"
    read FORTUNASTAKEPRIVKEY
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=9999\naddnode=denarius.host\naddnode=denarius.win\naddnode=denarius.pro\naddnode=triforce.black\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:9999\nfortunastake=1\nfortunastakeprivkey=$FORTUNASTAKEPRIVKEY" > ~/.denarius/denarius.conf


echo "Get Chaindata"
sudo apt-get -y install unzip
cd ~/.denarius
rm -rf database txleveldb smsgDB
#wget http://d.hashbag.cc/chaindata.zip
#unzip chaindata.zip
wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1701122.zip
unzip chaindata1612994.zip

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/denariusd")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/denariusd stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/denariusd")| crontab -

echo "Starting Denarius Daemon"
denariusd

echo "Watch getinfo for block sync"
watch -n 10 'denariusd getinfo'
                ;;
        2)      echo 2 "Installing Denarius FortunaStake Ubuntu 18.04"
echo "Updating linux packages"
sudo apt-get update -y && sudo apt-get upgrade -y

echo "Installing git"
sudo apt install git -y

echo "Installing curl"
sudo apt-get install curl -y

echo "Intalling fail2ban"
sudo apt install fail2ban -y

echo "Installing Firewall"
sudo apt install ufw -y
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 33369/tcp
sudo ufw allow 9999/tcp
sudo ufw logging on
sudo ufw --force enable

echo "Installing PWGEN"
sudo apt-get install -y pwgen

echo "Installing 2G Swapfile"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "Installing Dependencies"
sudo apt-get --assume-yes install git unzip build-essential libdb++-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libgmp-dev libevent-dev autogen automake  libtool

echo "Downgrade libssl-dev"
sudo apt-get install make
wget https://www.openssl.org/source/openssl-1.0.1j.tar.gz
tar -xzvf openssl-1.0.1j.tar.gz
cd openssl-1.0.1j
sudo ./config
sudo make depend
sudo make
sudo make install
sudo ln -sf /usr/local/ssl/bin/openssl `which openssl`
cd ~
openssl version -v

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
OPENSSL_INCLUDE_PATH=/usr/local/ssl/include OPENSSL_LIB_PATH=/usr/local/ssl/lib make -f makefile.unix
sudo mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Populate denarius.conf"
mkdir ~/.denarius
    # Get VPS IP Address
    VPSIP=$(curl ipinfo.io/ip)
    # create rpc user and password
    rpcuser=$(openssl rand -base64 24)
    # create rpc password
    rpcpassword=$(openssl rand -base64 48)
    echo -n "What is your fortunastakeprivkey? (Hint:genkey output)"
    read FORTUNASTAKEPRIVKEY
    echo -e "rpcuser=$rpcuser\nrpcpassword=$rpcpassword\nserver=1\nlisten=1\ndaemon=1\nport=9999\naddnode=denarius.host\naddnode=denarius.win\naddnode=denarius.pro\naddnode=triforce.black\nrpcallowip=127.0.0.1\nexternalip=$VPSIP:9999\nfortunastake=1\nfortunastakeprivkey=$FORTUNASTAKEPRIVKEY" > ~/.denarius/denarius.conf


echo "Get Chaindata"
sudo apt-get -y install unzip
cd ~/.denarius
rm -rf database txleveldb smsgDB
#wget http://d.hashbag.cc/chaindata.zip
#unzip chaindata.zip
wget https://github.com/carsenk/denarius/releases/download/v3.3.7/chaindata1701122.zip
unzip chaindata1612994.zip

echo "Add Daemon Cronjob"
(crontab -l ; echo "@reboot /usr/local/bin/denariusd")| crontab -
#(crontab -l ; echo "0 * * * * /usr/local/bin/denariusd stop")| crontab -
#(crontab -l ; echo "2 * * * * /usr/local/bin/denariusd")| crontab -

echo "Starting Denarius Daemon"
denariusd

echo "Watch getinfo for block sync"
watch -n 10 'denariusd getinfo'
                ;;
        3)      echo 3 "Updating Denarius FortunaStake"
echo "Stop denariusd"
denariusd stop

cd denarius
git checkout master
git pull
cd src
make -f makefile.unix
sudo mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Start denariusd"
denariusd
watch -n 10 'denariusd getinfo'
                ;;
        4)      echo 4 "Watch denariusd getinfo"
                watch -n 10 'denariusd getinfo'
                ;;
esac
echo Selected $choice
