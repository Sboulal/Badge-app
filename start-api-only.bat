@echo off
chcp 65001 >nul
REM ============================================
REM Badge Management API - Serveur Flask seul
REM ============================================

color 0B
title Badge Management API Server

echo ========================================
echo   API Server Badge Management
echo   Demarrage du serveur Flask...
echo ========================================
echo.

REM Verifier Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe
    pause
    exit /b 1
)

echo [OK] Python detecte
echo.

REM Installer les dependances si necessaire
echo Verification des dependances...
python -c "import flask" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installation des dependances Python...
    pip install flask flask-cors python-dotenv pillow brother_ql pyusb openpyxl requests
)

echo.
echo ========================================
echo   Serveur API demarre
echo   Port: 5000
echo   URL: http://127.0.0.1:5000
echo ========================================
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur
echo.

REM Lancer le serveur Flask
python api_server.py

pause