# SupEnum – Powerful Subdomain Enumeration Toolkit

## Features
- Supports **single domain** or **list of domains**
- Uses multiple tools:
  - Amass, Subfinder, Assetfinder, Findomain
  - Chaos, Gau, GitHub-Subdomains, GitLab-Subdomains
  - Shosubgo, Cero, DNSX, HTTPX
- Organizes results per domain in `results/domain.com/`

## Installation
```bash
git clone https://github.com/texech/supenum.git
cd supenum
chmod +x install.sh check_deps.sh supenum.sh
./install.sh
```
## Usage
Single domain
```bash
./supenum.sh example.com
```
Multiple domains
```bash
./supenum.sh domains.txt
```
## API Keys
```bash
nano apikeys.sh
```
Add Your Keys
```bash
export SHODAN_API_KEY="your_key"
export CENSYS_API_ID="your_id"
export CENSYS_API_SECRET="your_secret"
export CHAOS_KEY="your_key"
export GITHUB_TOKEN="your_github_token"
export GITLAB_TOKEN="your_gitlab_token"
```
