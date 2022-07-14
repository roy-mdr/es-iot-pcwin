@ECHO OFF

IF [%1]==[] (
  GOTO CHECKNODEJS
) ELSE (
  GOTO GOTPATH
)

:CHECKNODEJS
node -v >nul 2>&1
IF %errorLevel% == 0 (
  ECHO NODE.JS INSTALLED
  SET njspath=node
  ECHO Path: %njspath%
  GOTO :CHECKADMIN
  EXIT
) ELSE (
  ECHO NODE.JS NOT INSTALLED
  GOTO ASKPATH
  EXIT
)

:ASKPATH
CLS
SET /P njspath=Drag and drop "node.exe" from NodeJS install folder here: 
SET njspath=%njspath:"=%
ECHO Path: %njspath%
GOTO :CHECKADMIN

:GOTPATH
SET njspath=%1
ECHO GOT PATH: %njspath%
GOTO :CHECKADMIN


:CHECKADMIN
CLS
:: Check for ADMIN Privileges
echo Derechos de Administrador necesarios. Revisando permisos...
net session >nul 2>&1
if %errorLevel% == 0 (
  GOTO ISADMIN
) else (
  GOTO ISNOTADMIN
)


:ISNOTADMIN
echo Derechos denegados.
cls
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "cmd", "/c """"%~s0"" ""%njspath%""""", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B


:ISADMIN

CLS

SET /P clid=Client ID for this PC: 

ECHO.

ECHO ===== RENAMING NODE-WINDOWS INSTALLERS =====

powershell -Command "(gc %~dp0src\config.json) -replace '<PC_CLID>', '%clid%' | Out-File -encoding ASCII %~dp0config.json"
powershell -Command "(gc %~dp0src\service-install.js) -replace '<APP_PATH>', ([RegEx]::Escape('%~dp0') + 'index.js') | Out-File -encoding ASCII %~dp0service-install.js"
powershell -Command "(gc %~dp0src\service-uninstall.js) -replace '<APP_PATH>', ([RegEx]::Escape('%~dp0') + 'index.js') | Out-File -encoding ASCII %~dp0service-uninstall.js"

ECHO.



ECHO ===== SETTING UP SERVICE BATCH FILES =====

ECHO START "" %njspath% %~dp0index.js > %~dp0test-indexjs.bat
ECHO START "" %njspath% %~dp0service-install.js > %~dp0install-service.bat
ECHO START "" %njspath% %~dp0service-uninstall.js > %~dp0uninstall-service.bat

IF %njspath% EQU "node" (

    ECHO START "" npm install > %~dp0install-npm.bat

  ) ELSE (

    rem GET NPM PATH

    FOR /F "delims=" %%I IN ("%njspath%") DO (
      SET nodefiledrive=%%~dI
      SET nodefilepath=%%~pI
      SET nodefilename=%%~nI
      SET nodefileextension=%%~xI

      ECHO START "" %%~dpInpm install > %~dp0install-npm.bat
    )

)

ECHO.



ECHO ===== INSTALLING PROTOCOL HANDLER =====

rem REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_SZ"     /v ""                       /d "URL:esustenta Protocol"
    REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_SZ"     /v "URL Protocol"           /d ""
rem REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_DWORD"  /v "UseOriginalUrlEncoding" /d "1"
    REG ADD "HKEY_CLASSES_ROOT\esustenta\DefaultIcon"         /f  /t "REG_SZ"     /v ""                       /d "\"%~dp0res\es_protocol_handler.exe\",1"
    REG ADD "HKEY_CLASSES_ROOT\esustenta\shell\open\command"  /f  /t "REG_SZ"     /v ""                       /d "\"%~dp0res\es_protocol_handler.exe\" \"%%1\""

REG ADD "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /t "REG_SZ" /v "%~dp0res\es_protocol_handler.exe.ApplicationCompany" /d "Estudio Sustenta"
REG ADD "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /t "REG_SZ" /v "%~dp0res\es_protocol_handler.exe.FriendlyAppName"    /d "Estudio Sustenta App"

ECHO.

GOTO ASKNPMINSTALL



:ASKNPMINSTALL
SET /P npminst=Install NPM packages? (Y/N): 
IF /I "%npminst%" EQU "Y" GOTO NPMINSTALL
IF /I "%npminst%" EQU "N" GOTO ASKUSERINSTALL
GOTO ASKNPMINSTALL



:NPMINSTALL
ECHO.
ECHO ===== INSTALLING NPM PACKAGES =====
START /WAIT /D "%~dp0" install-npm.bat

ECHO.

GOTO ASKSVCINSTALL



:ASKSVCINSTALL
SET /P svcinst=Install Windows service? (Y/N): 
IF /I "%svcinst%" EQU "Y" GOTO SVCINSTALL
IF /I "%svcinst%" EQU "N" GOTO ASKUSERINSTALL
GOTO ASKSVCINSTALL



:SVCINSTALL
ECHO.
ECHO ===== INSTALLING WINDOWS SERVICE =====
START /WAIT /D "%~dp0" install-service.bat

ECHO.

GOTO ASKUSERINSTALL



:ASKUSERINSTALL
SET /P userinst=Install autorun for users? (Y/N): 
IF /I "%userinst%" EQU "Y" GOTO USERINSTALL
IF /I "%userinst%" EQU "N" GOTO ALLDONE
GOTO ASKUSERINSTALL



:USERINSTALL
ECHO.
ECHO ===== INSTALLING AUTO-RUN USER SERVICE (FOR ALL USERS) =====

rem REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_user_svcwkr /t REG_SZ /d """"%~dp0es_user_svcwkr.exe""" ""%njspath%"""
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_user_svcwkr /t REG_SZ /d """"%~dp0run-es_user_svcwkr.bat""""

ECHO START /D "%~dp0" es_user_svcwkr.exe %njspath% > %~dp0run-es_user_svcwkr.bat

ECHO.



ECHO ===== RUNNING PROCESS =====

START /D "%~dp0" run-es_user_svcwkr.bat

ECHO.

GOTO ALLDONE



:ALLDONE
ECHO.
ECHO ===== ALL DONE =====

PAUSE

EXIT