@echo off
echo ========================================
echo Clone du repo et ajout des fichiers
echo ========================================
echo.

cd /d "%~dp0\.."

echo Clonage du repo GitHub...
git clone https://github.com/difourthomas-droid/macho.git macho-temp

echo.
echo Copie des fichiers dans le repo...
xcopy /E /I /Y "windsurf-project-2\*" "macho-temp\windsurf-project-2\"

echo.
echo Navigation dans le repo...
cd macho-temp

echo.
echo Ajout des fichiers...
git add .

echo.
echo Commit des fichiers...
git commit -m "Add Macho DUI Menu - Complete setup"

echo.
echo Push vers GitHub...
git push origin main

echo.
echo Nettoyage...
cd ..
rmdir /S /Q macho-temp

echo.
echo ========================================
echo Push termine avec succes!
echo Attendez 2-5 minutes pour GitHub Pages
echo ========================================
echo.
echo Ensuite, activez GitHub Pages sur:
echo https://github.com/difourthomas-droid/macho/settings/pages
echo.
pause
