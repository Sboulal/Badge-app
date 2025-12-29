@echo off
chcp 65001 >nul
REM ============================================
REM Badge Management System - Unified Startup Script
REM ============================================

color 0A
title Badge Management System

:MENU
cls
echo ========================================
echo   Badge Management System
echo   Script de Demarrage Unifie
echo ========================================
echo.
echo Choisissez le mode de lancement:
echo.
echo   1. Application Complete (Electron + API)
echo   2. Serveur API Seul (Flask uniquement)
echo   3. Installation / Setup
echo   4. Test des Endpoints
echo   5. Quitter
echo.
echo ========================================
set /p choice="Votre choix (1-5): "

if "%choice%"=="1" goto APP_COMPLETE
if "%choice%"=="2" goto API_ONLY
if "%choice%"=="3" goto SETUP
if "%choice%"=="4" goto TEST_ENDPOINTS
if "%choice%"=="5" goto END
goto MENU

REM ============================================
REM MODE 1: APPLICATION COMPLETE
REM ============================================
:APP_COMPLETE
cls
color 0A
title Badge Management System - Application Complete
echo ========================================
echo   MODE: Application Complete
echo   Electron + API Flask
echo ========================================
echo.

call :CHECK_PREREQUISITES
if %errorlevel% neq 0 goto MENU

call :CHECK_DEPENDENCIES
if %errorlevel% neq 0 goto MENU

call :CHECK_ENV_FILE

echo.
echo ========================================
echo   Demarrage de l'application...
echo ========================================
echo.

REM Lancer l'application Electron (qui démarre automatiquement Flask)
npm start

if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] L'application s'est arretee avec une erreur
    pause
    goto MENU
)

echo.
echo Application fermee normalement
pause
goto MENU

REM ============================================
REM MODE 2: API SEUL
REM ============================================
:API_ONLY
cls
color 0B
title Badge Management System - API Serveur
echo ========================================
echo   MODE: Serveur API Seul
echo   Flask uniquement
echo ========================================
echo.

REM Vérifier Python uniquement
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe
    echo.
    echo Telechargez Python: https://www.python.org/downloads/
    pause
    goto MENU
)

echo [OK] Python detecte
echo.

REM Vérifier les dépendances Python
echo Verification des dependances Python...
python -c "import flask" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ATTENTION] Dependances Python manquantes
    echo Installation automatique...
    pip install flask flask-cors python-dotenv pillow brother_ql pyusb openpyxl requests
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation
        pause
        goto MENU
    )
)

echo [OK] Dependances Python installees
echo.

call :CHECK_ENV_FILE

echo.
echo ========================================
echo   Serveur API Demarre
echo ========================================
echo.
echo   Port: 5000
echo   URL:  http://127.0.0.1:5000
echo.
echo   Endpoints disponibles:
echo   - GET  /api/getbadges
echo   - POST /api/badges
echo   - POST /print-label
echo   - GET  /api/stats
echo   - Plus d'infos: http://127.0.0.1:5000
echo.
echo ========================================
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

REM Vérifier si api_server.py existe
if not exist "api_server.py" (
    echo [ERREUR] Fichier api_server.py introuvable!
    pause
    goto MENU
)

REM Lancer le serveur Flask
python api_server.py

pause
goto MENU

REM ============================================
REM MODE 3: INSTALLATION / SETUP
REM ============================================
:SETUP
cls
color 0E
title Badge Management System - Setup
echo ========================================
echo   MODE: Installation et Configuration
echo ========================================
echo.

echo [1/6] Verification de Python...
python --version
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe
    echo Telechargez: https://www.python.org/downloads/
    pause
    goto MENU
)
echo [OK] Python installe
echo.

echo [2/6] Verification de Node.js...
node --version
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe
    echo Telechargez: https://nodejs.org/
    pause
    goto MENU
)
echo [OK] Node.js installe
echo.

echo [3/6] Mise a jour de pip...
python -m pip install --upgrade pip --quiet
echo [OK] pip mis a jour
echo.

echo [4/6] Installation des dependances Python...
pip install flask flask-cors python-dotenv pillow brother_ql pyusb openpyxl requests
if %errorlevel% neq 0 (
    echo [ERREUR] Echec de l'installation Python
    pause
    goto MENU
)
echo [OK] Dependances Python installees
echo.

echo [5/6] Installation des dependances Node.js...
if exist "package.json" (
    call npm install
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation Node.js
        pause
        goto MENU
    )
    echo [OK] Dependances Node.js installees
) else (
    echo [ATTENTION] package.json introuvable, passage...
)
echo.

echo [6/6] Creation du fichier de configuration...
call :CHECK_ENV_FILE
echo.

echo ========================================
echo   Installation terminee avec succes!
echo ========================================
echo.

REM Proposer de détecter l'imprimante
echo Voulez-vous detecter l'imprimante maintenant? (O/N)
set /p detect_choice="> "
if /i "%detect_choice%"=="O" (
    echo.
    echo Detection de l'imprimante...
    python -c "from api_server import detect_brother_printer; printers = detect_brother_printer(); print(f'Imprimantes detectees: {printers}' if printers else 'Aucune imprimante detectee')" 2>nul
    if %errorlevel% neq 0 (
        echo [INFO] Detection non disponible (serveur doit etre demarre)
    )
    echo.
)

echo Installation complete!
echo.
pause
goto MENU

REM ============================================
REM MODE 4: TEST DES ENDPOINTS
REM ============================================
:TEST_ENDPOINTS
cls
color 0D
title Badge Management System - Test Endpoints
echo ========================================
echo   MODE: Test des Endpoints API
echo ========================================
echo.

set API_URL=http://127.0.0.1:5000

echo IMPORTANT: Le serveur API doit etre demarre!
echo.
echo Voulez-vous continuer? (O/N)
set /p test_choice="> "
if /i not "%test_choice%"=="O" goto MENU

echo.
echo Demarrage des tests...
echo.

REM Vérifier si curl est disponible
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] curl n'est pas disponible
    echo Utilisez Windows 10/11 ou installez curl
    pause
    goto MENU
)

echo ========================================
echo Test 1: Informations API
echo ========================================
curl -s %API_URL%/ 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Serveur API non accessible!
    echo Lancez d'abord le serveur (option 2)
    pause
    goto MENU
)
echo.
echo.

echo ========================================
echo Test 2: Configuration
echo ========================================
curl -s %API_URL%/api/config 2>nul
echo.
echo.

echo ========================================
echo Test 3: Detection imprimante
echo ========================================
curl -s %API_URL%/api/printer/detect 2>nul
echo.
echo.

echo ========================================
echo Test 4: Statistiques
echo ========================================
curl -s %API_URL%/api/stats 2>nul
echo.
echo.

echo ========================================
echo Test 5: Liste des badges
echo ========================================
curl -s %API_URL%/api/getbadges 2>nul
echo.
echo.

echo ========================================
echo Test 6: Creation d'un badge test
echo ========================================
curl -s -X POST %API_URL%/api/badges -H "Content-Type: application/json" -d "{\"nom\":\"Test\",\"prenom\":\"Badge\",\"valide\":1}" 2>nul
echo.
echo.

echo ========================================
echo   Tests termines!
echo ========================================
echo.
echo Note: Pour plus de details, utilisez test_api.py
echo.
pause
goto MENU

REM ============================================
REM FONCTIONS UTILITAIRES
REM ============================================

:CHECK_PREREQUISITES
echo Verification des prerequis...
echo.

python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe
    echo Telechargez: https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)
echo [OK] Python detecte

node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Node.js n'est pas installe
    echo Telechargez: https://nodejs.org/
    echo.
    pause
    exit /b 1
)
echo [OK] Node.js detecte
echo.

exit /b 0

:CHECK_DEPENDENCIES
echo Verification des dependances...
echo.

REM Dépendances Python
python -c "import flask" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ATTENTION] Dependances Python manquantes
    echo Installation automatique...
    pip install flask flask-cors python-dotenv pillow brother_ql pyusb openpyxl requests
    if %errorlevel% neq 0 (
        echo [ERREUR] Echec de l'installation Python
        pause
        exit /b 1
    )
)
echo [OK] Dependances Python OK

REM Dépendances Node.js
if not exist "node_modules\" (
    if exist "package.json" (
        echo [ATTENTION] Dependances Node.js manquantes
        echo Installation automatique...
        call npm install
        if %errorlevel% neq 0 (
            echo [ERREUR] Echec de l'installation Node.js
            pause
            exit /b 1
        )
    )
)
echo [OK] Dependances Node.js OK
echo.

exit /b 0

:CHECK_ENV_FILE
if not exist ".env" (
    echo [INFO] Creation du fichier .env...
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
    echo [OK] Fichier .env existe
)
exit /b 0

:END
cls
echo.
echo Merci d'avoir utilise Badge Management System!
echo.
exit