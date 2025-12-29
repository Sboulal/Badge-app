@echo off
chcp 65001 >nul
REM ============================================
REM Badge Management System - Startup Script
REM ============================================

color 0A
title Badge Management System - Startup

echo ========================================
echo   Badge Management System
echo   Demarrage de l'application...
echo ========================================
echo.

REM Verifier si Python est installe
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH
    echo.
    echo Veuillez installer Python depuis: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo [OK] Python detecte
echo.

REM Verifier si Node.js est installe
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe ou n'est pas dans le PATH
    echo.
    echo Veuillez installer Node.js depuis: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [OK] Node.js detecte
echo.

REM Verifier si api_server.py existe
if not exist "api_server.py" (
    echo [ERREUR] Le fichier api_server.py est introuvable
    echo.
    pause
    exit /b 1
)

echo [OK] api_server.py trouve
echo.

REM Verifier si les dependances Python sont installees
echo Verification des dependances Python...
python -c "import flask" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ATTENTION] Dependances Python manquantes
    echo Installation des dependances...
    pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation des dependances Python
        pause
        exit /b 1
    )
)

echo [OK] Dependances Python installees
echo.

REM Verifier si les dependances Node.js sont installees
if not exist "node_modules\" (
    echo [ATTENTION] Dependances Node.js manquantes
    echo Installation des dependances...
    call npm install
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation des dependances Node.js
        pause
        exit /b 1
    )
)

echo [OK] Dependances Node.js installees
echo.

REM Verifier si le fichier .env existe
if not exist ".env" (
    echo [ATTENTION] Fichier .env manquant
    echo Creation du fichier .env par defaut...
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
    echo.
)

echo ========================================
echo   Nettoyage du port 5000
echo ========================================
echo.

REM Nettoyer les anciens processus qui pourraient bloquer le port
echo Verification du port 5000...
set PORT_CLEANED=0

for /f "tokens=5" %%a in ('netstat -ano 2^>nul ^| findstr :5000 ^| findstr LISTENING') do (
    echo Arret du processus bloquant le port (PID: %%a)...
    taskkill /F /PID %%a >nul 2>&1
    set PORT_CLEANED=1
)

if %PORT_CLEANED%==1 (
    echo Attente de liberation du port...
    timeout /t 2 /nobreak >nul
    echo [OK] Port 5000 nettoye
) else (
    echo [OK] Port 5000 disponible
)

echo.
echo ========================================
echo   Demarrage de l'application
echo   Electron va lancer Flask automatiquement
echo ========================================
echo.

REM Lancer l'application Electron (qui lancera Flask en interne)
npm start

if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] L'application s'est arretee avec une erreur
    echo.
    echo Verifications a effectuer:
    echo - Python est bien installe et dans le PATH
    echo - Toutes les dependances sont installees
    echo - Le fichier api_server.py existe
    echo - Le port 5000 n'est pas bloque par un pare-feu
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Application fermee normalement
echo ========================================
pause