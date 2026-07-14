@echo off
rem arg1: target-file '%1' '%~1' '%~dp1'
rem arg2: download-url  '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_FILE=
set _TARGET_DIR=
set _TARGET_NAME=
set _DOWNLOAD_URL=
set _DOWNLOAD_FILE_NAME=
set _DOWNLOAD_FILE_PATH=
set _DOWNLOAD_SILENT=
set _CHANGE_DIR=
set _RESET=
set _FREE_ARGS=
:param_loop
if /I "%~1" equ "--silent"       (set "_DOWNLOAD_SILENT=true" &shift &goto :param_loop)
if /I "%~1" equ "--changeDir"    (set "_CHANGE_DIR=true" &shift &goto :param_loop)
if /I "%~1" equ "--reset"        (set "_RESET=true" &shift &goto :param_loop)
if "%~1" neq "" if "%_TARGET_FILE%" equ "" (set "_TARGET_FILE=%~1" & set "_TARGET_DIR=%~dp1" & set "_TARGET_NAME=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_DOWNLOAD_URL%"  equ "" (set "_DOWNLOAD_URL=%~1" &set "_DOWNLOAD_FILE_NAME=%~nx1" &shift /1 &goto :param_loop)
if "%~1" neq "" (set "_FREE_ARGS=%_FREE_ARGS% %1"&shift &goto :param_loop)
if "%_TARGET_FILE%" equ "" echo error: missing argument 'target-file' &goto :Usage
if "%_DOWNLOAD_URL%" equ "" echo error: missing argument 'download-url' &goto :Usage

if "%_TARGET_DIR:~-1%" equ "\" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
if "%_TARGET_DIR:~-1%" equ "/" set "_TARGET_DIR=%_TARGET_DIR:~0,-1%"
set "_DOWNLOAD_FILE_PATH=%_TARGET_DIR%\%_DOWNLOAD_FILE_NAME%"
if "%MAKER_MSG_VERBOSE%" equ "" goto :Start
echo _TARGET_FILE        = "%_TARGET_FILE%"
echo _TARGET_DIR         = "%_TARGET_DIR%"
echo _TARGET_NAME        = "%_TARGET_NAME%"
echo _DOWNLOAD_URL       = "%_DOWNLOAD_URL%"
echo _DOWNLOAD_FILE_NAME = "%_DOWNLOAD_FILE_NAME%"
echo _DOWNLOAD_FILE_PATH = "%_DOWNLOAD_FILE_PATH%"
echo _DOWNLOAD_SILENT    = "%_DOWNLOAD_SILENT%"
echo _CHANGE_DIR         = "%_CHANGE_DIR%"
echo _RESET              = "%_RESET%"
echo _FREE_ARGS          = %_FREE_ARGS%
goto :Start

:Usage
echo.
echo USAGE: %_SCRIPT_NAME% target-file download-url [--changeDir] [--silent] [--reset]
echo.
goto :Exit

:Exit
if "%_CHANGE_DIR%" neq "" (if exist "%_TARGET_DIR%" cd "%_TARGET_DIR%")
if "%_CHANGE_DIR%" equ "" (cd "%_CURRENT_DIR%")
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
set _CURRENT_DIR=
set _TARGET_FILE=
set _TARGET_NAME=
set _TARGET_DIR=
set _DOWNLOAD_URL=
set _DOWNLOAD_FILE_NAME=
set _DOWNLOAD_FILE_PATH=
set _DOWNLOAD_SILENT=
set _CHANGE_DIR=
set _RESET=
set _FREE_ARGS=
goto :EOF

:Start
echo ************************************************************************************************************************
echo * downloading "%_TARGET_NAME%" into "%_TARGET_DIR%"
if "%_DOWNLOAD_SILENT%" equ "true" (
echo ************************************************************************************************************************ )
if exist "%_TARGET_FILE%" if "%_RESET%" equ "true" del /f /q "%_TARGET_FILE%"
if not exist "%_TARGET_FILE%" goto :Download
if "%_DOWNLOAD_SILENT%" neq "true" (
  echo * -^> "%_TARGET_FILE%" already exists in "%_TARGET_DIR%"
  rem echo *    to download "%_TARGET_FILE%" freshly, remove the file via: 'del /f /q "%_TARGET_FILE%"'
  rem echo *    ^(or you can delete all current content with 'rmdir /s /q "%_TARGET_DIR%"'^)
  echo ************************************************************************************************************************
  echo.
)
goto :Exit

:Download
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
rem call powershell -command "$webclient=new-object System.Net.WebClient; $webclient.DownloadFile('%_DOWNLOAD_URL%','%_TARGET_FILE%'); $webclient.DownloadFile('%_DOWNLOAD_URL%','%_TARGET_FILE%');" 2>nul
echo curl -o "%_TARGET_FILE%" "%_DOWNLOAD_URL%"
call curl -o "%_TARGET_FILE%" "%_DOWNLOAD_URL%" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8" -H "Accept-Encoding: gzip, deflate" -H "Accept-Language: en-US,en;q=0.5" -H "Connection: keep-alive" -H "Sec-Ch-Ua: 'Chromium';v='128', 'Not;A=Brand';v='24', 'Brave';v='128'" -H "Sec-Ch-Ua-Mobile: ?0" -H "Sec-Ch-Ua-Platform: 'Windows'" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: none" -H "Sec-Fetch-User: ?1" -H "Sec-Gpc: 1" -H "Upgrade-Insecure-Requests: 1" -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" --referer www.google.com --cookie key=val %_FREE_ARGS%
if not exist "%_TARGET_FILE%" (
  echo * -^> ERROR: download of "%_TARGET_FILE%" failed
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
