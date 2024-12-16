@echo off
set "MAKER_BUILD=%~dp0"
call "%MAKER_BUILD%\validate_nodejs.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit

set "_NODE_BIN_DIR=%VSINSTALLDIR%\MSBuild\Microsoft\VisualStudio\NodeJs"
set "_NODE_TEST_OBJECT=%_NODE_BIN_DIR%\node.exe"
rem if not exist "%_NODE_TEST_OBJECT%" call "%MAKER_BUILD%\build_nodejs.bat" %*
if not exist "%_NODE_TEST_OBJECT%" echo error: NODEJS failed &exit /b 1
if exist "%_NODE_TEST_OBJECT%" set "PATH=%PATH%;%_NODE_BIN_DIR%"

:Exit
call "%MAKER_BUILD%\validate_nodejs.bat" %*
