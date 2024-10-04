@echo off
set "_MAKER_ROOT=%~dp0"
rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source

echo.
echo 1) clone CHOCO
call "%_MAKER_ROOT%\clone_choco.bat"
rem defines: _CHOCO_DIR
if "%_CHOCO_DIR%" EQU "" (echo cloning CHOCO &goto :EOF)
if not exist "%_CHOCO_DIR%" (echo cloning CHOCO &goto :EOF)


echo.
echo 2) build CHOCO
call which choco.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_choco_success
if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
  pushd %_CHOCO_DIR%
  call "%_CHOCO_DIR%\build.bat"
  popd
)
if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
  echo. error: building Choco failed
  goto :EOF
)
if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib" mkdir "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib"
set "Path=%Path%;%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged"
call which choco.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_choco_success
echo. error: Choco build seems not to work
goto :EOF
:test_choco_success
echo.
set _VERSION_NR=
for /f "tokens=1,2,* delims=-" %%i in ('call choco --version') do set "_VERSION_NR=%%i-%%j-%%k"
echo choco %_VERSION_NR%
set _VERSION_NR=
