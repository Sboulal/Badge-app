@echo off
cls
color 0B
title Badge Management System - Build

echo.
echo ========================================================
echo    Badge Management System - Build
echo ========================================================
echo.
echo Selectionnez le type de build:
echo.
echo 1. Build Windows (Installeur + Portable)
echo 2. Build rapide (sans compression)
echo 3. Nettoyer et rebuild
echo 4. Tester sans build
echo 5. Quitter
echo.

choice /C 12345 /N /M "Votre choix: "
set choice=%errorlevel%

if %choice%==5 goto end
if %choice%==4 goto test
if %choice%==3 goto clean
if %choice%==2 goto quick
if %choice%==1 goto full

:full
echo.
echo [BUILD COMPLET] Creation de tous les executables...
echo.
call npm run build:win
if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Le build a echoue!
    pause
    exit /b 1
)
echo.
echo [OK] Build termine!
echo.
echo Fichiers generes dans le dossier "dist/":
dir dist\*.exe /b
echo.
goto success

:quick
echo.
echo [BUILD RAPIDE] Creation sans compression...
echo.
call npm run pack
if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Le build a echoue!
    pause
    exit /b 1
)
echo.
echo [OK] Build rapide termine!
goto success

:clean
echo.
echo [NETTOYAGE] Suppression des anciens builds...
if exist "dist" rmdir /s /q dist
if exist "node_modules\.cache" rmdir /s /q node_modules\.cache
echo [OK] Nettoyage termine
echo.
echo [REBUILD] Reconstruction complete...
call npm run build:win
if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Le rebuild a echoue!
    pause
    exit /b 1
)
goto success

:test
echo.
echo [TEST] Lancement en mode developpement...
start npm start
goto end

:success
echo.
echo ========================================================
echo    BUILD REUSSI!
echo ========================================================
echo.
echo Les fichiers se trouvent dans le dossier "dist/"
echo.
echo Types de fichiers:
echo - Setup.exe     : Installeur Windows classique
echo - Portable.exe  : Version portable (sans installation)
echo.

choice /C YN /M "Ouvrir le dossier dist"
if errorlevel 2 goto end
if errorlevel 1 start explorer dist

:end
echo.
pause