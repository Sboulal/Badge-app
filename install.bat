@echo off
chcp 65001 >nul
cls
color 0B
title Badge Management System - Installation

echo.
echo ========================================================
echo    Badge Management System
echo    Installation des dépendances...
echo ========================================================
echo.

REM Vérification Python
where python >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installé!
    echo.
    echo Téléchargez Python depuis: https://www.python.org/downloads/
    echo Assurez-vous de cocher "Add Python to PATH" lors de l'installation
    pause
    exit /b 1
)

echo [OK] Python trouvé: 
python --version
echo.

REM Création de l'environnement virtuel
if not exist "venv" (
    echo [INFO] Création de l'environnement virtuel...
    python -m venv venv
    if errorlevel 1 (
        echo [ERREUR] Échec de création de l'environnement virtuel
        pause
        exit /b 1
    )
    echo [OK] Environnement virtuel créé
) else (
    echo [OK] Environnement virtuel existe déjà
)
echo.

REM Activation de l'environnement virtuel
echo [INFO] Activation de l'environnement virtuel...
call venv\Scripts\activate.bat

REM Mise à jour de pip
echo [INFO] Mise à jour de pip...
python -m pip install --upgrade pip
echo.

REM Installation des dépendances
echo [INFO] Installation des dépendances Python...
pip install flask flask-cors python-dotenv pillow openpyxl requests pyusb brother-ql

if errorlevel 1 (
    echo.
    echo [ERREUR] Échec de l'installation des dépendances
    pause
    exit /b 1
)

echo.
echo ========================================================
echo    Installation terminée avec succès!
echo ========================================================
echo.
echo Configuration USB pour Windows:
echo 1. Téléchargez Zadig: https://zadig.akeo.ie/
echo 2. Lancez Zadig en tant qu'administrateur
echo 3. Options ^> List All Devices
echo 4. Sélectionnez votre imprimante Brother QL
echo 5. Installez le pilote WinUSB
echo.
echo Vous pouvez maintenant lancer l'application avec start.bat
echo.
pause