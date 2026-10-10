@echo off
rem ======================================================================
rem  lancer_installation.bat -- Formation Linux (CID)
rem
rem  Lanceur a placer dans D:\PrenomNOM\sources\, a cote des installeurs.
rem  Il met a jour le depot de la formation clone dans
rem  D:\PrenomNOM\formation_linux (git pull), puis lance la version a jour
rem  du script installer_virtualbox.bat du depot, en lui indiquant le
rem  dossier sources\ ou se trouvent les installeurs.
rem
rem  Prerequis (module additionnel "Git sous Windows") :
rem    - Git portable dans D:\PrenomNOM\PortableGit ;
rem    - le depot clone dans D:\PrenomNOM\formation_linux.
rem
rem  Sans reseau ou sans Git, la mise a jour est sautee et la version du
rem  script deja presente dans le depot est utilisee.
rem
rem  Messages sans accents, chemins entre guillemets, aucune variable lue
rem  dans le bloc qui la modifie : memes precautions que dans
rem  installer_virtualbox.bat.
rem ======================================================================

setlocal EnableExtensions
title Mise a jour et installation - Formation Linux

rem Dossier du lanceur (D:\PrenomNOM\sources\) et dossier parent.
set "SOURCES=%~dp0"
for %%I in ("%~dp0..") do set "BASE=%%~fI"
set "GIT=%BASE%\PortableGit\cmd\git.exe"
set "DEPOT=%BASE%\formation_linux"
set "SCRIPT=%DEPOT%\ressources\scripts\installer_virtualbox.bat"

echo ======================================================================
echo   Mise a jour du depot de la formation
echo ======================================================================
echo.
echo Depot : %DEPOT%
if not exist "%DEPOT%\.git\" goto sans_depot
if not exist "%GIT%" goto sans_git

rem --ff-only : la mise a jour ne fait qu'avancer la copie locale. Si des
rem fichiers du depot ont ete modifies a la main, elle refuse sans rien
rem casser, et la version presente est utilisee.
"%GIT%" -C "%DEPOT%" pull --ff-only
if errorlevel 1 goto echec_mise_a_jour
echo   OK : depot a jour.
goto lancer

:sans_git
echo   [ATTENTION] Git introuvable : %GIT%
echo   Mise a jour sautee, la version presente du script est utilisee.
goto lancer

:echec_mise_a_jour
echo   [ATTENTION] Mise a jour impossible (pas de reseau, ou fichiers du
echo   depot modifies a la main). La version presente du script est utilisee.
goto lancer

:lancer
echo.
if not exist "%SCRIPT%" goto sans_script
rem Le dossier sources\ est passe sans sa barre finale.
call "%SCRIPT%" "%SOURCES:~0,-1%"
endlocal
exit /b

rem ======================================================================
rem  Erreurs bloquantes
rem ======================================================================

:sans_depot
echo   [ERREUR] Depot introuvable : %DEPOT%
echo   Le cloner d'abord (module Git sous Windows), ou lancer directement
echo   installer_virtualbox.bat s'il est present dans ce dossier.
goto fin_erreur

:sans_script
echo   [ERREUR] Script introuvable dans le depot :
echo   %SCRIPT%
goto fin_erreur

:fin_erreur
echo.
pause
endlocal
exit /b 1
