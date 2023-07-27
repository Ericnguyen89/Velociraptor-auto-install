#check OS of host
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "Failed to detect the operating system."
    exit 1
fi
if [[ "$OS" == "ubuntu" ]]; then
    apt-get update -y
    apt-get upgrade -y
elif [[ "$OS" == "centos" ]]; then
    yum update -y
else
    echo "Unsupported operating system."
    exit 1
fi
wget https://github.com/Velocidex/velociraptor/releases/download/v0.6.9/velociraptor-v0.6.9-linux-amd64
mkdir /etc/velociraptor
cp velociraptor-v0.6.9-linux-amd64 /usr/local/bin/velociraptor
sudo chmod +x /usr/local/bin/velociraptor

#start a config generate by velociraptor
echo "
--------------------------------------------
NOTE: remember path of 
1. Path to the logs directory. /opt/velociraptor/logs
2. Server config file? /etc/velociraptor/server.config.yaml
3. The client config file? /etc/velociraptor/client.config.yaml
--> if you not chose this suget, you need remember PATH URL you input to change the value to fix GUI access and something issus by the connect agent-server
--------------------------------------------


"
velociraptor config generate -i

# wite a Services to auto start
echo "[Unit]
Description=Velociraptor linux SERVER amd64
After=syslog.target network.target
[Service]
Type=simple
Restart=always
RestartSec=120
LimitNOFILE=20000
Environment=LANG=en_US.UTF-8
ExecStart=/usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml frontend -v
[Install]
WantedBy=multi-user.target" > /lib/systemd/system/velociraptor.service
sudo systemctl daemon-reload
sudo systemctl enable --now velociraptor

#-------------------------
#Seach config localhost and replace new value of IP
#!/bin/bash

config_file="/etc/velociraptor/server.config.yaml"
service_file="/lib/systemd/system/velociraptor.service"

# Check if the config file exists
if [ -e "$config_file" ]; then
  echo "All Working, please make a status of service to double check and sure not happend"
else
  echo "
  ------------------------
  
  DEFAULT CONFIG OF VELOCIRAPTOR NOT FOUND IN [/etc/velociraptor/server.config.yaml]
  YOU NEED TO CHANGE IT:
  
  "
  
  # Prompt the user for the replacement value
  read -p "Enter the replacement config file value for Velociraptor you input look like [/etc/velociraptor/server.config.yaml]:" replacement
  # Replace the value in the service file
  #sed -i "s|/etc/velociraptor.config.yaml|$replacement|" "$service_file"
  cp $replacement /etc/velociraptor/server.config.yaml
  echo "Complete setup a server system service for Velociraptor, Let start Velociraptor and Enjoy!"
    
fi
echo "Done!......Let We start seaching and replace so missing config"
wget https://raw.githubusercontent.com/Ericnguyen89/Velociraptor-auto-install/main/ip-update.sh && sudo bash ip-update.sh
