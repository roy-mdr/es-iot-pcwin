@ECHO OFF
TITLE Silent Start

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