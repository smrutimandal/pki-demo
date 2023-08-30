#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade -yq
apt install -yq \
    curl git nginx openssl vim
