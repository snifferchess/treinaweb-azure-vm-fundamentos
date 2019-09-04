#!/usr/bin/env sh

set -x

# instalar o nginx via apt-get
sudo apt-get update
sudo apt-get install nginx -y

# adicionar permissão de leitura para todos nos logs do Nginx
sudo chmod +r /var/log/nginx/*
