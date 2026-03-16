@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: download-url  '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_DIR=
set _DOWNLOAD_URL=
set _DOWNLOAD_FILE_NAME=
set _DOWNLOAD_FILE_PATH=
set _DOWNLOAD_SILENT=
set _CHANGE_DIR=
set _FREE_ARGS=
:param_loop
if /I "%~1" equ "--silent"       (set "_DOWNLOAD_SILENT=true" &shift &goto :param_loop)
if /I "%~1" equ "--changeDir"    (set "_CHANGE_DIR=true" &shift &goto :param_loop)
if "%~1" neq "" if "%_TARGET_DIR%" equ "" (set "_TARGET_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_DOWNLOAD_URL%"  equ "" (set "_DOWNLOAD_URL=%~1" &set "_DOWNLOAD_FILE_NAME=%~nx1" &shift /1 &goto :param_loop)
if "%~1" neq "" (set "_FREE_ARGS=%_FREE_ARGS% %1"&shift &goto :param_loop)
if "%_TARGET_DIR%" equ "" echo error: missing argument 'target-folder' &goto :Usage
if "%_DOWNLOAD_URL%" equ "" echo error: missing argument 'download-url' &goto :Usage
if "%_TARGET_DIR:~-1%" equ "\" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
if "%_TARGET_DIR:~-1%" equ "/" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
set "_DOWNLOAD_FILE_PATH=%_TARGET_DIR%\%_DOWNLOAD_FILE_NAME%"
if "%MAKER_ENV_VERBOSE%" equ "" goto :Start
echo _TARGET_DIR         = "%_TARGET_DIR%"
echo _DOWNLOAD_URL       = "%_DOWNLOAD_URL%"
echo _DOWNLOAD_FILE_NAME = "%_DOWNLOAD_FILE_NAME%"
echo _DOWNLOAD_FILE_PATH = "%_DOWNLOAD_FILE_PATH%"
echo _DOWNLOAD_SILENT    = "%_DOWNLOAD_SILENT%"
echo _CHANGE_DIR         = "%_CHANGE_DIR%"
echo _FREE_ARGS          = %_FREE_ARGS%
goto :Start

:Usage
echo.
echo USAGE: %_SCRIPT_NAME% target-folder download-url [--changeDir] [--silent]
echo.
goto :Exit

:Exit
if "%_CHANGE_DIR%" neq "" (if exist "%_TARGET_DIR%" cd "%_TARGET_DIR%")
if "%_CHANGE_DIR%" equ "" (cd "%_CURRENT_DIR%")
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
set _CURRENT_DIR=
set _TARGET_DIR=
set _DOWNLOAD_URL=
set _DOWNLOAD_FILE_NAME=
set _DOWNLOAD_FILE_PATH=
set _DOWNLOAD_SILENT=
set _CHANGE_DIR=
set _FREE_ARGS=
goto :EOF

:Start
rem if "%_DOWNLOAD_SILENT%" neq "true" (
  echo ************************************************************************************************************************
  echo * downloading "%_DOWNLOAD_FILE_NAME%" into "%_TARGET_DIR%"
  if "%_DOWNLOAD_SILENT%" equ "true" (
  echo ************************************************************************************************************************ )
rem )
if not exist "%_DOWNLOAD_FILE_PATH%" goto :Download
if "%_DOWNLOAD_SILENT%" neq "true" (
  echo * -^> "%_DOWNLOAD_FILE_NAME%" already exists in "%_TARGET_DIR%"
  rem echo *    to download "%_DOWNLOAD_FILE_NAME%" freshly, remove the file via: 'del /f /q "%_DOWNLOAD_FILE_PATH%"'
  rem echo *    ^(or you can delete all current content with 'rmdir /s /q "%_TARGET_DIR%"'^)
  echo ************************************************************************************************************************
  echo.
)
goto :Exit

:Download
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
call powershell -command "$webclient=new-object System.Net.WebClient; $webclient.DownloadFile('%_DOWNLOAD_URL%','%_DOWNLOAD_FILE_PATH%'); $webclient.DownloadFile('%_DOWNLOAD_URL%','%_DOWNLOAD_FILE_PATH%');" 2>nul
if not exist "%_DOWNLOAD_FILE_PATH%" (
  echo * -^> ERROR: download of "%_DOWNLOAD_FILE_NAME%" failed
  echo ************************************************************************************************************************
  echo.
  exit /b 77
) else (
  if "%_DOWNLOAD_SILENT%" neq "true" (
    echo * -^> DOWNLOAD DONE
    echo ************************************************************************************************************************
  )
)
goto :Exit
