@echo off
chcp 65001 >nul
cls
color 0B
title Badge Management System - Démarrage

echo.
echo ========================================================
echo    Badge Management System
echo    Lancement de l'application...
echo ========================================================
echo.

REM Vérification Python
where python >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python introuvable!
    echo Installez Python depuis https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Vérification de l'environnement virtuel
if not exist "venv\Scripts\activate.bat" (
    echo [ERREUR] Environnement virtuel introuvable!
    echo Exécutez install.bat d'abord.
    pause
    exit /b 1
)

echo [OK] Python trouvé
echo [OK] Environnement virtuel trouvé
echo.

REM Activation de l'environnement virtuel
call venv\Scripts\activate.bat

echo [INFO] Démarrage du serveur Flask...
echo.
echo ========================================================
echo    Serveur: http://127.0.0.1:5000
echo    Appuyez sur Ctrl+C pour arrêter
echo ========================================================
echo.

REM Démarrage de l'application Flask
python badge_app.py

pause