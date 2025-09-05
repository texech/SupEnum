#!/bin/bash
set -euo pipefail

# ----------------------------
# Configuration
# ----------------------------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS="$ROOT/results"
mkdir -p "$RESULTS"

# Load API keys if exists
API_FILE="$ROOT/api_keys.sh"
if [[ -f "$API_FILE" ]]; then
    source "$API_FILE"
else
    echo "[*] No API keys file found. Some tools (Shodan, Censys, Chaos) may not work."
fi

# ----------------------------
# Input
# ----------------------------
if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 <domain|domains.txt>"
    exit 1
fi

TARGET=$1
DOMAINS=()
if [[ -f "$TARGET" ]]; then
    mapfile -t DOMAINS < "$TARGET"
else
    DOMAINS+=("$TARGET")
fi

# ----------------------------
# Start enumeration
# ----------------------------
for domain in "${DOMAINS[@]}"; do
    BASE=$(echo "$domain" | sed -E 's#https?://##; s#/.*$##' | tr '[:upper:]' '[:lower:]')
    OUTDIR="$RESULTS/$BASE"
    mkdir -p "$OUTDIR/live" "$OUTDIR/403" "$OUTDIR/404" "$OUTDIR/wayback/params" "$OUTDIR/wayback/noparams" "$OUTDIR/resolved"

    echo "[*] Enumerating subdomains for $BASE"

    # ----------------------------
    # 1. Subdomain discovery
    # ----------------------------
    subfinder -d "$BASE" -silent > "$OUTDIR/subfinder.txt" 2>/dev/null || true
    amass enum -passive -d "$BASE" > "$OUTDIR/amass.txt" 2>/dev/null || true
    assetfinder --subs-only "$BASE" > "$OUTDIR/assetfinder.txt" 2>/dev/null || true
    findomain -t "$BASE" -q > "$OUTDIR/findomain.txt" 2>/dev/null || true

    # Optional API tools
    if [[ -n "${SHODAN_API_KEY:-}" ]]; then
        echo "[*] Running Shodan API enrichment..."
        shodan host "$BASE" --fields ip_str,org,ports > "$OUTDIR/shodan_info.txt" 2>/dev/null || true
    fi

    if [[ -n "${CENSYS_API_ID:-}" && -n "${CENSYS_API_SECRET:-}" ]]; then
        echo "[*] Running Censys API enrichment..."
        curl -s -u "$CENSYS_API_ID:$CENSYS_API_SECRET" \
            "https://search.censys.io/api/v2/hosts/search?q=$BASE" > "$OUTDIR/censys_info.json" || true
    fi

    cat "$OUTDIR/"*.txt | sort -u > "$OUTDIR/all_subs.txt"

    # ----------------------------
    # 2. Resolve subdomains (massdns/puredns/dnsx)
    # ----------------------------
    if command -v puredns >/dev/null 2>&1; then
        puredns resolve "$OUTDIR/all_subs.txt" --quiet --threads 100 | sort -u > "$OUTDIR/resolved/valid_subs.txt"
    else
        # Fallback: httpx resolution
        httpx -l "$OUTDIR/all_subs.txt" -silent -status-code -threads 100 -o "$OUTDIR/resolved/valid_subs_temp.txt"
        awk '$2==200{print $1}' "$OUTDIR/resolved/valid_subs_temp.txt" | sort -u > "$OUTDIR/resolved/valid_subs.txt"
    fi

    # ----------------------------
    # 3. HTTP Probing & status categorization
    # ----------------------------
    httpx -l "$OUTDIR/resolved/valid_subs.txt" -silent -status-code -threads 100 -o "$OUTDIR/probe_results.txt"

    awk '$2==200{print $1}' "$OUTDIR/probe_results.txt" | sort -u > "$OUTDIR/live/live.txt"
    awk '$2==403{print $1}' "$OUTDIR/probe_results.txt" | sort -u > "$OUTDIR/403/403.txt"
    awk '$2==404{print $1}' "$OUTDIR/probe_results.txt" | sort -u > "$OUTDIR/404/404.txt"

    echo "[+] Live: $(wc -l < "$OUTDIR/live/live.txt")"
    echo "[+] 403: $(wc -l < "$OUTDIR/403/403.txt")"
    echo "[+] 404: $(wc -l < "$OUTDIR/404/404.txt")"

    # ----------------------------
    # 4. Wayback/Gau URL extraction
    # ----------------------------
    gau "$BASE" --threads 50 2>/dev/null | tee "$OUTDIR/wayback/all.txt" | \
    while read -r url; do
        if [[ "$url" == *"="* ]]; then
            echo "$url" >> "$OUTDIR/wayback/params/urls.txt"
        else
            echo "$url" >> "$OUTDIR/wayback/noparams/urls.txt"
        fi
    done

    echo "[+] Wayback URLs with params: $(wc -l < "$OUTDIR/wayback/params/urls.txt")"
    echo "[+] Wayback URLs without params: $(wc -l < "$OUTDIR/wayback/noparams/urls.txt")"

done
