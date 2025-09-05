#!/bin/bash
# ==========================================
# Check if all dependencies are installed
# ==========================================

TOOLS=(
    "amass"
    "findomain"
    "massdns"
    "subfinder"
    "assetfinder"
    "chaos"
    "gau"
    "github-subdomains"
    "gitlab-subdomains"
    "cero"
    "anew"
    "shosubgo"
    "httpx"
    "unfurl"
    "puredns"
    "dnsx"
)

echo "[*] Checking required tools..."

MISSING=0
for tool in "${TOOLS[@]}"; do
    if ! command -v $tool &>/dev/null; then
        echo "[-] $tool is NOT installed"
        ((MISSING++))
    else
        echo "[+] $tool is installed"
    fi
done

if [ $MISSING -eq 0 ]; then
    echo "[✔] All dependencies are installed!"
else
    echo "[!] $MISSING tools are missing. Run ./install.sh to install them."
fi

# Check API keys file
if [[ -f "apikeys.sh" ]]; then
    echo "[*] Found apikeys.sh"
else
    echo "[!] apikeys.sh not found. Create it and add your API keys."
fi
