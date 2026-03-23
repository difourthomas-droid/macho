@echo off
echo ========================================
echo Push des fichiers vers GitHub
echo ========================================
echo.

cd /d "%~dp0"

git add .
git commit -m "Add Macho DUI Menu - Complete setup"
git push origin main

echo.
echo ========================================
echo Push termine!
echo Attendez 2-5 minutes pour le deploiement
echo ========================================
pause
