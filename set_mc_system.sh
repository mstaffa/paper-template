#!/bin/bash

echo "-----------------------------------------"
echo "- Installing prerequisite packages      -"
echo "-----------------------------------------"

apt-get install -y openjdk-11-jre-headless curl screen nano bash grep

echo "-----------------------------------------"
echo "- Create /opt                           -"
echo "-----------------------------------------"

mkdir /opt

echo "-----------------------------------------"
echo "- Add minecraft user and configure home -"
echo "-----------------------------------------"

adduser --system --shell /bin/bash --home /opt/minecraft --group minecraft
chmod +t /opt/minecraft

echo "-----------------------------------------"
echo "- Curl unit file into systemd/system    -"
echo "-----------------------------------------"

cp ./minecraft@.service /etc/systemd/system/
#curl https://raw.githubusercontent.com/agowa338/MinecraftSystemdUnit/master/minecraft%40.service > /etc/systemd/system/minecraft@.service

echo "-----------------------------------------"
echo "- Append credit to unit file            -"
echo "-----------------------------------------"

echo '# This unit file is created and maintained in the following Github repo and is used as-is with no guarantees' >> /etc/systemd/system/minecraft@.service
echo '# https://github.com/agowa338/MinecraftSystemdUnit' >> /etc/systemd/system/minecraft@.service
