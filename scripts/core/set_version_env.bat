@echo off

if "%~1" equ "" if "%MAKER_ENV_NOERRORS%" equ "" echo error: missing arg1 'env_variable_base_name' &goto :EOF
set %~1_VERSION=
set %~1_VERSION_MAJOR=
set %~1_VERSION_MINOR=
set %~1_VERSION_PATCH=

if "%~2" equ "" goto :EOF
call "%MAKER_SCRIPTS%\split_version.bat" "%~2" 1>nul
set "%~1_VERSION=%VERSION%"
set "%~1_VERSION_MAJOR=%VERSION_MAJOR%"
set "%~1_VERSION_MINOR=%VERSION_MINOR%"
set "%~1_VERSION_PATCH=%VERSION_PATCH%"
set "%~1_VERSION_COMPARE=%VERSION_COMPARE%"
