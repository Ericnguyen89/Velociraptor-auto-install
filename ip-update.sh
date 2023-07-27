#!/bin/bash
echo "
-------------------------------------------------
We seaching localhost ip on /etc/velociraptor.config.yaml and replace to ip of interface you want 
That make fix error of access GUI on port 8889 and connect from agent to server Velociraptor via 8000
-------------------------------------------------


"
# Read the file content
file_path="/etc/velociraptor/server.config.yaml"
file_content=$(cat "$file_path")

# Find occurrences of '127.0.0.1' in the file
ip_count=$(grep -c '127.0.0.1' "$file_path")

if [ "$ip_count" -eq 0 ]; then
  echo "No occurrences of '127.0.0.1' found in the file."
  echo "There is no value to replace."
else
  # Generate IP addresses for selection
  ip_addresses=($(hostname -I))
  ip_count=${#ip_addresses[@]}

  echo "Select the IP address to replace '127.0.0.1':"

  # Print IP addresses with corresponding numbers
  for ((i=0; i<ip_count; i++)); do
    echo "$(($i+1)). ${ip_addresses[$i]}"
  done

  # Read the user's choice
  read -p "Enter the number of the IP address to use (1-$ip_count): " choice

  if [[ $choice =~ ^[1-$ip_count]$ ]]; then
    # Replace '127.0.0.1' with the chosen IP address
    new_ip="${ip_addresses[$(($choice-1))]}"
    updated_content="${file_content//127.0.0.1/$new_ip}"

    # Write the updated content back to the file
    echo "$updated_content" > "$file_path"
    sudo systemctl restart velociraptor.service
    echo "Value replaced successfully and you can access to GUI web "
  else
    echo "Invalid choice. No changes were made."
  fi
fi 
