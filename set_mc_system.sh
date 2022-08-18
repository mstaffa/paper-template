#!/bin/bash

if [[ $(whoami) != 'root' ]]
then
  echo "Script needs to be run as root..."
  exit 1
fi

printf 'Do you want to install PaperMC or Velocity Proxy service?: '
read choice

choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

if [[ $choice == 'papermc' ]]
then
  unit_name='minecraft@.service'

elif [[ $choice == 'velocity' ]]
then
  unit_name='velocity@.service'

else
  echo "Invalid option '$choice'"
  exit 0
fi

echo "-----------------------------------------"
echo "- Installing prerequisite packages      -"
echo "-----------------------------------------"

apt-get install -y openjdk-17-jre-headless curl screen nano bash grep

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

cp ./$unit_name /etc/systemd/system/

echo "-----------------------------------------"
echo "- Append credit to unit file            -"
echo "-----------------------------------------"

echo '# This unit file is created and maintained in the following Github repo and is used as-is with no guarantees' >> /etc/systemd/system/$unit_name
echo '# https://github.com/agowa338/MinecraftSystemdUnit' >> /etc/systemd/system/$unit_name
