@ECHO OFF

IF [%1]==[] (
  GOTO ASKPATH
) ELSE (
  GOTO GOTPATH
)

:ASKPATH
SET /P njspath=Drag and drop "node.exe" from NodeJS install folder here: 
set njspath=%njspath:"=%
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

ECHO ===== INSTALLING PROTOCOL HANDLER =====

rem REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_SZ"     /v ""                       /d "URL:esustenta Protocol"
    REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_SZ"     /v "URL Protocol"           /d ""
rem REG ADD "HKEY_CLASSES_ROOT\esustenta"                     /f  /t "REG_DWORD"  /v "UseOriginalUrlEncoding" /d "1"
    REG ADD "HKEY_CLASSES_ROOT\esustenta\DefaultIcon"         /f  /t "REG_SZ"     /v ""                       /d "\"%~dp0res\es_protocol_handler.exe\",1"
    REG ADD "HKEY_CLASSES_ROOT\esustenta\shell\open\command"  /f  /t "REG_SZ"     /v ""                       /d "\"%~dp0res\es_protocol_handler.exe\" \"%%1\""

REG ADD "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /t "REG_SZ" /v "%~dp0res\es_protocol_handler.exe.ApplicationCompany" /d "Estudio Sustenta"
REG ADD "HKEY_CLASSES_ROOT\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /t "REG_SZ" /v "%~dp0res\es_protocol_handler.exe.FriendlyAppName"    /d "Estudio Sustenta App"

ECHO.



ECHO ===== INSTALLING AUTO-RUN USER SERVICE =====

rem REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_svcwkr /t REG_SZ /d """"%~dp0start.exe""" ""%njspath%"""
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_svcwkr /t REG_SZ /d """"%~dp0run-silent.bat""""

ECHO START /D "%~dp0" silent.exe %njspath% > %~dp0run-silent.bat

START /D "%~dp0" run-silent.bat

ECHO.



ECHO ===== ALL DONE =====

PAUSE



EXIT