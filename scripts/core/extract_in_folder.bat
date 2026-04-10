@echo off
rem arg1: target-folder '%1' '%~1' '%~dp1'
rem arg2: archive_file_or_folder '%2' '%~2' '%~dp2'
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
set "_CURRENT_DIR=%cd%"
set _TARGET_DIR=
set _ARCHIVE_PATH=
set _ARCHIVE_NAME=
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
if "%MAKER_MSG_VERBOSE%" equ "" goto :Start
echo _TARGET_DIR       = "%_TARGET_DIR%"
echo _ARCHIVE_PATH     = "%_ARCHIVE_PATH%"
echo _ARCHIVE_NAME     = "%_ARCHIVE_NAME%"
echo _EXTRACT_SILENT   = "%_EXTRACT_SILENT%"
echo _CHANGE_DIR       = "%_CHANGE_DIR%"
echo _FREE_ARGS        = %_FREE_ARGS%
call :Start
goto :Exit

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
setlocal EnableDelayedExpansion
rem resolve _ARCHIVE_PATH into single zip file
if exist "%_ARCHIVE_PATH%\*" (
  rem _ARCHIVE_PATH is a folder - we look for the first .zip file we can find:
  pushd "%_ARCHIVE_PATH%"
  rem set _ARCHIVE_
  rem set __archive_name=
  for /f %%f in ('dir /b /A-D *') do if "%__archive_name%" equ "" if /i "%%~xf" equ ".zip" set "__archive_name=%%~nxf"
  popd
  rem set __archive
  set "_ARCHIVE_PATH=%_ARCHIVE_PATH%\!__archive_name!"
  set "_ARCHIVE_NAME=!__archive_name!"
  rem set _ARCHIVE_
)
rem if "%_EXTRACT_SILENT%" neq "true" (
  echo ************************************************************************************************************************
  echo * extracting "!_ARCHIVE_NAME!" into "%_TARGET_DIR%"
  if "%_EXTRACT_SILENT%" equ "true" (
  echo ************************************************************************************************************************ )
rem )
if not exist "%_TARGET_DIR%" goto :Extract
set _dir_is_empty=true
for /f %%i in ('dir /a /b "%_TARGET_DIR%"') do set _dir_is_empty=false
if "!_dir_is_empty!" neq "true" (
  endlocal
  if "%_EXTRACT_SILENT%" neq "true" (
    echo * -^> "%_TARGET_DIR%" already contains data
    echo *    remove the target folder via: 'rmdir /s /q "%_TARGET_DIR%"'
    echo *    to force fresh extraction of "!_ARCHIVE_NAME!" into "%_TARGET_DIR%"
    echo ************************************************************************************************************************
    echo.
  )
  goto :EOF
)
endlocal
rem echo call :Extract "%_TARGET_DIR%" "%_ARCHIVE_PATH%" "%_ARCHIVE_NAME%"
call :Extract "%_TARGET_DIR%" "%_ARCHIVE_PATH%" "%_ARCHIVE_NAME%"
goto :EOF


:Extract
setlocal EnableDelayedExpansion
rem echo :Extract "%~1" "%~2" "%~3"
rem set _TARGET_DIR
rem set _ARCHIVE_
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"
if not exist "%_ARCHIVE_PATH%" (
  echo * -^> ERROR: extraction of "%_ARCHIVE_NAME%" failed
  echo *           the archive "%_ARCHIVE_PATH%" does not exist 
  echo ************************************************************************************************************************
  endlocal
  set _ARCHIVE_NAME=
  set _ARCHIVE_PATH=
  exit /b 78
)
call powershell -command "Expand-Archive -Force '!_ARCHIVE_PATH!' '%_TARGET_DIR%'; Expand-Archive -Force '!_ARCHIVE_PATH!' '%_TARGET_DIR%';"
set _dir_is_empty=true
for /f %%i in ('dir /a /b "%_TARGET_DIR%"') do set _dir_is_empty=false
if "!_dir_is_empty!" equ "true" (
  echo * -^> ERROR: extraction of "!_ARCHIVE_NAME!" failed
  echo ************************************************************************************************************************
  endlocal
  set _ARCHIVE_NAME=
  set _ARCHIVE_PATH=
  exit /b 79
)
pushd "%_TARGET_DIR%"
set _file_count=0
set _file_path=
set _file_name=
set _file_type=
for /f %%i in ('dir /a-d /b "%_TARGET_DIR%"') do (set /a _file_count=!_file_count!+1 &set "_file_path=%%~dpnxi" &set "_file_name=%%~nxi" &set "_file_type=%%~xi")
if !_file_count! equ 1 if /i "!_file_type!" equ ".tgz" (
  rem set _file_
  echo * extracting "!_file_name!" into "%_TARGET_DIR%"
  call tar -xf "!_file_path!"
  set _dir_is_empty=true
  for /f %%i in ('dir /a /b "%_TARGET_DIR%"') do set _dir_is_empty=false
  if "!_dir_is_empty!" equ "true" (
    echo * -^> ERROR: extraction of "!_file_path!" failed
    echo ************************************************************************************************************************
    endlocal
    set _ARCHIVE_NAME=
    set _ARCHIVE_PATH=
    exit /b 80
  )
)
if "%_EXTRACT_SILENT%" neq "true" (
  echo * -^> EXTRACTION DONE
  echo ************************************************************************************************************************
)
endlocal
goto :EOF
