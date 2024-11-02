@goto :_start
:_usage
echo validate ^<tool_name^> ^<test_cmd^> ^<version_cmd^> [tgt_version] [--no_errors^|-ne] [--no_warnings^|-nw] [--no_info^|-ni] [--verbose^|-v] [--help^|-h^|-?]
echo.
echo tgt_version:
echo   major              GTRmajor              GEQmajor              LSSmajor              LEQmajor
echo   major.minor        GTRmajor.minor        GEQmajor.minor        LSSmajor.minor        LEQmajor.minor
echo   major.minor.patch  GTRmajor.minor.patch  GEQmajor.minor.patch  LSSmajor.minor.patch  LEQmajor.minor.patch
echo.
echo examples:
echo   validate "CHOCO" "choco --version" "call choco --version" GTR2.1
echo   validate "NINJA" "ninja --version" "call ninja --version"
echo   validate "CMAKE" "cmake --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call cmake --version') do if /I %%%%j EQU version echo %%%%k" 3
goto :EOF

:_start
@echo off
set "_SCRIPT_NAME=%~n0"
if /I "%~1" equ "--help" (call :_usage &goto :EOF)
if /I "%~1" equ "-h"     (call :_usage &goto :EOF)
if /I "%~1" equ "-?"     (call :_usage &goto :EOF)
if "%~1" equ "" echo %_SCRIPT_NAME% error: missing arg1: ^<tool_name^> & goto :EOF
if "%~2" equ "" echo %_SCRIPT_NAME% error: missing arg2: ^<test_cmd^> & goto :EOF
if "%~3" equ "" echo %_SCRIPT_NAME% error: missing arg3: ^<version_cmd^> & goto :EOF
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
set _VALIDATE_HELP=
:_param_loop
set "_ARG_TMP_=%~1"
if "%_ARG_TMP_%" equ "" goto :_param_loop_finish
shift
if /I "%_ARG_TMP_%" equ "--no_errors"   (set "_VALIDATE_NO_ERRORS=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-ne"           (set "_VALIDATE_NO_ERRORS=--no_errors" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--no_warnings" (set "_VALIDATE_NO_WARNINGS=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-nw"           (set "_VALIDATE_NO_WARNINGS=--no_warnings" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--no_info"     (set "_VALIDATE_NO_INFO=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-ni"           (set "_VALIDATE_NO_INFO=--no_info" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--verbose"     (set "_VALIDATE_VERBOSE=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-v"            (set "_VALIDATE_VERBOSE=--verbose" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--help"        (set "_VALIDATE_HELP=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-h"            (set "_VALIDATE_HELP=--help" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-?"            (set "_VALIDATE_HELP=--help" &goto :_param_loop)
if "%_ARG_TMP_:~0,1%" equ "-" (echo warning: unknown switch '%_ARG_TMP_%' &goto :_param_loop)
if "%_ARG_TMP_%" neq "" if "%_VALIDATE_TGT_VERSION%" equ "" (set "_VALIDATE_TGT_VERSION=%_ARG_TMP_%" &goto :_param_loop)
if "%_ARG_TMP_%" neq "" (echo warning: unknown argument '%_ARG_TMP_%' &goto :_param_loop)
:_param_loop_finish
set _ARG_TMP_=

:_params_postprocessing
if "%_VALIDATE_TGT_VERSION%" equ "" goto :_params_done
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION_COMPARE=GEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION_COMPARE=GTR"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION_COMPARE=LEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION_COMPARE=LSS"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"

:_params_done
dir "%~dpn0.---" 1>nul 2>nul
if %ERRORLEVEL% equ 0 (echo YOUR SHELL IS DEFECT -^> CREATE A NEW ONE &goto :EOF)
if "%_VALIDATE_VERBOSE%" neq "" call :_validate_verbose_params_list
if "%_VALIDATE_HELP%" neq "" call :_usage &call :_clean_temp_variables &goto :EOF
goto :_execute

:_clean_temp_variables
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_NO_WARNINGS=
set _VALIDATE_NO_ERRORS=
set _VALIDATE_NO_INFO=
set _VALIDATE_VERBOSE=
set _VALIDATE_HELP=
goto :EOF

:_validate_verbose_params_list
echo _VALIDATE_NAME                : '%_VALIDATE_NAME%'
echo _VALIDATE_TEST_CMD            : '%_VALIDATE_TEST_CMD%'
echo _VALIDATE_VERSION_CMD         : '%_VALIDATE_VERSION_CMD%'
echo _VALIDATE_TGT_VERSION         : '%_VALIDATE_TGT_VERSION%'
echo _VALIDATE_TGT_VERSION_COMPARE : '%_VALIDATE_TGT_VERSION_COMPARE%'
echo _VALIDATE_NO_WARNINGS         : '%_VALIDATE_NO_WARNINGS%'
echo _VALIDATE_NO_ERRORS           : '%_VALIDATE_NO_ERRORS%'
echo _VALIDATE_NO_INFO             : '%_VALIDATE_NO_INFO%'
echo _VALIDATE_VERBOSE             : '%_VALIDATE_VERBOSE%'
echo _VALIDATE_HELP                : '%_VALIDATE_HELP%'
echo %_VALIDATE_NAME%_VERSION       :
echo %_VALIDATE_NAME%_VERSION_MAJOR :
echo %_VALIDATE_NAME%_VERSION_MINOR :
echo %_VALIDATE_NAME%_VERSION_PATCH :
echo.
goto :EOF

:_execute
call %_VALIDATE_TEST_CMD% 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :_tool_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 1: %_VALIDATE_NAME% not available
call :_clean_temp_variables
exit /b 1

:_tool_available
set _VALIDATE_VERSION=
rem call cmd /Q /E:ON /V:ON /C "%_VALIDATE_VERSION_CMD%">"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
%_VALIDATE_VERSION_CMD%>"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
set /P _VALIDATE_VERSION=<"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
del /Q /F "%TEMP%\_VALIDATE_VERSION_CMD.tmp" 1>nul 2>nul
if "%_VALIDATE_VERSION%" neq "" goto :_tool_version_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 2: %_VALIDATE_NAME% version unknown
call :_clean_temp_variables
exit /b 2

:_tool_version_available
call "%_SCRIPT_ROOT%\split_version.bat" "%_VALIDATE_VERSION%" 1>nul
if %ERRORLEVEL% equ 0 goto :_tool_version_split_ok
if "%_VALIDATE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 3: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' not available or invalid
call :_clean_temp_variables
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
if "%_VALIDATE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 4: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' does not match required version '%_VALIDATE_TGT_VERSION%'
call :_clean_temp_variables
exit /b 4

:_tool_validation_success
if "%_VALIDATE_NO_INFO%" equ "" cmd /Q /V:ON /C echo using: %_VALIDATE_NAME% !%_VALIDATE_NAME%_VERSION!
call :_clean_temp_variables
exit /b 0
