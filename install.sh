#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

LUNA_URL="https://github.com/tp-handler/luna/releases/latest/download/Luna"

TEMP_DIR=$(mktemp -d)
TARGET_DIR="/Applications"
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
        printf "\r${GREEN}[✔] ${1} - Done${NC}    \n"
    else
        printf "\r${RED}[✘] ${1} - Failed${NC}    \n"
        exit 1
    fi
}

main() {
    clear
    echo -e "${CYAN}Starting installation...${NC}\n"

    if [ -w "/Applications" ]; then
        TARGET_DIR="/Applications"
    else
        TARGET_DIR="$HOME/Applications"
    fi

    mkdir -p "$TARGET_DIR"

    curl -fsSL "$LUNA_URL" -o "$TEMP_DIR/Luna" &
    spinner "Downloading latest Luna release"

    INSTALL_PATH="$TARGET_DIR/Luna"

    (
        mv "$TEMP_DIR/Luna" "$INSTALL_PATH"
        chmod +x "$INSTALL_PATH"
    ) &
    spinner "Installing binary"

    cat > "$ENTITLEMENTS_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.get-task-allow</key>
    <true/>
    <key>com.apple.security.cs.debugger</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
</dict>
</plist>
EOF

    (
        xattr -cr "$INSTALL_PATH"
        codesign --force --options runtime --sign - --entitlements "$ENTITLEMENTS_FILE" "$INSTALL_PATH"
    ) &
    spinner "Finalizing & Securing app"

    rm -rf "$TEMP_DIR"
    echo -e "\n${GREEN}✨ Success!${NC}"
    echo -e "${CYAN}Installed to: $INSTALL_PATH${NC}"
}

main
