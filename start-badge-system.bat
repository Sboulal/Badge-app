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
)

echo.
echo ========================================
echo   Demarrage du serveur Flask
echo ========================================
echo.

REM Verifier si le fichier api_server.py existe
if not exist "api_server.py" (
    echo [ERREUR] Le fichier api_server.py est introuvable
    pause
    exit /b 1
)

REM Tuer tout processus Python existant sur le port 5000
echo Nettoyage des processus existants...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1

REM Lancer le serveur Flask en arriere-plan
echo Demarrage du serveur Flask...
start "Flask API Server" python api_server.py

REM Attendre que le serveur Flask demarre
echo Attente du demarrage du serveur Flask...
timeout /t 3 /nobreak >nul

REM Verifier si le serveur Flask est lance
netstat -ano | findstr :5000 | findstr LISTENING >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Le serveur Flask n'a pas demarre correctement
    pause
    exit /b 1
)

echo [OK] Serveur Flask demarre sur http://127.0.0.1:5000
echo.

echo ========================================
echo   Demarrage de l'application Electron
echo ========================================
echo.

REM Lancer l'application Electron
npm start

if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] L'application s'est arretee avec une erreur
)

echo.
echo ========================================
echo   Arret du serveur Flask
echo ========================================
echo.

REM Arreter le serveur Flask
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do (
    echo Arret du processus Flask (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo Application fermee normalement
pause