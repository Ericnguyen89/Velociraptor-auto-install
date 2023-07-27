get_current_hostname() {
    current_hostname=$(hostname)
    echo "$current_hostname"
}

# Function to update the /etc/hosts file with the current hostname
update_hosts_file() {
    new_hostname="$1"
    if [ -z "$new_hostname" ]; then
        echo "Error: No hostname provided."
        exit 1
    fi

    # Backup the original hosts file
    sudo cp /etc/hosts /etc/hosts.backup

    # Update the hostname in the hosts file
    sudo sed -i "s/^\(127\.0\.1\.1[[:space:]]\+\).*$/\1$new_hostname/" /etc/hosts

    echo "Hostname updated to: $new_hostname"
}

# Main script
current_hostname=$(get_current_hostname)
echo "Current hostname: $current_hostname"

update_hosts_file "$current_hostname"
echo "ĐÃ FIX LỖI HOSTNAME TRONG --> /etc/hosts "
