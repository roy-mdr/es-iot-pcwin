@ECHO OFF

REM THIS BAT WILL BE CONVERTED TO .EXE WITH "Invisible application" MODE

TITLE Silent Estudio Sustenta service worker (user)

IF [%1]==[] (
  GOTO ASKPATH
) ELSE (
  GOTO GOTPATH
)

:ASKPATH
ECHO soriii > nope.txt
EXIT

:GOTPATH
SET njspath=%1
%njspath% index.js
EXIT