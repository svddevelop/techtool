#!/bin/bash

# Path to the file
FILE="/usr/bin/down_can0.sh"

# New content to write to the file
NEW_CONTENT="
#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <SSID> <PASSPHRASE>"
    exit 1
fi

SSID=$1
PASSPHRASE=$2
CLIENT_INTERFACE="wlan0"

sudo killall wpa_supplicant

sudo tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null <<EOL
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=GB

network={
    ssid="$SSID"
    psk="$PASSPHRASE"
}
EOL

sudo wpa_supplicant -B -i $CLIENT_INTERFACE -c /etc/wpa_supplicant/wpa_supplicant.conf
sudo dhclient $CLIENT_INTERFACE

IP_ADDRESS=$(ip -4 addr show $CLIENT_INTERFACE | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "Connected to $SSID. IP address: $IP_ADDRESS"
"
touch $FILE

# Check if the file exists
if [ -f "$FILE" ]; then
    # Overwrite the file with new content
    echo "$NEW_CONTENT" > "$FILE"
    chmod +x $FILE
    echo "File $FILE has been successfully updated."
else
    echo "File $FILE not found."
    exit 1
fi
