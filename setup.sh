#!/bin/bash

# ================================================================
# setup.sh
# Predictive Maintenance for Robot Motors — Environment Setup
# ================================================================
# This script will:
#   1. Detect your OS (Linux / macOS / Windows via Git Bash)
#   2. Install Arduino CLI
#   3. Add the ESP32 board support package
#   4. Install all required Arduino libraries
#   5. Verify the installation
#
# Compatible with: Linux, macOS, Windows (Git Bash / WSL)
# ================================================================

set -e  # Exit immediately if any command fails

# ── Colours for output ──────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Colour

echo ""
echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}   Predictive Maintenance for Robot Motors — Setup Script      ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# ── Step 1: Detect Operating System ─────────────────────────────
echo -e "${YELLOW}[Step 1/5] Detecting operating system...${NC}"

OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo -e "${GREEN}  → Detected: Linux${NC}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo -e "${GREEN}  → Detected: macOS${NC}"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
    echo -e "${GREEN}  → Detected: Windows (Git Bash / WSL)${NC}"
else
    echo -e "${RED}  ✗ Could not detect OS. Please follow manual setup in SETUP.md${NC}"
    exit 1
fi

echo ""

# ── Step 2: Install Arduino CLI ──────────────────────────────────
echo -e "${YELLOW}[Step 2/5] Installing Arduino CLI...${NC}"

ARDUINO_CLI_DIR="$HOME/.arduino-cli"
ARDUINO_CLI_BIN="$ARDUINO_CLI_DIR/arduino-cli"

if command -v arduino-cli &> /dev/null; then
    echo -e "${GREEN}  → Arduino CLI is already installed: $(arduino-cli version)${NC}"
    ARDUINO_CLI="arduino-cli"
elif [ -f "$ARDUINO_CLI_BIN" ]; then
    echo -e "${GREEN}  → Arduino CLI found at $ARDUINO_CLI_BIN${NC}"
    ARDUINO_CLI="$ARDUINO_CLI_BIN"
    export PATH="$ARDUINO_CLI_DIR:$PATH"
else
    echo "  → Downloading and installing Arduino CLI..."
    mkdir -p "$ARDUINO_CLI_DIR"

    if [[ "$OS" == "linux" ]]; then
        ARDUINO_CLI_URL="https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz"
    elif [[ "$OS" == "macos" ]]; then
        ARDUINO_CLI_URL="https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_macOS_64bit.tar.gz"
    elif [[ "$OS" == "windows" ]]; then
        ARDUINO_CLI_URL="https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Windows_64bit.zip"
    fi

    TMPFILE=$(mktemp)

    if [[ "$OS" == "windows" ]]; then
        curl -fsSL "$ARDUINO_CLI_URL" -o "${TMPFILE}.zip"
        unzip -o "${TMPFILE}.zip" -d "$ARDUINO_CLI_DIR"
        rm -f "${TMPFILE}.zip"
    else
        curl -fsSL "$ARDUINO_CLI_URL" -o "${TMPFILE}.tar.gz"
        tar -xzf "${TMPFILE}.tar.gz" -C "$ARDUINO_CLI_DIR"
        rm -f "${TMPFILE}.tar.gz"
    fi

    chmod +x "$ARDUINO_CLI_BIN"
    ARDUINO_CLI="$ARDUINO_CLI_BIN"
    export PATH="$ARDUINO_CLI_DIR:$PATH"
    echo -e "${GREEN}  ✓ Arduino CLI installed successfully.${NC}"
fi

echo ""

# ── Step 3: Initialize Arduino CLI config ────────────────────────
echo -e "${YELLOW}[Step 3/5] Configuring Arduino CLI and adding ESP32 board...${NC}"

# Add ESP32 board manager URL
$ARDUINO_CLI config init --overwrite 2>/dev/null || true
$ARDUINO_CLI config add board_manager.additional_urls \
    https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

echo "  → Updating board index (this may take a minute)..."
$ARDUINO_CLI core update-index

echo "  → Installing ESP32 board support package..."
$ARDUINO_CLI core install esp32:esp32

echo -e "${GREEN}  ✓ ESP32 board support installed.${NC}"
echo ""

# ── Step 4: Install Required Arduino Libraries ───────────────────
echo -e "${YELLOW}[Step 4/5] Installing required Arduino libraries...${NC}"

install_lib() {
    local LIB_NAME="$1"
    echo "  → Installing: $LIB_NAME"
    $ARDUINO_CLI lib install "$LIB_NAME"
}

install_lib "Adafruit MPU6050"
install_lib "Adafruit Unified Sensor"
install_lib "DHT sensor library"
install_lib "Adafruit BusIO"

# Built-in libraries (WiFi, WebServer, Wire) come with ESP32 core
echo -e "${GREEN}  ✓ Note: WiFi, WebServer, and Wire are built-in with ESP32 core.${NC}"
echo -e "${GREEN}  ✓ All libraries installed successfully.${NC}"
echo ""

# ── Step 5: Verify Installation ───────────────────────────────────
echo -e "${YELLOW}[Step 5/5] Verifying installation...${NC}"

echo "  → Installed boards:"
$ARDUINO_CLI board listall | grep -i esp32 | head -5

echo ""
echo "  → Installed libraries:"
$ARDUINO_CLI lib list | grep -E "Adafruit|DHT"

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}  ✓ Setup Complete!                                             ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open Arduino IDE"
echo "  2. Go to File → Open → select the .ino file from the codes/ folder"
echo "  3. Select Board: Tools → Board → esp32 → ESP32 Dev Module"
echo "  4. Select Port: Tools → Port → (your ESP32 COM port)"
echo "  5. Click Upload"
echo ""
echo "  For more details, see SETUP.md in this repository."
echo ""
