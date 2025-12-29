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

REM Tuer tout processus existant sur le port 5000
echo Nettoyage des processus existants sur le port 5000...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do (
    echo Arret du processus PID: %%a
    taskkill /F /PID %%a
)

REM Attendre que le port soit libere
timeout /t 2 /nobreak >nul

REM Verifier une seconde fois et tuer si necessaire
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5000 ^| findstr LISTENING') do (
    echo Arret force du processus PID: %%a
    taskkill /F /PID %%a
    timeout /t 1 /nobreak >nul
)

REM Verifier que le port est bien libre
netstat -ano | findstr :5000 | findstr LISTENING >nul 2>&1
if %errorlevel% equ 0 (
    echo [ERREUR] Le port 5000 est toujours utilise
    echo Veuillez fermer manuellement l'application qui utilise ce port
    echo.
    echo Processus utilisant le port 5000:
    netstat -ano | findstr :5000
    echo.
    pause
    exit /b 1
)

echo [OK] Port 5000 libre

REM Lancer le serveur Flask en arriere-plan
echo Demarrage du serveur Flask...
start "Flask API Server" python api_server.py

REM Attendre que le serveur Flask demarre (avec plusieurs tentatives)
echo Attente du demarrage du serveur Flask...
set RETRIES=0
:WAIT_FLASK
timeout /t 2 /nobreak >nul
netstat -ano | findstr :5000 | findstr LISTENING >nul 2>&1
if %errorlevel% neq 0 (
    set /a RETRIES+=1
    if %RETRIES% leq 5 (
        echo Tentative %RETRIES%/5...
        goto WAIT_FLASK
    ) else (
        echo [ERREUR] Le serveur Flask n'a pas demarre apres 10 secondes
        echo Verifiez les erreurs dans la fenetre Flask
        pause
        exit /b 1
    )
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