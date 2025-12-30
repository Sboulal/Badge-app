# ============================================================================
# Script PowerShell de création de raccourci Bureau
# Badge Management System - Version Windows
# ============================================================================

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Creation du raccourci Bureau" -ForegroundColor Cyan
Write-Host "Badge Management System" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration des chemins
$ProjectDir = "C:\Users\$env:USERNAME\Desktop\Badge-app"
$Desktop = [Environment]::GetFolderPath("Desktop")
$ShortcutPath = "$Desktop\Badge Management.lnk"

# Vérification du projet
Write-Host "Verification du projet..." -ForegroundColor Yellow

if (-Not (Test-Path $ProjectDir)) {
    Write-Host "[ERREUR] Le dossier du projet n'existe pas: $ProjectDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Chemins possibles a verifier:" -ForegroundColor Yellow
    Write-Host "  - C:\Users\$env:USERNAME\Desktop\Badge-app"
    Write-Host "  - C:\Users\$env:USERNAME\Documents\Badge-app"
    Write-Host "  - D:\Badge-app"
    Write-Host ""
    Write-Host "Modifiez la variable `$ProjectDir dans ce script." -ForegroundColor Yellow
    Pause
    exit 1
}

if (-Not (Test-Path "$ProjectDir\package.json")) {
    Write-Host "[ERREUR] package.json introuvable dans $ProjectDir" -ForegroundColor Red
    Pause
    exit 1
}

Write-Host "[OK] Projet trouve" -ForegroundColor Green
Write-Host ""

# Vérifier l'icône
$IconPath = "$ProjectDir\assets\icon.ico"
if (-Not (Test-Path $IconPath)) {
    Write-Host "[ATTENTION] Icone introuvable: $IconPath" -ForegroundColor Yellow
    Write-Host "Le raccourci utilisera l'icone par defaut" -ForegroundColor Yellow
    $IconPath = "$env:SystemRoot\System32\shell32.dll,21"
}

# Créer le raccourci
Write-Host "Creation du raccourci..." -ForegroundColor Yellow

$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)

# Configuration du raccourci
$Shortcut.TargetPath = "cmd.exe"
$Shortcut.Arguments = "/c cd /d `"$ProjectDir`" && npm start"
$Shortcut.WorkingDirectory = $ProjectDir
$Shortcut.Description = "Badge Management System - Gestion de badges avec impression"
$Shortcut.IconLocation = $IconPath
$Shortcut.WindowStyle = 1  # Normal window

# Sauvegarder
$Shortcut.Save()

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "[SUCCESS] Installation terminee !" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Raccourci cree:" -ForegroundColor Cyan
Write-Host "  $ShortcutPath" -ForegroundColor White
Write-Host ""
Write-Host "Pour lancer l'application:" -ForegroundColor Cyan
Write-Host "  1. Double-cliquez sur 'Badge Management' sur votre bureau" -ForegroundColor White
Write-Host ""
Write-Host "Note:" -ForegroundColor Yellow
Write-Host "  - Une fenetre de commande s'ouvrira au demarrage" -ForegroundColor White
Write-Host "  - Ne la fermez pas tant que l'application est en cours" -ForegroundColor White
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Pause