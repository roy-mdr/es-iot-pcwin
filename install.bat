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

rem REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_svcwkr /t REG_SZ /d """"%~dp0start.exe""" ""%njspath%"""
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_svcwkr /t REG_SZ /d """"%~dp0run-silent.bat""""

ECHO START /D "%~dp0" silent.exe %njspath% > %~dp0run-silent.bat

START /D "%~dp0" run-silent.bat

PAUSE
EXIT