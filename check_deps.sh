#!/bin/bash
set -euo pipefail

sudo apt update && sudo apt install -y wget curl git unzip jq python3 python3-pip

# Go tools
GO111MODULE=on go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
GO111MODULE=on go install github.com/tomnomnom/assetfinder@latest
GO111MODULE=on go install github.com/projectdiscovery/httpx/cmd/httpx@latest
GO111MODULE=on go install github.com/lc/gau/v2/cmd/gau@latest

# Native tools
sudo apt install -y amass ffuf cewl

# findomain
wget https://github.com/findomain/findomain/releases/latest/download/findomain-linux -O findomain
chmod +x findomain
sudo mv findomain /usr/local/bin/

# Optional DNS tools
sudo apt install -y massdns
go install github.com/projectdiscovery/puredns/v2/cmd/puredns@latest
go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest
