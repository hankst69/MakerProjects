@echo off

set "MAKER_ROOT=%~dp0"
rem strip "\scripts\" suffix:
if "%MAKER_ROOT:~-9%" equ "\scripts\" set "MAKER_ROOT=%MAKER_ROOT:~0,-9%"
rem strip "\" suffix:
if "%MAKER_ROOT:~-1%" equ "\" set "MAKER_ROOT=%MAKER_ROOT:~0,-1%"

set "MAKER_TOOLS=%MAKER_ROOT%\tools"
set "MAKER_SCRIPTS=%MAKER_ROOT%\scripts"
set "MAKER_PROJECTS=%MAKER_ROOT%\projects"
set "MAKER_BIN=%MAKER_ROOT%\.tools"

rem list env:
set MAKER_
