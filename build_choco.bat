@echo off
set "_MAKER_ROOT=%~dp0"
rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source

echo.
echo 1) clone CHOCO
call "%_MAKER_ROOT%\clone_choco.bat"
rem defines: _CHOCO_DIR
rem defines: _CHOCO_SOURCES_DIR
if "%_CHOCO_DIR%" EQU "" (echo cloning CHOCO &goto :EOF)
if "%_CHOCO_SOURCES_DIR%" EQU "" (echo cloning CHOCO &goto :EOF)
if not exist "%_CHOCO_DIR%" (echo cloning CHOCO &goto :EOF)
if not exist "%_CHOCO_SOURCES_DIR%" (echo cloning CHOCO &goto :EOF)

echo.
echo 2) build CHOCO
pushd %_CHOCO_SOURCES_DIR%
call "%_CHOCO_SOURCES_DIR%\build.bat"
echo.
popd
rem if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
rem   echo QT is not installed
rem   goto :EOF
rem )
