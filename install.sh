#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
LUNA="https://raw.githubusercontent.com/tp-handler/luna/main/Luna.zip"

APP_NAME="LunaMac"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="$HOME/Desktop/Luna"
INSTALL_DIR="$TARGET_DIR/$APP_NAME"
DOWNLOADED_FILE="$TEMP_DIR/LunaOWO"
ENTITLEMENTS_FILE="$TEMP_DIR/entitlements.plist"

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    printf "\033[?25l"
    while ps -p $pid &>/dev/null; do
        printf "\r${CYAN}[${spinstr:i++%${#spinstr}:1}] ${1}...${NC} "
        sleep $delay
    done
    wait $pid
    local exit_code=$?
    printf "\033[?25h"
    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}[✔] ${1} - Done${NC}   \n"
    else
        printf "\r${RED}[✘] ${1} - Failed${NC}   \n"
        if [[ "$1" == *"Downloading"* ]]; then exit 1; fi
    fi
}

main() {
    clear
    echo -e "${CYAN}Starting installation for ${APP_NAME}...${NC}\n"

    curl -fsSL "$LUNA" -o "$TEMP_DIR/Luna.zip" &
    spinner "Downloading Luna"

    unzip -oq "$TEMP_DIR/Luna.zip" -d "$TEMP_DIR" &
    spinner "Unzipping archive"

    FILE_TYPE=$(file -b "$DOWNLOADED_FILE")
    if [[ "$FILE_TYPE" != *"Mach-O"* ]]; then
         echo -e "\n${RED}[✘] Critical Error: Downloaded file is not a binary program.${NC}"
         echo -e "${YELLOW}File type detected: $FILE_TYPE${NC}"
         rm -rf "$TEMP_DIR"
         exit 1
    fi

    if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "$TARGET_DIR"
    fi

    if [ -d "$INSTALL_DIR" ]; then
        (rm -rf "$INSTALL_DIR") &
        spinner "Removing old version"
    fi
    
    chmod +x "$DOWNLOADED_FILE"
    xattr -cr "$DOWNLOADED_FILE"
    cat > "$ENTITLEMENTS_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.debugger</key>
    <true/>
</dict>
</plist>
EOF
    codesign --force --sign - --entitlements "$ENTITLEMENTS_FILE" "$DOWNLOADED_FILE" 2>/dev/null
    mv "$DOWNLOADED_FILE" "$INSTALL_DIR"
    rm -rf "$TEMP_DIR"

    echo -e "\n${GREEN}✨ Success!${NC}"
    echo -e "${CYAN}You can find it at: $INSTALL_DIR${NC}"
}

main
