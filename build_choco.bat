@echo off
rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source
set "_MAKER_ROOT=%~dp0"
set "_TOOLS_DIR=%_MAKER_ROOT%\.tools"
set "_TOOLS_CHOCO_DIR=%_TOOLS_DIR%\.choco"

rem echo.
rem echo install CHOCO

call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem echo CHOCO already available
  goto :test_choco_success
)

if not exist "%_TOOLS_CHOCO_DIR%\choco.exe" (
  echo.
  echo building CHOCO
  call "%_MAKER_ROOT%\clone_choco.bat" --silent
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
	if "%VSCMD_VER:~0,2%" neq "16" (echo error: wrong VisualStudio version &goto :EOF)
    echo.
	call "%_CHOCO_DIR%\build.bat"
    popd
  )
  if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\choco.exe" (
    echo. error: building CHOCO failed
    goto :EOF
  )
  if not exist "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib" mkdir "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged\lib"

  if not exist "%_TOOLS_CHOCO_DIR%" mkdir "%_TOOLS_CHOCO_DIR%"
  call xcopy /S /Y /Q "%_CHOCO_DIR%\code_drop\temp\_PublishedApps\choco_merged" "%_TOOLS_CHOCO_DIR%" 1>NUL
  if not exist "%_TOOLS_CHOCO_DIR%\lib" mkdir "%_TOOLS_CHOCO_DIR%\lib"
) 

echo @pushd "%_TOOLS_CHOCO_DIR%">"%_TOOLS_DIR%\choco.bat"
rem echo @call choco.exe %%* --allow-unofficial --debug>>"%_TOOLS_DIR%\choco.bat"
echo @call choco.exe %%* --allow-unofficial >>"%_TOOLS_DIR%\choco.bat"
echo @popd>>"%_TOOLS_DIR%\choco.bat"

call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%_TOOLS_DIR%;%Path%"

call which choco.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: installing CHOCO failed
  goto :EOF
)

:test_choco_success
rem echo.
rem call which choco.bat -l -d
set _VERSION_NR=
for /f "tokens=1,2,* delims=-" %%i in ('call choco --version') do set "_VERSION_NR=%%i-%%j-%%k"
echo choco %_VERSION_NR%
set _VERSION_NR=
