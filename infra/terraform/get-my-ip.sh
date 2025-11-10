#!/bin/bash
# Script to get your public IP address
# Run this script to get your IP address for terraform.tfvars

echo "Getting your public IP address..."

IP=$(curl -s https://api.ipify.org)

if [ -n "$IP" ]; then
    echo ""
    echo "Your public IP address is: $IP"
    echo ""
    echo "Update terraform.tfvars with:"
    echo "  admin_cidr = \"$IP/32\""
    echo ""
else
    echo "Error getting IP address. Please visit https://whatismyipaddress.com/ to get your IP manually"
fi

