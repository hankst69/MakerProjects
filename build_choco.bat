@echo off
set "_MAKER_ROOT=%~dp0"
rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source

call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  echo CHOCO already available
  goto :test_choco_success
)
set "_CHOCO_DIR=%_MAKER_ROOT%Choco"
if not exist "%_CHOCO_DIR%\build.bat" (
  echo.
  echo 1^) clone CHOCO
  call "%_MAKER_ROOT%\clone_choco.bat"
  rem defines: _CHOCO_DIR
  if "%_CHOCO_DIR%" EQU "" (echo error: cloning CHOCO &goto :EOF)
  if not exist "%_CHOCO_DIR%" (echo error: cloning CHOCO &goto :EOF)
)
if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
  echo.
  echo 2^) build CHOCO
  pushd %_CHOCO_DIR%
  call "%_CHOCO_DIR%\build.bat"
  popd
)
if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
  echo. error: building CHOCO failed
  goto :EOF
)

if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib" mkdir "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib"

set "_TOOLS_DIR=%_MAKER_ROOT%\.tools"
set "_TOOLS_CHOCO_DIR=%_TOOLS_DIR%\.choco"
if not exist "%_TOOLS_CHOCO_DIR%" mkdir "%_TOOLS_CHOCO_DIR%"
call xcopy /S /Y /Q "D:\GIT\HAN\MakerProjects\Choco\code_drop\temp\_PublishedApps\choco_merged" "%_TOOLS_CHOCO_DIR%" 1>NUL
echo @pushd "%_TOOLS_CHOCO_DIR%">"%_TOOLS_DIR%\choco.bat"
rem echo @call choco.exe %%* --allow-unofficial --debug>>"%_TOOLS_DIR%\choco.bat"
echo @call choco.exe %%* --allow-unofficial >>"%_TOOLS_DIR%\choco.bat"
echo @popd>>"%_TOOLS_DIR%\choco.bat"
call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%_TOOLS_DIR%;%_TOOLS_CHOCO_DIR%\bin"
call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_choco_success
echo. error: Choco build seems not to work
goto :EOF

:test_choco_success
echo.
rem call which choco.bat -l -d
set _VERSION_NR=
for /f "tokens=1,2,* delims=-" %%i in ('call choco --version') do set "_VERSION_NR=%%i-%%j-%%k"
echo choco %_VERSION_NR%
set _VERSION_NR=
