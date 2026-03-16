@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: download-url  '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_DIR=
set _ARCHIVE_PATH=
set _EXTRACT_SILENT=
set _CHANGE_DIR=
set _FREE_ARGS=
:param_loop
if /I "%~1" equ "--silent"       (set "_EXTRACT_SILENT=true" &shift &goto :param_loop)
if /I "%~1" equ "--changeDir"    (set "_CHANGE_DIR=true" &shift &goto :param_loop)
if "%~1" neq "" if "%_TARGET_DIR%" equ "" (set "_TARGET_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_ARCHIVE_PATH%"  equ "" (set "_ARCHIVE_PATH=%~1" &set "_ARCHIVE_NAME=%~nx1" &shift /1 &goto :param_loop)
if "%~1" neq "" (set "_FREE_ARGS=%_FREE_ARGS% %1"&shift &goto :param_loop)
if "%_TARGET_DIR%" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%_ARCHIVE_PATH%" equ "" echo error: missing argument 'archive-path' &goto :Usage
if "%_TARGET_DIR:~-1%" equ "\" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
if "%_TARGET_DIR:~-1%" equ "/" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
if "%MAKER_ENV_VERBOSE%" equ "" goto :Start
echo _TARGET_DIR       = "%_TARGET_DIR%"
echo _ARCHIVE_PATH     = "%_ARCHIVE_PATH%"
echo _ARCHIVE_NAME     = "%_ARCHIVE_NAME%"
echo _EXTRACT_SILENT   = "%_EXTRACT_SILENT%"
echo _CHANGE_DIR       = "%_CHANGE_DIR%"
echo _FREE_ARGS        = %_FREE_ARGS%
goto :Start

:Usage
echo.
echo USAGE: %_SCRIPT_NAME% target-folder archive-path [--changeDir] [--silent]
echo.
goto :Exit

:Exit
if "%_CHANGE_DIR%" neq "" (if exist "%_TARGET_DIR%" cd "%_TARGET_DIR%")
if "%_CHANGE_DIR%" equ "" (cd "%_CURRENT_DIR%")
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
set _CURRENT_DIR=
set _TARGET_DIR=
set _ARCHIVE_NAME=
set _ARCHIVE_PATH=
set _EXTRACT_SILENT=
set _CHANGE_DIR=
set _FREE_ARGS=
goto :EOF

:Start
rem if "%_EXTRACT_SILENT%" neq "true" (
  echo.******************************************************************************************
  echo.* extracting '%_ARCHIVE_NAME%' into '%_TARGET_DIR%'
  echo.******************************************************************************************
rem )
if not exist "%_TARGET_DIR%" goto :Extract
setlocal EnableDelayedExpansion
set _dir_is_empty=true
for /f %%i in ('dir /a /b "%_TARGET_DIR%"') do set _dir_is_empty=false
if "!_dir_is_empty!" neq "true" (
  endlocal
  if "%_EXTRACT_SILENT%" neq "true" (
    rem echo ******************************************************************************************
    echo * '%_TARGET_DIR%' already contains data
    echo * remove the target folder via: 'rmdir /s /q "%_TARGET_DIR%"'
    echo * to force fresh extraction of '%_ARCHIVE_NAME%' into '%_TARGET_DIR%'
    echo ******************************************************************************************
    echo.
  )
  goto :Exit
)
endlocal
goto :Extract

:Extract
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
if not exist "%_ARCHIVE_PATH%" (
  rem echo ******************************************************************************************
  echo * ERROR: extraction of "%_ARCHIVE_NAME%" failed
  echo *        the archive "%_ARCHIVE_PATH%" does not exist 
  echo ******************************************************************************************
  exit /b 78
)
call powershell -command "Expand-Archive -Force '%_ARCHIVE_PATH%' '%_TARGET_DIR%'"
setlocal EnableDelayedExpansion
set _dir_is_empty=true
for /f %%i in ('dir /a /b "%_TARGET_DIR%"') do set _dir_is_empty=false
if "!_dir_is_empty!" equ "true" (
  rem echo ******************************************************************************************
  echo * ERROR: extraction of "%_ARCHIVE_NAME%" failed
  echo ******************************************************************************************
  exit /b 79
)
if "%_EXTRACT_SILENT%" neq "true" (
  echo * EXTRACTION DONE
  echo ******************************************************************************************
)

endlocal
goto :Exit
