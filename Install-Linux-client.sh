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
#---------------check folder------------
folder="/etc/velociraptor"

if [ -d "$folder" ]; then
  echo "Folder $folder exists. Deleting..."
  rm -rf "$folder"
  echo " ---> Folder Clean!!!"
else
  mkdir /etc/velociraptor
  echo "Folder $folder never exist, Create it."
fi

cp velociraptor-v0.6.9-linux-amd64 /usr/local/bin/velociraptor
sudo chmod +x /usr/local/bin/velociraptor
#write a service to start Velociraptor client
echo "[Unit]
Description=Velociraptor linux amd64
After=syslog.target network.target
[Service]
Type=simple
Restart=always
RestartSec=120
LimitNOFILE=20000
Environment=LANG=en_US.UTF-8
ExecStart=/usr/local/bin/velociraptor --config /etc/velociraptor/client.config.yaml client -v
[Install]
WantedBy=multi-user.target" > /lib/systemd/system/velociraptor-client.service
echo "
----------------------------------------------------------------------------------------------
--> YOU NEED HAVE DOWNLOAD Client.config.yaml FROM SERVER FIST YOU START THIS SETUP <---

----------------------------------------------------------------------------------------------"
config_file="/etc/velociraptor/client.config.yaml"
service_file="/lib/systemd/system/velociraptor-client.service"

# Check if the config file exists
if [ -e "$config_file" ]; then
  echo "All Working, please make a status of service to double check and sure not happend"
  
else
  echo "
  ------------------------
  
  DEFAULT CONFIG OF VELOCIRAPTOR CLIENT NOT FOUND IN [/etc/velociraptor/client.config.yaml]
  YOU NEED TO UPDATE IT:
  
  "
  
  # Prompt the user for the replacement value
  read -p "Enter the replacement config file value for Velociraptor client file you download look like [/etc/velociraptor/client.config.yaml]:" replacement
  
  
  # Replace the value in the service file
  #sed -i "s|/etc/velociraptor/client.config.yaml|$replacement|" "$service_file"
  cp $replacement /etc/velociraptor/client.config.yaml
  echo "Complete setup a server system service for Velociraptor, Let's start Velociraptor and Enjoy!"
  sudo systemctl restart velociraptor-client  
fi
