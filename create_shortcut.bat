@echo off
REM ============================================================================
REM Script de création de raccourci Bureau pour Badge Management System
REM Pour Windows 10/11
REM ============================================================================

echo ==========================================
echo Creation du raccourci Bureau
echo Badge Management System
echo ==========================================
echo.

REM Définir les chemins
set "PROJECT_DIR=C:\Users\%USERNAME%\Desktop\Badge-app"
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\Badge Management.lnk"

echo Verification du projet...
if not exist "%PROJECT_DIR%" (
    echo [ERREUR] Le dossier du projet n'existe pas: %PROJECT_DIR%
    echo.
    echo Veuillez modifier PROJECT_DIR dans ce script avec le bon chemin.
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\package.json" (
    echo [ERREUR] package.json introuvable dans %PROJECT_DIR%
    pause
    exit /b 1
)

echo [OK] Projet trouve
echo.

REM Créer le script VBS pour créer le raccourci
echo Creation du raccourci...

set "VBS_SCRIPT=%TEMP%\create_shortcut.vbs"

(
echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
echo sLinkFile = "%SHORTCUT%"
echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
echo oLink.TargetPath = "cmd.exe"
echo oLink.Arguments = "/c cd /d ""%PROJECT_DIR%"" && npm start"
echo oLink.WorkingDirectory = "%PROJECT_DIR%"
echo oLink.Description = "Badge Management System - Gestion de badges avec impression"
echo oLink.IconLocation = "%PROJECT_DIR%\assets\icon.ico"
echo oLink.WindowStyle = 1
echo oLink.Save
) > "%VBS_SCRIPT%"

REM Exécuter le script VBS
cscript //nologo "%VBS_SCRIPT%"

REM Supprimer le script temporaire
del "%VBS_SCRIPT%"

echo.
echo ==========================================
echo [SUCCESS] Installation terminee !
echo ==========================================
echo.
echo Raccourci cree sur le bureau:
echo    %SHORTCUT%
echo.
echo Pour lancer l'application:
echo    1. Double-cliquez sur 'Badge Management' sur votre bureau
echo.
echo Note: Une fenetre de commande s'ouvrira brievement au demarrage.
echo ==========================================
echo.
pause