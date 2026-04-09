@echo off
:: ============================================================
:: Predictive Maintenance for Robot Motors
:: Automated Setup Script for Windows
:: Run this file once to install all required tools and libraries
:: ============================================================

echo.
echo  ============================================================
echo   Predictive Maintenance for Robot Motors — Setup Script
echo  ============================================================
echo.
echo  This script will:
echo    1. Check if Arduino CLI is installed
echo    2. Install Arduino CLI if not found
echo    3. Add ESP32 board support
echo    4. Install all required Arduino libraries
echo.
echo  Please keep this window open until setup is complete.
echo  ============================================================
echo.
pause

:: ---------------------------------------------------------------
:: STEP 1 — Check if Arduino CLI is already installed
:: ---------------------------------------------------------------
echo.
echo [STEP 1] Checking for Arduino CLI...
echo.

where arduino-cli >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo  [OK] Arduino CLI is already installed.
    arduino-cli version
) ELSE (
    echo  [INFO] Arduino CLI not found. Downloading and installing...
    echo.

    :: Download Arduino CLI installer using PowerShell
    powershell -Command "Invoke-WebRequest -Uri 'https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Windows_64bit.zip' -OutFile '%TEMP%\arduino-cli.zip'"

    echo  [INFO] Extracting Arduino CLI...
    powershell -Command "Expand-Archive -Path '%TEMP%\arduino-cli.zip' -DestinationPath '%USERPROFILE%\arduino-cli' -Force"

    :: Add to PATH for this session
    SET PATH=%USERPROFILE%\arduino-cli;%PATH%

    echo  [OK] Arduino CLI downloaded and extracted to %USERPROFILE%\arduino-cli
    echo.
    echo  NOTE: To use arduino-cli permanently from any terminal,
    echo        add this folder to your system PATH manually:
    echo        %USERPROFILE%\arduino-cli
    echo.
)

:: ---------------------------------------------------------------
:: STEP 2 — Initialize Arduino CLI config (if not already done)
:: ---------------------------------------------------------------
echo.
echo [STEP 2] Initializing Arduino CLI configuration...
echo.
arduino-cli config init --overwrite
echo  [OK] Configuration initialized.

:: ---------------------------------------------------------------
:: STEP 3 — Add ESP32 Board Manager URL
:: ---------------------------------------------------------------
echo.
echo [STEP 3] Adding ESP32 board support URL...
echo.
arduino-cli config add board_manager.additional_urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
echo  [OK] ESP32 board URL added.

:: ---------------------------------------------------------------
:: STEP 4 — Update Board Index
:: ---------------------------------------------------------------
echo.
echo [STEP 4] Updating board index (this may take a minute)...
echo.
arduino-cli core update-index
echo  [OK] Board index updated.

:: ---------------------------------------------------------------
:: STEP 5 — Install ESP32 Board Package
:: ---------------------------------------------------------------
echo.
echo [STEP 5] Installing ESP32 board package by Espressif...
echo          (This may take several minutes — please wait)
echo.
arduino-cli core install esp32:esp32@2.0.17
echo  [OK] ESP32 board package installed.

:: ---------------------------------------------------------------
:: STEP 6 — Install Required Arduino Libraries
:: ---------------------------------------------------------------
echo.
echo [STEP 6] Installing required Arduino libraries...
echo.

echo  Installing MPU6050 library...
arduino-cli lib install "MPU6050"
echo  [OK] MPU6050 installed.

echo.
echo  Installing DHT sensor library...
arduino-cli lib install "DHT sensor library"
echo  [OK] DHT sensor library installed.

echo.
echo  Installing Adafruit Unified Sensor (dependency for DHT)...
arduino-cli lib install "Adafruit Unified Sensor"
echo  [OK] Adafruit Unified Sensor installed.

:: Wire, WiFi, and WebServer are built-in — no installation needed
echo.
echo  [INFO] Wire, WiFi, and WebServer libraries are built-in
echo         with the ESP32 package — no separate install needed.

:: ---------------------------------------------------------------
:: STEP 7 — Verify Installation
:: ---------------------------------------------------------------
echo.
echo [STEP 7] Verifying installed boards and libraries...
echo.
echo  --- Installed ESP32 Board ---
arduino-cli core list

echo.
echo  --- Installed Libraries ---
arduino-cli lib list

:: ---------------------------------------------------------------
:: DONE
:: ---------------------------------------------------------------
echo.
echo  ============================================================
echo   Setup Complete!
echo  ============================================================
echo.
echo  Everything is installed. Here is what to do next:
echo.
echo   1. Open Arduino IDE (install from https://www.arduino.cc
echo      if not already installed)
echo.
echo   2. Go to: Tools ^> Board ^> ESP32 Arduino ^> ESP32 Dev Module
echo.
echo   3. Go to: Tools ^> Port ^> Select the COM port for your ESP32
echo      (appears when ESP32 is connected via USB)
echo.
echo   4. Open the .ino file from the 'codes' folder of this project
echo.
echo   5. Click the Upload button (right arrow icon)
echo.
echo   6. After upload, open Serial Monitor (Tools ^> Serial Monitor)
echo      and set baud rate to 115200
echo.
echo   7. Connect to the ESP32's Wi-Fi to view the live dashboard
echo.
echo  ============================================================
echo.
pause
