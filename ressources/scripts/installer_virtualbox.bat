@echo off
rem ======================================================================
rem  installer_virtualbox.bat -- Formation Linux (CID)
rem
rem  Reinstalle VirtualBox sur un poste "fige" (C: remis a zero a chaque
rem  redemarrage) et retrouve la VM conservee sur D:.
rem
rem  Utilisation :
rem    1. Placer ce fichier dans D:\PrenomNOM\sources\ avec :
rem         VC_redist.x64.exe
rem         VirtualBox-<version>-<build>-Win.exe
rem         Oracle_VirtualBox_Extension_Pack-<version>.vbox-extpack
rem    2. Double-cliquer sur le fichier. Si Windows demande une
rem       autorisation, repondre Oui.
rem
rem  Le script :
rem    - installe Visual C++ 2015-2022 x64, VirtualBox et l'Extension Pack
rem      en silencieux ;
rem    - regle le dossier des machines sur D:\PrenomNOM\VirtualBox ;
rem    - reenregistre la VM FormationLinux si elle existe deja.
rem
rem  Les messages sont volontairement sans accents : cmd.exe affiche les
rem  fichiers .bat dans la page de code OEM (850), et "chcp 65001" est
rem  source de bugs d'analyse des scripts sur certaines versions de
rem  Windows. L'ASCII pur fonctionne partout.
rem
rem  Precautions cmd.exe suivies dans ce fichier : aucune variable n'est
rem  modifiee puis lue dans un meme bloc entre parentheses (pas besoin de
rem  "delayed expansion"), les chemins sont toujours entre guillemets, et
rem  les codes retour sont recopies dans RC juste apres chaque commande.
rem ======================================================================

setlocal EnableExtensions
title Installation de VirtualBox - Formation Linux

rem ----------------------------------------------------------------------
rem  Parametres
rem ----------------------------------------------------------------------

rem Hash de la licence de l'Extension Pack (SHA256 du fichier de licence,
rem releve pour la version 7.2.20). Si Oracle change la licence, ce hash
rem change et l'installation silencieuse du pack echoue : le script
rem affiche alors la commande a lancer a la main.
set "LICENCE_EXTPACK=eb31505e56e9b4d0fbca139104da41ac6f6b98f8e78968bdf01b1f3da3c4f9ae"

rem Nom de la VM et emplacement de VBoxManage (dossier d'installation
rem par defaut de VirtualBox).
set "NOM_VM=FormationLinux"
set "VBOXMANAGE=%ProgramFiles%\Oracle\VirtualBox\VBoxManage.exe"

rem Dossier du script (D:\PrenomNOM\sources\, avec la barre finale)
rem et dossier parent (D:\PrenomNOM).
set "SOURCES=%~dp0"
for %%I in ("%~dp0..") do set "BASE=%%~fI"
set "DOSSIER_VMS=%BASE%\VirtualBox"
set "FICHIER_VM=%DOSSIER_VMS%\%NOM_VM%\%NOM_VM%.vbox"
set "JOURNAL=%SOURCES%installation_virtualbox.log"

rem Etat de chaque etape, affiche dans le resume final.
set "ETAT_VCREDIST=non fait"
set "ETAT_VIRTUALBOX=non fait"
set "ETAT_EXTPACK=non fait"
set "ETAT_DOSSIER=non fait"
set "ETAT_VM=non fait"
set "AVERTISSEMENTS=0"

echo ======================================================================
echo   Installation de VirtualBox - Formation Linux
echo ======================================================================
echo.
echo Dossier des installeurs : %SOURCES%
echo Dossier des machines    : %DOSSIER_VMS%
echo.

rem ----------------------------------------------------------------------
rem  Etape 1 : recherche des installeurs par motif
rem  (le script ne depend pas des numeros de version)
rem ----------------------------------------------------------------------

echo Recherche des installeurs dans %SOURCES%
call :trouver FICHIER_VCREDIST "VC_redist.x64*.exe"
call :trouver FICHIER_VIRTUALBOX "VirtualBox-*-Win.exe"
call :trouver FICHIER_EXTPACK "Oracle_VirtualBox_Extension_Pack-*.vbox-extpack"

if not defined FICHIER_VCREDIST goto erreur_fichiers
if not defined FICHIER_VIRTUALBOX goto erreur_fichiers
if not defined FICHIER_EXTPACK goto erreur_fichiers
echo.

rem ----------------------------------------------------------------------
rem  Etape 2 : Microsoft Visual C++ Redistributable (requis par VirtualBox)
rem  Codes retour acceptes : 0 = installe, 1638 = version plus recente deja
rem  presente, 3010 = installe, redemarrage demande (on ne redemarre pas :
rem  le poste fige perdrait tout).
rem
rem  Les installeurs sont lances avec start /wait (et non directement) :
rem  start passe par l'explorateur de Windows, qui affiche lui-meme la
rem  demande d'autorisation si l'installeur en a besoin. Lance directement
rem  depuis cmd, il echouerait avec le code 740 (elevation requise).
rem  start /wait attend la fin de l'installeur et recupere son code retour.
rem  Codes 740 et 1223 : autorisation impossible ou refusee.
rem ----------------------------------------------------------------------

echo [1/5] Installation de Visual C++ Redistributable...
start "" /wait "%FICHIER_VCREDIST%" /install /quiet /norestart
set "RC=%ERRORLEVEL%"
if "%RC%"=="740" goto vcredist_autorisation
if "%RC%"=="1223" goto vcredist_autorisation
if "%RC%"=="0" set "ETAT_VCREDIST=OK"
if "%RC%"=="1638" set "ETAT_VCREDIST=OK (deja present)"
if "%RC%"=="3010" set "ETAT_VCREDIST=OK"
if "%ETAT_VCREDIST%"=="non fait" goto erreur_vcredist
echo       %ETAT_VCREDIST%
echo.

rem ----------------------------------------------------------------------
rem  Etape 3 : VirtualBox
rem  --silent        : installation sans fenetre ni question ;
rem  --ignore-reboot : renvoie 0 meme si Windows demande un redemarrage ;
rem  --msi-log-file  : journal detaille, garde sur D: en cas de probleme.
rem  Si VBoxManage existe deja (script relance dans la meme session),
rem  l'installation est sautee.
rem ----------------------------------------------------------------------

echo [2/5] Installation de VirtualBox (1 a 3 minutes, patienter)...
if exist "%VBOXMANAGE%" goto virtualbox_deja_la
start "" /wait "%FICHIER_VIRTUALBOX%" --silent --ignore-reboot --msi-log-file "%JOURNAL%"
set "RC=%ERRORLEVEL%"
if "%RC%"=="740" goto virtualbox_autorisation
if "%RC%"=="1223" goto virtualbox_autorisation
if not "%RC%"=="0" goto erreur_virtualbox
if not exist "%VBOXMANAGE%" goto erreur_vboxmanage
set "ETAT_VIRTUALBOX=OK"
goto virtualbox_fin
:virtualbox_deja_la
set "ETAT_VIRTUALBOX=OK (deja installe)"
:virtualbox_fin
echo       %ETAT_VIRTUALBOX%
echo.

rem ----------------------------------------------------------------------
rem  Etape 4 : Extension Pack
rem  --replace         : remplace une version deja installee ;
rem  --accept-license= : accepte la licence sans question (hash ci-dessus).
rem  Un echec n'est pas bloquant : la VM fonctionne sans le pack.
rem  Les commandes VBoxManage sont lancees normalement, avec le compte du
rem  stagiaire (le reglage du dossier et la VM sont propres a ce compte) ;
rem  VBoxManage demande lui-meme l'autorisation si l'installation du pack
rem  en a besoin.
rem ----------------------------------------------------------------------

echo [3/5] Installation de l'Extension Pack...
"%VBOXMANAGE%" extpack install --replace --accept-license=%LICENCE_EXTPACK% "%FICHIER_EXTPACK%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto avertissement_extpack
set "ETAT_EXTPACK=OK"
goto extpack_fin
:avertissement_extpack
set "ETAT_EXTPACK=ECHEC (non bloquant, voir ci-dessus)"
set /a AVERTISSEMENTS+=1
echo.
echo   [ATTENTION] L'Extension Pack ne s'est pas installe (code %RC%).
echo   Cause probable : Oracle a modifie la licence, le hash du script
echo   n'est plus le bon. Pour l'installer a la main, double-cliquer sur
echo   le fichier .vbox-extpack, ou taper dans une invite de commandes :
echo.
echo   "%VBOXMANAGE%" extpack install --replace "%FICHIER_EXTPACK%"
echo.
echo   puis accepter la licence en tapant y. Si Windows demande une
echo   autorisation, repondre Oui.
:extpack_fin
echo       %ETAT_EXTPACK%
echo.

rem ----------------------------------------------------------------------
rem  Etape 5 : dossier des machines virtuelles
rem  Le reglage est stocke dans le profil Windows (sur C:, efface a chaque
rem  redemarrage) : on le refait a chaque fois.
rem ----------------------------------------------------------------------

echo [4/5] Reglage du dossier des machines : %DOSSIER_VMS%
if not exist "%DOSSIER_VMS%\" mkdir "%DOSSIER_VMS%"
"%VBOXMANAGE%" setproperty machinefolder "%DOSSIER_VMS%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto erreur_dossier
set "ETAT_DOSSIER=OK"
echo       %ETAT_DOSSIER%
echo.

rem ----------------------------------------------------------------------
rem  Etape 6 : reenregistrement de la VM
rem  - VM absente (premiere seance) : rien a faire, on la creera ;
rem  - VM deja connue de VirtualBox : rien a faire ;
rem  - sinon : VBoxManage registervm.
rem ----------------------------------------------------------------------

echo [5/5] Recherche de la VM %NOM_VM%...
if not exist "%FICHIER_VM%" goto vm_absente
"%VBOXMANAGE%" showvminfo "%NOM_VM%" >nul 2>&1
if not errorlevel 1 goto vm_deja_enregistree
"%VBOXMANAGE%" registervm "%FICHIER_VM%"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto avertissement_vm
set "ETAT_VM=OK (VM reenregistree)"
goto vm_fin
:vm_absente
set "ETAT_VM=pas encore de VM (normal a la premiere seance)"
goto vm_fin
:vm_deja_enregistree
set "ETAT_VM=OK (VM deja enregistree)"
goto vm_fin
:avertissement_vm
set "ETAT_VM=ECHEC (non bloquant, voir ci-dessus)"
set /a AVERTISSEMENTS+=1
echo.
echo   [ATTENTION] La VM n'a pas pu etre enregistree (code %RC%).
echo   Dans VirtualBox : menu Machine, Ajouter..., puis choisir le fichier
echo   %FICHIER_VM%
:vm_fin
echo       %ETAT_VM%
echo.

rem ----------------------------------------------------------------------
rem  Resume
rem ----------------------------------------------------------------------

call :resume
if not "%AVERTISSEMENTS%"=="0" echo Termine, mais avec des avertissements : lire les messages ci-dessus.
if "%AVERTISSEMENTS%"=="0" echo Termine. VirtualBox est pret : lancer "Oracle VirtualBox" depuis le menu Demarrer.
echo.
pause
endlocal
exit /b 0

rem ======================================================================
rem  Erreurs bloquantes : message, resume, pause, code retour 1
rem ======================================================================

:erreur_fichiers
echo.
echo [ERREUR] Il manque au moins un fichier dans %SOURCES%
echo   Fichiers attendus (le numero de version peut varier) :
echo     VC_redist.x64.exe
echo     VirtualBox-7.2.20-175154-Win.exe
echo     Oracle_VirtualBox_Extension_Pack-7.2.20.vbox-extpack
echo   Les telecharger (liens dans l'annexe d'installation), les placer
echo   dans ce dossier, puis relancer le script.
goto fin_erreur

:erreur_vcredist
echo.
echo [ERREUR] L'installation de Visual C++ a echoue (code %RC%).
echo   Essayer de lancer %FICHIER_VCREDIST% par un double-clic.
set "ETAT_VCREDIST=ECHEC (code %RC%)"
goto fin_erreur

:vcredist_autorisation
set "ETAT_VCREDIST=ECHEC (autorisation refusee, code %RC%)"
goto erreur_autorisation

:virtualbox_autorisation
set "ETAT_VIRTUALBOX=ECHEC (autorisation refusee, code %RC%)"
goto erreur_autorisation

:erreur_autorisation
echo.
echo [ERREUR] Windows n'a pas donne l'autorisation d'installer (code %RC%).
echo   Relancer le script et, quand Windows demande une autorisation,
echo   repondre Oui.
goto fin_erreur

:erreur_virtualbox
echo.
echo [ERREUR] L'installation de VirtualBox a echoue (code %RC%).
echo   Journal detaille : %JOURNAL%
echo   Essayer d'installer VirtualBox par un double-clic sur
echo   %FICHIER_VIRTUALBOX%
set "ETAT_VIRTUALBOX=ECHEC (code %RC%)"
goto fin_erreur

:erreur_vboxmanage
echo.
echo [ERREUR] VirtualBox semble installe, mais ce fichier est introuvable :
echo   %VBOXMANAGE%
echo   VirtualBox a peut-etre ete installe dans un autre dossier.
set "ETAT_VIRTUALBOX=ECHEC (VBoxManage introuvable)"
goto fin_erreur

:erreur_dossier
echo.
echo [ERREUR] Impossible de regler le dossier des machines (code %RC%).
echo   Dans VirtualBox : menu Fichier, Parametres, General, puis choisir
echo   %DOSSIER_VMS%
set "ETAT_DOSSIER=ECHEC (code %RC%)"
goto fin_erreur

:fin_erreur
echo.
call :resume
echo Installation interrompue. Prevenir le formateur si le probleme persiste.
echo.
pause
endlocal
exit /b 1

rem ======================================================================
rem  Sous-programmes
rem ======================================================================

rem ----------------------------------------------------------------------
rem  :trouver VARIABLE "motif"
rem  Cherche le motif dans le dossier du script et met le chemin complet
rem  dans VARIABLE (vide si aucun fichier). Une boucle "for" sur un motif
rem  sans correspondance ne fait aucun tour : la variable reste vide.
rem  Si plusieurs fichiers correspondent, le dernier trouve est garde et
rem  un avertissement est affiche.
rem ----------------------------------------------------------------------
:trouver
set "%~1="
set "NB_TROUVES=0"
for %%F in ("%SOURCES%%~2") do (
    set "%~1=%%~fF"
    set /a NB_TROUVES+=1
)
if "%NB_TROUVES%"=="0" echo   [MANQUANT] %~2
if "%NB_TROUVES%"=="0" exit /b 1
call echo   [OK]       %%%~1%%
if not "%NB_TROUVES%"=="1" echo   [ATTENTION] %NB_TROUVES% fichiers correspondent a %~2 : garder une seule version.
exit /b 0

rem ----------------------------------------------------------------------
rem  :resume -- affiche l'etat de chaque etape
rem ----------------------------------------------------------------------
:resume
echo ======================================================================
echo   Resume
echo ======================================================================
echo   Visual C++ Redistributable : %ETAT_VCREDIST%
echo   VirtualBox                 : %ETAT_VIRTUALBOX%
echo   Extension Pack             : %ETAT_EXTPACK%
echo   Dossier des machines       : %ETAT_DOSSIER%
echo   Machine virtuelle          : %ETAT_VM%
echo ======================================================================
echo.
exit /b 0
