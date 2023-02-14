#!/bin/bash
sudo apt-get update -y
apt-get install apache2 -y
sudo ufw allow 'Apache' 
sudo systemctl start apache2