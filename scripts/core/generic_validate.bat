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
call :_clean_script_variables
set "_VALIDATE_SCRIPT_ROOT=%~dp0"
set "_VALIDATE_SCRIPT_NAME=_%~n0"
set "_VALIDATE_NAME=%~1"
set "_VALIDATE_TEST_CMD=%~2"
set "_VALIDATE_VERSION_CMD=%3"
shift
shift
shift
:_param_loop
set "_ARG_TMP_=%~1"
if "%_ARG_TMP_%" equ "" goto :_param_loop_finish
shift
if /I "%_ARG_TMP_%" equ "x86"           (set "_VALIDATE_TGT_ARCHITECTURE=x86" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "x64"           (set "_VALIDATE_TGT_ARCHITECTURE=x64" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "amd64"         (set "_VALIDATE_TGT_ARCHITECTURE=x64" &goto :_param_loop)
if /I "%_ARG_TMP_:~0,12%" equ "--tool_arch:" (set "_VALIDATE_TOOL_ARCHITECTURE=%_ARG_TMP_:~12%" &goto :_param_loop)
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
if '%_ARG_TMP_:~0,1%' equ '-' (echo warning%_VALIDATE_SCRIPT_NAME%: unknown switch '%_ARG_TMP_%' &goto :_param_loop)
if "%_VALIDATE_TGT_VERSION%" equ "" set "_VALIDATE_TGT_VERSION=%_ARG_TMP_%" &goto :_param_loop
echo warning%_VALIDATE_SCRIPT_NAME%: unknown argument '%_ARG_TMP_%'
goto :_param_loop
:_param_loop_finish
set _ARG_TMP_=

:_params_postprocessing
if "%_VALIDATE_NAME%"             equ "" (echo error 1%_VALIDATE_SCRIPT_NAME%: missing arg1: ^<tool_name^> &call :_clean_script_variables &exit /b 1)
if "%_VALIDATE_TEST_CMD%"         equ "" (echo error 2%_VALIDATE_SCRIPT_NAME%: missing arg2: ^<test_cmd^>  &call :_clean_script_variables &exit /b 2)
if "%_VALIDATE_VERSION_CMD:~1,1%" equ "" (echo error 3%_VALIDATE_SCRIPT_NAME%: missing arg3: ^<version_cmd^> &call :_clean_script_variables &exit /b 3)
rem unquote the cmd string:
set _VALIDATE_VERSION_CMD=%_VALIDATE_VERSION_CMD:~1,-1%
call set _VALIDATE_VERSION_CMD=%%_VALIDATE_VERSION_CMD:""="%%
rem reset result and temp variables:
set %_VALIDATE_NAME%_VERSION=
set %_VALIDATE_NAME%_VERSION_MAJOR=
set %_VALIDATE_NAME%_VERSION_MINOR=
set %_VALIDATE_NAME%_VERSION_PATCH=
rem extract compare mode from target verison
if "%_VALIDATE_TGT_VERSION%" equ "" goto :_params_done
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION_COMPARE=GEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION_COMPARE=GTR"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "GTR" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION_COMPARE=LEQ"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LEQ" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION_COMPARE=LSS"
if /I "%_VALIDATE_TGT_VERSION:~0,3%" equ "LSS" set "_VALIDATE_TGT_VERSION=%_VALIDATE_TGT_VERSION:~3%"
rem normalize tool architecture:
if /I "%_VALIDATE_TOOL_ARCHITECTURE%" equ "x86"   set "_VALIDATE_TOOL_ARCHITECTURE=x86"
if /I "%_VALIDATE_TOOL_ARCHITECTURE%" equ "x64"   set "_VALIDATE_TOOL_ARCHITECTURE=x64"
if /I "%_VALIDATE_TOOL_ARCHITECTURE%" equ "amd64" set "_VALIDATE_TOOL_ARCHITECTURE=x64"
rem specific MSVS version handling:
if /I "%_VALIDATE_NAME%" neq "MSVS" goto :tgt_version_normalized
rem https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B#Internal_version_numbering
if "%_VALIDATE_TGT_VERSION%" equ "2022" (set "_VALIDATE_TGT_VERSION=17" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2019" (set "_VALIDATE_TGT_VERSION=16" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2017" (set "_VALIDATE_TGT_VERSION=15" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2015" (set "_VALIDATE_TGT_VERSION=14" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2013" (set "_VALIDATE_TGT_VERSION=12" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2012" (set "_VALIDATE_TGT_VERSION=11" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2010" (set "_VALIDATE_TGT_VERSION=10" &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2008" (set "_VALIDATE_TGT_VERSION=9"  &goto :tgt_version_normalized)
if "%_VALIDATE_TGT_VERSION%" equ "2005" (set "_VALIDATE_TGT_VERSION=8"  &goto :tgt_version_normalized)
:tgt_version_normalized

:_params_done
dir "%~dpn0.---" 1>nul 2>nul
if %ERRORLEVEL% equ 0 (echo YOUR SHELL IS DEFECT -^> CREATE A NEW ONE &exit /b 99)
if "%_VALIDATE_VERBOSE%" neq "" call :_validate_verbose_params_list
if "%_VALIDATE_HELP%" neq "" (call :_usage &call :_clean_script_variables &goto :EOF)
goto :_execute

:_clean_script_variables
set _VALIDATE_SCRIPT_ROOT=
set _VALIDATE_SCRIPT_NAME=
set _VALIDATE_NAME=
set _VALIDATE_TEST_CMD=
set _VALIDATE_VERSION_CMD=
set _VALIDATE_VERSION=
set _VALIDATE_TGT_VERSION=
set _VALIDATE_TGT_VERSION_COMPARE=
set _VALIDATE_TGT_ARCHITECTURE=
set _VALIDATE_TOOL_ARCHITECTURE=
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
echo _VALIDATE_TGT_VERSION         : %_VALIDATE_TGT_VERSION%
echo _VALIDATE_TGT_VERSION_COMPARE : %_VALIDATE_TGT_VERSION_COMPARE%
echo _VALIDATE_TGT_ARCHITECTURE    : %_VALIDATE_TGT_ARCHITECTURE%
echo _VALIDATE_NO_WARNINGS         : %_VALIDATE_NO_WARNINGS%
echo _VALIDATE_NO_ERRORS           : %_VALIDATE_NO_ERRORS%
echo _VALIDATE_NO_INFO             : %_VALIDATE_NO_INFO%
echo _VALIDATE_VERBOSE             : %_VALIDATE_VERBOSE%
echo _VALIDATE_HELP                : %_VALIDATE_HELP%
rem echo %_VALIDATE_NAME%_VERSION       :
rem echo %_VALIDATE_NAME%_VERSION_MAJOR :
rem echo %_VALIDATE_NAME%_VERSION_MINOR :
rem echo %_VALIDATE_NAME%_VERSION_PATCH :
rem echo.
goto :EOF

:_execute
if "%_VALIDATE_VERBOSE%" neq "" echo VALIDATE: '%_VALIDATE_NAME% %_VALIDATE_TGT_ARCHITECTURE% %_VALIDATE_TGT_VERSION_COMPARE% %_VALIDATE_TGT_VERSION%'
call %_VALIDATE_TEST_CMD% 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :_tool_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 4%_VALIDATE_SCRIPT_NAME%: %_VALIDATE_NAME% not available
call :_clean_script_variables
exit /b 4

:_tool_available
set _VALIDATE_VERSION=
rem call cmd /Q /E:ON /V:ON /C "%_VALIDATE_VERSION_CMD%">"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
%_VALIDATE_VERSION_CMD%>"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
set /P _VALIDATE_VERSION=<"%TEMP%\_VALIDATE_VERSION_CMD.tmp"
del /Q /F "%TEMP%\_VALIDATE_VERSION_CMD.tmp" 1>nul 2>nul
if "%_VALIDATE_VERSION%" neq "" goto :_tool_version_available
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 5%_VALIDATE_SCRIPT_NAME%: %_VALIDATE_NAME% version unknown
call :_clean_script_variables
exit /b 5

:_tool_version_available
call "%_VALIDATE_SCRIPT_ROOT%\split_version.bat" "%_VALIDATE_VERSION%" --no_info %_VALIDATE_NO_WARNINGS% %_VALIDATE_NO_ERRORS%
if %ERRORLEVEL% equ 0 goto :_tool_version_split_ok
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 6%_VALIDATE_SCRIPT_NAME%: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' not available or invalid
call :_clean_script_variables
exit /b 6

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
if "%_VALIDATE_TGT_VERSION%" equ "" goto :_tool_architecture_requirement_test
call "%_VALIDATE_SCRIPT_ROOT%\compare_versions.bat" --no_info %_VALIDATE_NO_ERRORS% "%_VALIDATE_VERSION%" "%_VALIDATE_TGT_VERSION%" "%_VALIDATE_TGT_VERSION_COMPARE%"
if %ERRORLEVEL% equ 0 goto :_tool_architecture_requirement_test
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 7%_VALIDATE_SCRIPT_NAME%: %_VALIDATE_NAME% version '%_VALIDATE_VERSION%' does not match required version '%_VALIDATE_TGT_VERSION%'
call :_clean_script_variables
exit /b 7

:_tool_architecture_requirement_test
if "%_VALIDATE_TGT_ARCHITECTURE%" equ "" goto :_tool_validation_success
if "%_VALIDATE_TOOL_ARCHITECTURE%" equ "" goto :_tool_validation_success
if /I "%_VALIDATE_TOOL_ARCHITECTURE%" equ "%_VALIDATE_TGT_ARCHITECTURE%" goto :_tool_validation_success
if "%_VALIDATE_NO_ERRORS%" equ "" echo error 8%_VALIDATE_SCRIPT_NAME%: %_VALIDATE_NAME% architecture '%_VALIDATE_TOOL_ARCHITECTURE%' does not match required type '%_VALIDATE_TGT_ARCHITECTURE%'
call :_clean_script_variables
exit /b 8

:_tool_validation_success
if "%_VALIDATE_NO_INFO%" equ "" cmd /Q /V:ON /C echo using: %_VALIDATE_NAME% !%_VALIDATE_NAME%_VERSION! %_VALIDATE_TOOL_ARCHITECTURE%
call :_clean_script_variables
exit /b 0
