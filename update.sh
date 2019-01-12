#!/bin/bash

echo "Stop denariusd"
denariusd stop

cd denarius
git checkout v3.4
git pull
cd src
make -f makefile.unix
sudo mv ~/denarius/src/denariusd /usr/local/bin/denariusd

echo "Start denariusd"
denariusd
watch -n .1 './denariusd getinfo'
