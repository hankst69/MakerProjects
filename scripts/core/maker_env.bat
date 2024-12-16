@echo off

pushd "%~dp0..\.."
set "MAKER_ROOT=%cd%"
popd
rem strip "\" suffix:
if "%MAKER_ROOT:~-1%" equ "\" set "MAKER_ROOT=%MAKER_ROOT:~0,-1%"

set "MAKER_TOOLS=%MAKER_ROOT%\tools"
set "MAKER_SCRIPTS=%MAKER_ROOT%\scripts\core"
set "MAKER_BUILD=%MAKER_ROOT%\scripts"
set "MAKER_PROJECTS=%MAKER_ROOT%\projects"
set "MAKER_BIN=%MAKER_ROOT%\.tools"

rem list env:
rem set MAKER_
