wget https://raw.githubusercontent.com/Ericnguyen89/Velociraptor-auto-install/main/fix-hostname.sh && bash fix-hostname.sh
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
else
    echo "Failed to detect the operating system."
    exit 1
fi
if [[ "$OS" == "ubuntu" ]]; then
    apt-get update -y
elif [[ "$OS" == "centos" ]]; then
    yum update -y
else
    echo "Unsupported operating system."
    exit 1
fi
# ---- Automatic download lastest version of Velociraptor -----
#wget https://github.com/Velocidex/velociraptor/releases/download/v0.6.9/velociraptor-v0.6.9-linux-amd64
URL1="https://github.com/Velocidex/velociraptor/releases/latest/download/velociraptor-linux-amd64"
TARGET_DIR1="/tmp"
wget -q --show-progress -O "$TARGET_DIR1/velociraptor" "$URL1"
echo "Velociraptor downloaded successfully to $TARGET_DIR1"
#---------------check folder------------
folder="/etc/velociraptor"
if [ -d "$folder" ]; then
  echo "Folder $folder exists. Deleting..."
  rm -rf "$folder"
  mkdir /etc/velociraptor
  echo " ---> Folder Cleaned!!!"
else
  mkdir /etc/velociraptor
  echo "Folder $folder Created and ready to install continue."
fi
#delete old file velociraptor
#!/bin/bash
file_velo="/usr/local/bin/velociraptor"
if [ -e "$file_velo" ]; then
    echo "File $file_velo exists. Updating to new version..."
    rm "$file_velo"
    echo "File $file_velo removed"
    echo "Start creating services binary of Velociraptor."
    cp $TARGET_DIR1/velociraptor /usr/local/bin/velociraptor
    sudo chmod +x /usr/local/bin/velociraptor
    echo "File $file_velo Updated to new version."
else
    echo "Start creating services binary of Velociraptor."
    cp $TARGET_DIR1/velociraptor /usr/local/bin/velociraptor
    sudo chmod +x /usr/local/bin/velociraptor
    echo "File $file_velo Has been ready."
fi
#write a service to start Velociraptor client
rm -f /lib/systemd/system/velociraptor-client.service
echo "[Unit]
Description=Velociraptor CLIENT linux amd64
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
  read -p "NHẬP VÀO ĐƯỜNG DẪN FILE CLIENT CONFIG ĐÃ TẢI VỀ, ví dụ [/tmp/client.config.yaml]:" replacement
  # Replace the value in the service file
  #sed -i "s|/etc/velociraptor/client.config.yaml|$replacement|" "$service_file"
  cp $replacement /etc/velociraptor/client.config.yaml
  echo "Complete setup a server system service for Velociraptor, Let's start Velociraptor and Enjoy!"
  sudo systemctl daemon-reload
  sudo systemctl restart velociraptor-client  
fi
