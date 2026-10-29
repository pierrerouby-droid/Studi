@echo off
rem Glissez-deposez un dossier de videos sur ce fichier pour egaliser leur volume.
rem Ajoutez "compression" apres le dossier en ligne de commande pour activer la compression legere.
chcp 65001 >nul
if "%~1"=="" (
    echo Glissez-deposez le dossier des videos sur ce fichier.
    pause
    exit /b 1
)
if /i "%~2"=="compression" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0normaliser-audio.ps1" -Source "%~1" -Compression
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0normaliser-audio.ps1" -Source "%~1"
)
pause
