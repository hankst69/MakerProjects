@rem https://github.com/chocolatey/choco?tab=readme-ov-file#compiling--building-source
@echo off
call "%~dp0\maker_env.bat" %*

set "_CHOCO_BIN=%MAKER_BIN%\.choco"

rem echo.
rem echo install CHOCO

call "%MAKER_BUILD%\validate_choco.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  rem echo CHOCO already available
  goto :test_choco_success
)

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

call "%MAKER_BUILD%\validate_choco.bat"
if %ERRORLEVEL% NEQ 0 set "Path=%MAKER_BIN%;%Path%"

:test_choco_success
call "%MAKER_BUILD%\validate_choco.bat"
if %ERRORLEVEL% NEQ 0 echo error: installing CHOCO failed
