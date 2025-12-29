@echo off
chcp 65001 >nul
REM ============================================
REM Badge Management System - Setup & Installation
REM ============================================

color 0E
title Badge Management System - Setup

echo ========================================
echo   Badge Management System
echo   Installation et Configuration
echo ========================================
echo.

REM Verifier les prerequis
echo [1/5] Verification de Python...
python --version
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe
    echo Telechargez Python depuis: https://www.python.org/downloads/
    pause
    exit /b 1
)
echo [OK] Python installe
echo.

echo [2/5] Verification de Node.js...
node --version
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe
    echo Telechargez Node.js depuis: https://nodejs.org/
    pause
    exit /b 1
)
echo [OK] Node.js installe
echo.

echo [3/5] Installation des dependances Python...
pip install --upgrade pip
pip install flask flask-cors python-dotenv pillow brother_ql pyusb openpyxl requests
if %errorlevel% neq 0 (
    echo [ERREUR] Echec de l'installation Python
    pause
    exit /b 1
)
echo [OK] Dependances Python installees
echo.

echo [4/5] Installation des dependances Node.js...
call npm install
if %errorlevel% neq 0 (
    echo [ERREUR] Echec de l'installation Node.js
    pause
    exit /b 1
)
echo [OK] Dependances Node.js installees
echo.

echo [5/5] Creation du fichier de configuration...
if not exist ".env" (
    (
        echo # Configuration du serveur Flask
        echo DB_NAME=badges.db
        echo EXTERNAL_API_URL=http://badges.eevent.ma/api/getbadges
        echo.
        echo # Configuration imprimante Brother QL
        echo PRINTER_MODEL=QL-810W
        echo PRINTER_BACKEND=pyusb
        echo PRINTER_USB_VENDOR_ID=0x04f9
        echo PRINTER_USB_PRODUCT_ID=0x209c
        echo.
        echo # Configuration etiquettes
        echo LABEL_SIZE=29x90
        echo LABEL_ROTATE=90
        echo LABEL_CUT=True
        echo.
        echo # Configuration serveur
        echo FLASK_HOST=127.0.0.1
        echo FLASK_PORT=5000
        echo FLASK_DEBUG=False
        echo.
        echo # CORS
        echo CORS_ORIGINS=*
    ) > .env
    echo [OK] Fichier .env cree
) else (
    echo [OK] Fichier .env existe deja
)
echo.

echo ========================================
echo   Installation terminee avec succes!
echo ========================================
echo.
echo Prochaines etapes:
echo 1. Connectez votre imprimante Brother QL via USB
echo 2. Lancez 'start-badge-system.bat' pour demarrer
echo 3. Ou lancez 'start-api-only.bat' pour API seul
echo.

REM Proposer de detecter l'imprimante
echo Voulez-vous detecter l'imprimante maintenant? (O/N)
set /p choice="> "
if /i "%choice%"=="O" (
    echo.
    echo Detection de l'imprimante...
    python -c "from api_server import detect_brother_printer; printers = detect_brother_printer(); print(f'Imprimantes detectees: {printers}' if printers else 'Aucune imprimante detectee')"
    echo.
)

echo.
echo Installation complete!
pause