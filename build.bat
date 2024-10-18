@echo off
if not exist "%~dpn0_%~1.bat" echo error: unknown tool '%~1' ^("%~n0_%~1.bat" does not exist^)
if not exist "%~dpn0_%~1.bat" goto :EOF
call "%~dpn0_%~1.bat" "%~2" "%~3" "%~4" "%~5" "%~6"