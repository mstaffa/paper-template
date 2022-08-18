#!/bin/bash

if [[ $(whoami) != 'root' ]]
then
  echo "Script needs to be run as root..."
  exit 1
fi

printf 'Do you want to install [PaperMC] or [Velocity] Proxy service?: '
read choice

printf 'Do you want to auto-start the selected service? yes / [no]: '
read autostart

choice="$(echo $choice | tr '[:upper:]' '[:lower:]')"
autostart="$(echo $autostart | tr '[:upper:]' '[:lower:]')"

user_dir='/opt/minecraft'

if [[ $choice == 'papermc' ]]
then
  unit_name='minecraft@.service'
  server_dir="$user_dir/paper-server"

elif [[ $choice == 'velocity' ]]
then
  unit_name='velocity@.service'
  server_dir="$user_dir/velocity-proxy"

else
  echo "Invalid option '$choice'"
  exit 0
fi

if [[ $autostart == '' ]]
then
  autostart='no'
fi

echo "-----------------------------------------"
echo "- Installing prerequisite packages      -"
echo "-----------------------------------------"

apt-get install -y openjdk-17-jre-headless curl screen nano bash grep

echo "-----------------------------------------"
echo "- Create /opt if it doesn't exit        -"
echo "-----------------------------------------"

if [[ ! -d /opt ]]; then mkdir /opt; fi

echo "-----------------------------------------"
echo "- Add minecraft user and configure home -"
echo "-----------------------------------------"

adduser --system --shell /bin/bash --home $user_dir --group minecraft
chmod +t $user_dir

echo "-----------------------------------------"
echo "- Generate server directory and pull jar-"
echo "-----------------------------------------"

# Create base server directory and set ownership
if [[ ! -d $server_dir ]]
then
  mkdir $server_dir
  chown minecraft: $server_dir
fi

# Download proper file and set ownership
if [[ $choice == 'papermc' ]]
then
  wget https://api.papermc.io/v2/projects/paper/versions/1.19.2/builds/131/downloads/paper-1.19.2-131.jar -P $server_dir/paper-1.19.2-131.jar
  chown minecraft: $server_dir/paper-1.19.2-131.jar
  
elif [[ $choice == 'velocity' ]]
then
  wget https://api.papermc.io/v2/projects/velocity/versions/3.1.2-SNAPSHOT/builds/175/downloads/velocity-3.1.2-SNAPSHOT-175.jar -P $server_dir/velocity-3.1.2-175.jar
  chown minecraft: $server_dir/velocity-3.1.2-175.jar

fi

# No EULA agreement is required for the velocity proxy
if [[ $choice == 'papermc' ]]
then
  echo "-----------------------------------------"
  echo "- Populate EULA                         -"
  echo "-----------------------------------------"

  touch $server_dir/eula.txt
  cat <<EOF >> $server_dir/eula.txt
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
#$(date)
eula=true
EOF
  chown minecraft: $server_dir/eula.txt
  
fi

echo "-----------------------------------------"
echo "- Populate resource file                 -"
echo "-----------------------------------------"

if [[ $choice == 'papermc' ]]
then
  touch $server_dir/server.conf
  echo 'MCMINMEM=512M' >> $server_dir/server.conf
  echo 'MCMAXMEM=2048M' >> $server_dir/server.conf
  
  chown minecraft: $server_dir/server.conf

elif [[ $choice == 'velocity' ]]
then
  touch $server_dir/proxy.conf
  echo 'VPMINMEM=512M' >> $server_dir/proxy.conf
  echo 'VPMAXMEM=2048M' >> $server_dir/proxy.conf
  
  chown minecraft: $server_dir/proxy.conf
fi

echo "-----------------------------------------"
echo "- Copy unit file into systemd/system    -"
echo "-----------------------------------------"

cp ./$unit_name /etc/systemd/system/

echo "-----------------------------------------"
echo "- Append credit to unit file            -"
echo "-----------------------------------------"

echo '# This unit file is created and maintained in the following Github repo and is used as-is with no guarantees' >> /etc/systemd/system/$unit_name
echo '# https://github.com/agowa338/MinecraftSystemdUnit' >> /etc/systemd/system/$unit_name

if [[ $autostart != 'no' ]]
then
  echo "-----------------------------------------"
  echo "- Autostart + Enable Service            -"
  echo "-----------------------------------------"

  if [[ $choice == 'papermc' ]]
  then
    systemtl enable --now minecraft@paper-server
  
  elif [[ $choice == 'velocity' ]]
  then
    systemctl enable --now velocity@velocity-proxy
  fi
fi

echo
echo
echo '-----------------------------------------------------------------------------------'
echo 'Complete'
echo '-----------------------------------------------------------------------------------'
  
  
