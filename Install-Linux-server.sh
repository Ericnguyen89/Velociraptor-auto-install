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
mkdir /usr/local/bin/velociraptor
cp velociraptor-v0.6.9-linux-amd64 /usr/local/bin/velociraptor
sudo chmod +x /usr/local/bin/velociraptor

#start a config generate by velociraptor
echo "
--------------------------------------------
NOTE: remember path of 
1. Path to the logs directory. /opt/velociraptor/logs
2. Server config file? /etc/velociraptor.config.yaml
3. The client config file? /etc/client.config.yaml
--> if you not chose this suget, you need remember PATH URL you input to change the value to fix GUI access and something issus by the connect agent-server
--------------------------------------------


"
velociraptor config generate -i

# wite a Services to auto start
echo "[Unit]
Description=Velociraptor linux amd64
After=syslog.target network.target
[Service]
Type=simple
Restart=always
RestartSec=120
LimitNOFILE=20000
Environment=LANG=en_US.UTF-8
ExecStart=/usr/local/bin/velociraptor --config /etc/velociraptor.config.yaml frontend -v
[Install]
WantedBy=multi-user.target " > /lib/systemd/system/velociraptor.service
sudo systemctl daemon-reload
sudo systemctl enable --now velociraptor
#-----------------------------------------------
# seaching config of velociraptor server to double check after start services
#!/bin/bash

config_file="/etc/velociraptor.config.yaml"
service_file="/lib/systemd/system/velociraptor.service"

# Check if the config file exists
if [ -e "$config_file" ]; then
  echo "Config file already exists."
else
  echo "
  ------------------------
  
  DEFAULT CONFIG OF VELOCIRAPTOR NOT FOUND IN [/etc/velociraptor.config.yaml]"
  
  # Prompt the user for the replacement value
  read -p "Enter the replacement file value for /etc/velociraptor.config.yaml: " replacement
  
  # Replace the value in the service file
  sed -i "s|/etc/velociraptor.config.yaml|$replacement|" "$service_file"
  
  echo "Replacement complete."
fi

