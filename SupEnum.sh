#!/bin/bash
# ==========================================================
# Subdomain Enumeration Automation Script
# Author: Texech
# ==========================================================

banner() {
cat << "EOF"

   ███████╗██╗   ██╗██████╗ ███████╗███╗   ██╗██╗   ██╗███╗   ███╗
   ██╔════╝██║   ██║██╔══██╗██╔════╝████╗  ██║██║   ██║████╗ ████║
   ███████╗██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║   ██║██╔████╔██║
   ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║   ██║██║╚██╔╝██║
   ███████║╚██████╔╝██║     ███████╗██║ ╚████║╚██████╔╝██║ ╚═╝ ██║
   ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝
            Subdomain Enumeration Toolkit - by Texech

EOF
}


if [ -z "$1" ]; then
    echo "Usage: $0 <domain.com | domains.txt>"
    exit 1
fi

INPUT=$1
BASEDIR="results"
mkdir -p $BASEDIR

# Load API keys
if [[ -f "apikeys.sh" ]]; then
    source apikeys.sh
    echo "[*] API keys loaded from apikeys.sh"
else
    echo "[!] No apikeys.sh found, some tools may not work fully"
fi

enumerate_domain() {
    DOMAIN=$1
    OUTDIR="$BASEDIR/$DOMAIN"
    mkdir -p $OUTDIR

    echo -e "\n[+] Enumerating: $DOMAIN"
    echo "[*] Output -> $OUTDIR"

    subfinder -d $DOMAIN -all -silent | anew $OUTDIR/subdomains.txt
    amass enum -d $DOMAIN -o $OUTDIR/amass.txt
    cat $OUTDIR/amass.txt | anew $OUTDIR/subdomains.txt
    assetfinder --subs-only $DOMAIN | anew $OUTDIR/subdomains.txt
    findomain -t $DOMAIN -q | anew $OUTDIR/subdomains.txt
    chaos -d $DOMAIN -silent | anew $OUTDIR/subdomains.txt
    cero $DOMAIN | anew $OUTDIR/subdomains.txt
    github-subdomains -d $DOMAIN | anew $OUTDIR/subdomains.txt
    gitlab-subdomains -d $DOMAIN | anew $OUTDIR/subdomains.txt
    shosubgo -d $DOMAIN | anew $OUTDIR/subdomains.txt
    gau $DOMAIN | unfurl -u domains | anew $OUTDIR/subdomains.txt

    cat $OUTDIR/subdomains.txt | dnsx -silent -resp | anew $OUTDIR/resolved.txt
    cat $OUTDIR/resolved.txt | httpx -silent | anew $OUTDIR/live.txt

    sort -u $OUTDIR/subdomains.txt -o $OUTDIR/subdomains.txt
    echo "[+] $DOMAIN → $(wc -l < $OUTDIR/subdomains.txt) subdomains"
}

if [[ -f "$INPUT" ]]; then
    echo "[*] Multiple domains mode"
    while read -r domain; do
        [ -n "$domain" ] && enumerate_domain "$domain"
    done < "$INPUT"
else
    echo "[*] Single domain mode"
    enumerate_domain "$INPUT"
fi
