@echo off
chcp 65001 >nul
cls
color 0B
title Badge Management System - Demarrage

echo.
echo ========================================================
echo    Badge Management System
echo    Lancement de l'application...
echo ========================================================
echo.

REM Verification rapide
where node >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Node.js introuvable!
    echo Executez install.bat d'abord.
    pause
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python introuvable!
    echo Executez install.bat d'abord.
    pause
    exit /b 1
)

echo [OK] Environnement verifie
echo.
echo Demarrage de l'application...
echo.
echo Appuyez sur Ctrl+C pour arreter
echo.

npm start

pause