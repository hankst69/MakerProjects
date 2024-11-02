@echo off
rem validate <tool_name> <test_cmd> <version_cmd> [tgt_version] [--no_errors] [--no_warnings] [--no_info]
rem tgt_version:
rem   major              GTRmajor              GEQmajor              LSSmajor              LEQmajor
rem   major.minor        GTRmajor.minor        GEQmajor.minor        LSSmajor.minor        LEQmajor.minor
rem   major.minor.patch  GTRmajor.minor.patch  GEQmajor.minor.patch  LSSmajor.minor.patch  LEQmajor.minor.patch
if "%~1" equ "" echo error: missing arg1: ^<tool_name^> & goto :EOF
if "%~2" equ "" echo error: missing arg2: ^<tool_version_cmd^> & goto :EOF
set "_SCRIPT_ROOT=%~dp0"
set "_VALIDATE_NAME=%~1"
set "_VALIDATE_TEST_CMD=%~2"
set "_VALIDATE_VERSION_CMD=%3"
shift
shift
shift
rem unquote the cmd string:
set _VALIDATE_VERSION_CMD=%_VALIDATE_VERSION_CMD:~1,-1%
call set _VALIDATE_VERSION_CMD=%%_VALIDATE_VERSION_CMD:""="%%
rem reset result and temp variables:
set %_VALIDATE_NAME%_VERSION=
set %_VALIDATE_NAME%_VERSION_MAJOR=
set %_VALIDATE_NAME%_VERSION_MINOR=
set %_VALIDATE_NAME%_VERSION_PATCH=

set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
:_tool_param_loop
if /I "%~1" equ "--no_errors"   (set "_VALIDATE_NO_ERRORS=%~1" &shift &goto :_tool_param_loop)
if /I "%~1" equ "--no_warnings" (set "_VALIDATE_NO_WARNINGS=%~1" &shift &goto :_tool_param_loop)
if /I "%~1" equ "--no_info"     (set "_VALIDATE_NO_INFO=%~1" &shift &goto :_tool_param_loop)
if /I "%~1" equ "--verbose"     (set "_VALIDATE_VERBOSE=%~1" &shift &goto :_tool_param_loop)
if "%~1" neq "" if "%_VALIDATE_TGT_VERSION%" equ "" (set "_VALIDATE_TGT_VERSION=%~1" &shift &goto :_tool_param_loop)
if "%~1" neq "" (echo warning: unknown argument '%~1' &shift &goto :_tool_param_loop)
if "%_VALIDATE_TGT_VERSION%" equ "" goto :_tool_params_done
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION_COMPARE=GEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION_COMPARE=GTR"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION_COMPARE=LEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION_COMPARE=LSS"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"

:_tool_params_done
if "%_VALIDATE_VERBOSE%" equ "" goto :_tool_validation

:_tool_list_params
echo _VALIDATE_NAME                : '%_VALIDATE_NAME%'
echo _VALIDATE_TEST_CMD            : '%_VALIDATE_TEST_CMD%'
echo _VALIDATE_VERSION_CMD         : '%_VALIDATE_VERSION_CMD%'
echo _VALIDATE_TGT_VERSION         : '%_VALIDATE_TGT_VERSION%'
echo _VALIDATE_TGT_VERSION_COMPARE : '%_VALIDATE_TGT_VERSION_COMPARE%'
echo _VALIDATE_NO_WARNINGS         : '%_VALIDATE_NO_WARNINGS%'
echo _VALIDATE_NO_ERRORS           : '%_VALIDATE_NO_ERRORS%'
echo _VALIDATE_NO_INFO             : '%_VALIDATE_NO_INFO%'
echo _VALIDATE_VERBOSE             : '%_VALIDATE_VERBOSE%'
echo %_VALIDATE_NAME%_VERSION       :
echo %_VALIDATE_NAME%_VERSION_MAJOR :
echo %_VALIDATE_NAME%_VERSION_MINOR :
echo %_VALIDATE_NAME%_VERSION_PATCH :

:_tool_validation
call %_VALIDATE_TEST_CMD% 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :_tool_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 1: %_VALIDATE_NAME% not available
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _SCRIPT_ROOT=
exit /b 1

:_tool_available
set _VALIDATE_VERSION=
rem for /f "tokens=*" %%v in ('call :_tool_echo_version') do if "%%v" neq "" set "_VALIDATE_VERSION=%%v"
%_VALIDATE_VERSION_CMD%>"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
set /P _VALIDATE_VERSION=<"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
del /Q /F "%TEMP%\_VALIDATE_VERSION_CMD.tmp" 1>nul 2>nul
if "%_VALIDATE_VERSION%" neq "" goto :_tool_version_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 2: %_VALIDATE_NAME% version unknown
set _VALIDATE_VERSION=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _SCRIPT_ROOT=
exit /b 2

:_tool_version_available
call "%_SCRIPT_ROOT%\split_version.bat" "%_VALIDATE_VERSION%" 1>nul
if %ERRORLEVEL% equ 0 goto :_tool_version_split_ok
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 3: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' not available or invalid
set _VALIDATE_VERSION=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _SCRIPT_ROOT=
exit /b 3

:_tool_version_split_ok
set "%_VALIDATE_NAME%_VERSION=%_VALIDATE_VERSION%"
set "%_VALIDATE_NAME%_VERSION_MAJOR=%VERSION_MAJOR%"
set "%_VALIDATE_NAME%_VERSION_MINOR=%VERSION_MINOR%"
set "%_VALIDATE_NAME%_VERSION_PATCH=%VERSION_PATCH%"
rem set %_VALIDATE_NAME%_VERSION
rem set %_VALIDATE_NAME%_VERSION_MAJOR
if "%_VALIDATE_VERBOSE%" neq "" cmd /V:ON /C echo %_VALIDATE_NAME%_VERSION       : !%_VALIDATE_NAME%_VERSION!
if "%_VALIDATE_VERBOSE%" neq "" cmd /V:ON /C echo %_VALIDATE_NAME%_VERSION_MAJOR : !%_VALIDATE_NAME%_VERSION_MAJOR!
if "%_VALIDATE_VERBOSE%" neq "" cmd /V:ON /C echo %_VALIDATE_NAME%_VERSION_MINOR : !%_VALIDATE_NAME%_VERSION_MINOR!
if "%_VALIDATE_VERBOSE%" neq "" cmd /V:ON /C echo %_VALIDATE_NAME%_VERSION_PATCH : !%_VALIDATE_NAME%_VERSION_PATCH!

:_tool_version_requirement_test
if "%_VALIDATE_TGT_VERSION%" equ "" goto :_tool_validation_success
call "%_SCRIPT_ROOT%\compare_versions.bat" --no_info %_VALIDATE_NO_ERRORS% "%_VALIDATE_VERSION%" "%_VALIDATE_TGT_VERSION%" "%_VALIDATE_TGT_VERSION_COMPARE%"
if %ERRORLEVEL% equ 0 goto :_tool_validation_success
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 4: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' does not match required version '%_VALIDATE_TGT_VERSION%'
set _VALIDATE_VERSION=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _SCRIPT_ROOT=
exit /b 4

:_tool_validation_success
if "%_VALIDATE_NO_INFO%" equ "" cmd /Q /V:ON /C echo using: %_VALIDATE_NAME% !%_VALIDATE_NAME%_VERSION!
set _VALIDATE_VERSION=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _SCRIPT_ROOT=
exit /b 0


:_tool_echo_version
%_VALIDATE_VERSION_CMD%
rem call :_tool_echo_version_intern %_VALIDATE_VERSION_CMD%
goto :EOF
:_tool_echo_version_intern
%*
goto :EOF

:_test_errorlevel_test
echo initial:
echo ERRORLEVEL: %ERRORLEVEL%
echo dir failing:
dir "%~dpn0.---" 1>nul 2>nul
echo ERRORLEVEL: %ERRORLEVEL%
echo dir ok:
dir "%~dpnx0" 1>nul 2>nul
echo ERRORLEVEL: %ERRORLEVEL%
echo choco test:
call choco --version  1>nul 2>nul
echo ERRORLEVEL: %ERRORLEVEL%
rem echo choco found:
rem call "%~dp0..\.tools\choco.bat" --version  1>nul 2>nul
rem echo ERRORLEVEL: %ERRORLEVEL%
rem if %ERRORLEVEL% neq 0 set "PATH=%PATH%;%~dp0..\.tools"

