@echo off
echo ========================================
echo Configuration Git et Push vers GitHub
echo ========================================
echo.

cd /d "%~dp0"

echo Initialisation du depot Git...
git init

echo.
echo Ajout du remote GitHub...
git remote add origin https://github.com/difourthomas-droid/macho.git

echo.
echo Creation de la branche main...
git branch -M main

echo.
echo Ajout des fichiers...
git add .

echo.
echo Commit des fichiers...
git commit -m "Add Macho DUI Menu - Complete setup"

echo.
echo Push vers GitHub...
git push -u origin main

echo.
echo ========================================
echo Configuration terminee!
echo Attendez 2-5 minutes pour GitHub Pages
echo ========================================
pause
