#!/bin/bash
# ==============================================
# Install Dependencies for Subenum Project
# ==============================================

echo "[*] Updating system..."
sudo apt update -y
sudo apt install -y amass findomain massdns golang git wget unzip

# Setup GOPATH if not already
if [ -z "$GOPATH" ]; then
    export GOPATH=$HOME/go
    export PATH=$PATH:$GOPATH/bin
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Function to install Go tools
install_tool() {
    if ! command -v $1 &>/dev/null; then
        echo "[*] Installing $1..."
        go install $2@latest
    else
        echo "[*] $1 already installed"
    fi
}

install_tool subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder
install_tool assetfinder github.com/tomnomnom/assetfinder
install_tool chaos github.com/projectdiscovery/chaos-client/cmd/chaos
install_tool gau github.com/lc/gau/v2/cmd/gau
install_tool github-subdomains github.com/gwen001/github-subdomains
install_tool gitlab-subdomains github.com/gwen001/gitlab-subdomains
install_tool cero github.com/glebarez/cero
install_tool anew github.com/tomnomnom/anew
install_tool shosubgo github.com/incogbyte/shosubgo
install_tool httpx github.com/projectdiscovery/httpx/cmd/httpx
install_tool unfurl github.com/tomnomnom/unfurl
install_tool puredns github.com/d3mondev/puredns/v2
install_tool dnsx github.com/projectdiscovery/dnsx/cmd/dnsx

echo "[✔] Installation complete. Now run ./subenum.sh <domain | domains.txt>"
