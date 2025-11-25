#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
DYLIB_URL="https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/libSystem.zip"
MODULES_URL="https://raw.githubusercontent.com/Savage3991/superpoop/refs/heads/main/Resources.zip"

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while ps -p $pid &>/dev/null; do
        printf "\r${CYAN}[${spinstr:i++%${#spinstr}:1}] ${1}...${NC} "
        sleep $delay
    done
    wait $pid 2>/dev/null
    printf "\r${GREEN}[*] ${1} - done${NC}\n"
}

main() {
    clear
    spinner "Installing luna."
    
}

main
