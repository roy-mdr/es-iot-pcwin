@ECHO OFF

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
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs"
exit /B


:ISADMIN

CLS

REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_svcwkr

PAUSE

EXIT