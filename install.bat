@echo off
echo Installation Badge Management System
echo.

python --version
if %errorlevel% neq 0 (
    echo ERREUR: Python non trouve
    echo Installez Python depuis python.org
    pause
    exit
)

echo Creation environnement virtuel...
python -m venv venv

echo Activation...
call venv\Scripts\activate

echo Installation packages...
pip install flask flask-cors python-dotenv pillow openpyxl requests pyusb brother-ql

echo.
echo Installation terminee!
echo Lancez: start.bat
pause