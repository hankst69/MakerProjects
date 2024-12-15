@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_nodejs.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo NODE.JS %* available &exit /b 0

set "_NODE_BIN_DIR=%VSINSTALLDIR%\MSBuild\Microsoft\VisualStudio\NodeJs"
set "_NODE_TEST_OBJECT=%_NODE_BIN_DIR%\node.exe"
rem if not exist "%_NODE_TEST_OBJECT%" call %MAKER_ROOT%\build_nodejs.bat" %*
if not exist "%_NODE_TEST_OBJECT%" echo error: NODE.JS %* failed &exit /b 1
if exist "%_NODE_TEST_OBJECT%" set "PATH=%PATH%;%_NODE_BIN_DIR%"

call "%MAKER_SCRIPTS%\validate_nodejs.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU echo NODE.JS %* available &exit /b 0
echo error: NODE.JS %* failed
exit /b 1
