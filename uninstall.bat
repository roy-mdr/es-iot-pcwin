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

ECHO ===== KILLING PROCESS =====

TASKKILL /F /IM es_user_svcwkr.exe /T

ECHO.



ECHO ===== UNINSTALLING PROTOCOL HANDLER =====

REG DELETE "HKEY_CLASSES_ROOT\esustenta" /f

REG DELETE "HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /v "%~dp0res\es_protocol_handler.exe.ApplicationCompany"
REG DELETE "HKEY_CURRENT_USER\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache"  /f  /v "%~dp0res\es_protocol_handler.exe.FriendlyAppName"

ECHO.



ECHO ===== UNINSTALLING AUTO-RUN USER SERVICE (FOR ALL USERS) =====

REG DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /f /v es_user_svcwkr

ECHO.



ECHO ===== CLEANING FILES =====

REM DEL /F %~dp0service-install.js
REM DEL /F %~dp0service-uninstall.js
REM DEL /F %~dp0test-indexjs.bat
DEL /F %~dp0run-es_user_svcwkr.bat

ECHO.



ECHO ===== ALL DONE =====

PAUSE



EXIT