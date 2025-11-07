@rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source
@echo off
set "_BCO_START_DIR=%cd%"
call "%~dp0\maker_env.bat" %*
if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem init with command line arguments
set "_CHOCO_VERSION=%MAKER_ENV_VERSION%"
rem apply defaults
rem if "%_CHOCO_VERSION%"    equ "" set _CHOCO_VERSION=2.2.2

rem take shortcut if possible
set ERRORLEVEL=
call "%MAKER_BUILD%\validate_choco.bat" %_CHOCO_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
rem validate specifies:
rem CHOCO_DIR=%MAKER_BIN%\.choco
rem ChocolateyInstall=%CHOCO_DIR%


rem Install Choco via PowerShell script 'https://community.chocolatey.org/install.ps1' obeying the define ChocolateyInstall directorty location
rem set "ChocolateyInstall=C:\ProgramData\chocolatey"
rem set "ChocolateyInstall=%LOCALAPPDATA%\chocolatey"
rem ChocolateyInstall=%CHOCO_DIR%
rem call powershell -noprofile -command "$InstallDir='%CHOCO_DIR%'; $env:ChocolateyInstall='$InstallDir'; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'));"


set "_CHOCO_BIN=%CHOCO_DIR%"

rem take shortcut if possible
set ERRORLEVEL=
call "%MAKER_BUILD%\validate_choco.bat" %_CHOCO_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on


rem install/build...

rem echo.
rem echo install CHOCO

if not exist "%_CHOCO_BIN%\choco.exe" (
  echo.
  echo building CHOCO
  call "%MAKER_BUILD%\clone_choco.bat" --silent
  rem defines: _CHOCO_DIR
  if "%_CHOCO_DIR%" EQU "" (echo error: cloning CHOCO &goto :EOF)
  if not exist "%_CHOCO_DIR%" (echo error: cloning CHOCO &goto :EOF)
  if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
    pushd %_CHOCO_DIR%
	echo.
	echo rebuilding CHOCO from sources
    echo.
	echo *** THIS REQUIRES VisualStudio 2019 ^(currently^) ***
	echo *** THIS REQUIRES running in an ELEVATED SHELL ^(currently^) ***
	call "%MAKER_BUILD%\validate_msvs.bat" 2019
	if %ERRORLEVEL% NEQ 0 (
		echo error: wrong VisualStudio version 
		goto :EOF
	)
    echo.
	call "%_CHOCO_DIR%\build.bat"
    popd
  )
  if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
    echo. error: building CHOCO failed
    goto :EOF
  )
  if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib" mkdir "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib"

  if not exist "%_CHOCO_BIN%" mkdir "%_CHOCO_BIN%"
  call xcopy /S /Y /Q "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged" "%_CHOCO_BIN%" 1>NUL
  if not exist "%_CHOCO_BIN%\lib" mkdir "%_CHOCO_BIN%\lib"
) 

echo @pushd "%_CHOCO_BIN%">"%MAKER_BIN%\choco.bat"
rem echo @call choco.exe %%* --allow-unofficial --debug>>"%MAKER_BIN%\choco.bat"
echo @call choco.exe %%* --allow-unofficial >>"%MAKER_BIN%\choco.bat"
echo @popd>>"%MAKER_BIN%\choco.bat"

call "%MAKER_BUILD%\validate_choco.bat" %_CHOCO_VERSION% 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%MAKER_BIN%;%Path%"


:exit_script
cd /d "%_BCO_START_DIR%"
"%MAKER_BUILD%\validate_choco.bat" %_CHOCO_VERSION%
