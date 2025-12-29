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
echo [INFO] Vérification de Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installé ou n'est pas dans le PATH!
    echo.
    echo Solutions:
    echo 1. Téléchargez Python depuis: https://www.python.org/downloads/
    echo 2. Lors de l'installation, cochez "Add Python to PATH"
    echo 3. Redémarrez votre terminal après l'installation
    echo.
    echo Essayez aussi: py --version
    py --version >nul 2>&1
    if errorlevel 1 (
        echo Python introuvable avec 'py' non plus.
        pause
        exit /b 1
    ) else (
        echo [OK] Python trouvé avec 'py'
        set PYTHON_CMD=py
        goto :python_found
    )
)

set PYTHON_CMD=python
:python_found
echo [OK] Python trouvé: 
%PYTHON_CMD% --version
echo.

REM Suppression de l'ancien environnement virtuel si corrompu
if exist "venv" (
    echo [INFO] Vérification de l'environnement virtuel existant...
    if not exist "venv\Scripts\activate.bat" (
        echo [ATTENTION] Environnement virtuel corrompu détecté
        echo [INFO] Suppression de l'ancien environnement...
        rmdir /s /q venv
    )
)

REM Création de l'environnement virtuel
if not exist "venv" (
    echo [INFO] Création de l'environnement virtuel...
    %PYTHON_CMD% -m venv venv
    if errorlevel 1 (
        echo [ERREUR] Échec de création de l'environnement virtuel
        echo.
        echo Solutions possibles:
        echo 1. Installez/réinstallez Python avec toutes les options
        echo 2. Vérifiez que vous avez les droits d'administrateur
        echo 3. Essayez: %PYTHON_CMD% -m pip install --upgrade virtualenv
        echo.
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
if not exist "venv\Scripts\activate.bat" (
    echo [ERREUR] Fichier activate.bat introuvable!
    echo L'environnement virtuel semble corrompu.
    echo Supprimez le dossier 'venv' et relancez install.bat
    pause
    exit /b 1
)

call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERREUR] Échec de l'activation de l'environnement virtuel
    pause
    exit /b 1
)
echo [OK] Environnement virtuel activé
echo.

REM Mise à jour de pip
echo [INFO] Mise à jour de pip...
python -m pip install --upgrade pip --quiet
if errorlevel 1 (
    echo [ATTENTION] Échec de la mise à jour de pip, continuation...
)
echo [OK] pip mis à jour
echo.

REM Installation des dépendances
echo [INFO] Installation des dépendances Python...
echo Cette étape peut prendre quelques minutes...
echo.

pip install flask flask-cors python-dotenv pillow openpyxl requests pyusb brother-ql

if errorlevel 1 (
    echo.
    echo [ERREUR] Échec de l'installation des dépendances
    echo.
    echo Solutions:
    echo 1. Vérifiez votre connexion Internet
    echo 2. Essayez de désactiver temporairement l'antivirus
    echo 3. Installez manuellement: pip install flask
    echo 4. Utilisez: pip install --user [nom_du_package]
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Toutes les dépendances sont installées
echo.

REM Création du fichier .env s'il n'existe pas
if not exist ".env" (
    echo [INFO] Création du fichier .env...
    (
        echo # Configuration de la base de données
        echo DB_NAME=badges.db
        echo.
        echo # Configuration de l'API externe
        echo EXTERNAL_API_URL=http://badges.eevent.ma/api/getbadges
        echo.
        echo # Configuration de l'imprimante Brother QL
        echo PRINTER_MODEL=QL-810W
        echo PRINTER_BACKEND=pyusb
        echo PRINTER_USB_VENDOR_ID=0x04f9
        echo PRINTER_USB_PRODUCT_ID=0x209c
        echo.
        echo # Configuration des étiquettes
        echo LABEL_SIZE=29x90
        echo LABEL_ROTATE=90
        echo LABEL_CUT=True
        echo.
        echo # Configuration du serveur Flask
        echo FLASK_HOST=0.0.0.0
        echo FLASK_PORT=5000
        echo FLASK_DEBUG=True
        echo.
        echo # Configuration CORS
        echo CORS_ORIGINS=*
    ) > .env
    echo [OK] Fichier .env créé
) else (
    echo [OK] Fichier .env existe déjà
)
echo.

echo ========================================================
echo    Installation terminée avec succès!
echo ========================================================
echo.
echo PROCHAINES ÉTAPES:
echo.
echo 1. Configuration USB pour Windows:
echo    - Téléchargez Zadig: https://zadig.akeo.ie/
echo    - Lancez Zadig en tant qu'administrateur
echo    - Options ^> List All Devices
echo    - Sélectionnez votre imprimante Brother QL
echo    - Installez le pilote WinUSB
echo.
echo 2. Modifiez le fichier .env si nécessaire
echo.
echo 3. Lancez l'application avec: start.bat
echo.
echo ========================================================
echo.
pause