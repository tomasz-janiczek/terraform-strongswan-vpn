#!/bin/bash

# This simple scripts does a few checks for a valida strongSwan IPSec-based VPN connection
# It will also auto-detect if the connection uses ESP-in-UDP

TARGET=$1

IKE_OK=$(ipsec statusall | grep -i "^Security Associations (1 up,.*)")
ESP_IN_UDP=$(ipsec statusall | grep "ESP in UDP")

if [ ! "$TARGET" ]; then
    echo "Usage: $0 <IP-address-of-a-host-in-the-target-network>"
    exit 1
fi

echo -e "\n---===[ Testing the strongSwan VPN connection ]===---"

# Check the IKE connection
if [ "$IKE_OK" ]; then
    echo -n "1. IKE connection: OK "

    if [ "$ESP_IN_UDP" ]; then
        echo -n "(detected ESP-in-UDP mode)"
    fi

    echo -ne "\n"
else
    echo "1. ERROR! IKE connection is DOWN!"
    exit 1
fi

# Check outgoing ESP data
if [ "ESP_IN_UDP" ]; then
    TCPDUMP_RULE="udp and port 4500"
else
    TCPDUMP_RULE="esp"
fi

timeout 5s ping $TARGET >/dev/null &
RESULT=$(timeout 5s tcpdump $TCPDUMP_RULE 2>/dev/null)
wait

if [ "$RESULT" ]; then
    echo "2. ESP connection: OK"
else
    echo "2. ERROR! ESP connection is DOWN!"
    exit 1
fi

# Check ping (routing / connectivity)
RESULT=$(timeout 5s ping $TARGET >/dev/null)

if [ "$RESULT" ]; then
    echo "3. Ping response: OK"
else
    echo -e "3. ERROR! No ping response from the target host!\n"
    exit 1
fi

echo -e "\n"
