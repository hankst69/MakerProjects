@goto :_start
:_usage
echo.
echo compare_versions ^<src_version^> ^<EQU^|GTR^|GEQ^|LSS^|LEQ^> ^<tgt_version^>  [options]
echo compare_versions ^<src_version^> ^<tgt_version^> [EQU^|GTR^|GEQ^|LSS^|LEQ]  [options]
echo compare_versions ^<src_version^> ^<[EQU^|GTR^|GEQ^|LSS^|LEQ]tgt_version^>   [options]
echo.
echo   src_version  : major[.minor[.patch]]
echo   tgt_version  : major[.minor[.patch]]
echo   compare_mode : EQU^|GTR^|GEQ^|LSS^|LEQ
echo      [options] : --no_errors^|-ne
echo                : --no_warnings^|-nw
echo                : --no_info^|-ni
echo                : --verbose^|-v
echo                : --help^|-h^|-?
echo.
echo examples:
echo   compare_versions 3.12.5 GEQ 3
echo   compare_versions 3.12.5 3 GEQ
echo   compare_versions 3.12.5 GEQ3
echo   compare_versions 2.3    2    GTR
echo   compare_versions 2      2.5  GEQ
echo   compare_versions 2.3    GEQ2
echo   compare_versions 2      LSS2.5
goto :EOF

:_start
@echo off
set ERRORLEVEL=
set "_COMPARE_SCRIPT_ROOT=%~dp0"
set "_COMPARE_SCRIPT_NAME=_%~n0"
set "_COMPARE_SCRIPT_NAME=_compare"
set _COMPARE_SRC_VERSION_MAJOR=
set _COMPARE_SRC_VERSION_MINOR=
set _COMPARE_SRC_VERSION_PATCH=
set _COMPARE_TGT_VERSION_MAJOR=
set _COMPARE_TGT_VERSION_MINOR=
set _COMPARE_TGT_VERSION_PATCH=
set _COMPARE_TGT_MINOR_MISSING=
set _COMPARE_TGT_PATCH_MISSING=

set _COMPARE_SRC_VERSION=
set _COMPARE_TGT_VERSION=
set _COMPARE_VERSION_MODE=
set _COMPARE_NO_WARNINGS=
set _COMPARE_NO_ERRORS=
set _COMPARE_NO_INFO=
set _COMPARE_VERBOSE=
set _COMPARE_HELP=
:_param_loop
set "_ARG_TMP_=%~1"
if "%_ARG_TMP_%" equ "" goto :_param_loop_finish
shift
if /I "%_ARG_TMP_%" equ "--no_errors"   (set "_COMPARE_NO_ERRORS=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-ne"           (set "_COMPARE_NO_ERRORS=--no_errors" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--no_warnings" (set "_COMPARE_NO_WARNINGS=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-nw"           (set "_COMPARE_NO_WARNINGS=--no_warnings" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--no_info"     (set "_COMPARE_NO_INFO=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-ni"           (set "_COMPARE_NO_INFO=--no_info" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--verbose"     (set "_COMPARE_VERBOSE=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-v"            (set "_COMPARE_VERBOSE=--verbose" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "--help"        (set "_COMPARE_HELP=%_ARG_TMP_%" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-h"            (set "_COMPARE_HELP=--help" &goto :_param_loop)
if /I "%_ARG_TMP_%" equ "-?"            (set "_COMPARE_HELP=--help" &goto :_param_loop)
if "%_ARG_TMP_:~0,1%" equ "-" (echo warning%_COMPARE_SCRIPT_NAME%: unknown switch '%_ARG_TMP_%' &goto :_param_loop)
if "%_COMPARE_SRC_VERSION%"  equ "" (set "_COMPARE_SRC_VERSION=%_ARG_TMP_%" &goto :_param_loop)
if "%_COMPARE_TGT_VERSION%"  equ "" (set "_COMPARE_TGT_VERSION=%_ARG_TMP_%" &goto :_param_loop)
if "%_COMPARE_VERSION_MODE%" equ "" (set "_COMPARE_VERSION_MODE=%_ARG_TMP_%" &goto :_param_loop)
echo warning%_COMPARE_SCRIPT_NAME%: unknown argument '%_ARG_TMP_%'
goto :_param_loop
:_param_loop_finish

if "%_COMPARE_VERSION_MODE%" equ "" goto :_params_validation
if /I "%_COMPARE_TGT_VERSION%" equ "EQU" goto :_params_switching
if /I "%_COMPARE_TGT_VERSION%" equ "GTR" goto :_params_switching
if /I "%_COMPARE_TGT_VERSION%" equ "GEQ" goto :_params_switching
if /I "%_COMPARE_TGT_VERSION%" equ "NEQ" goto :_params_switching
if /I "%_COMPARE_TGT_VERSION%" equ "LSS" goto :_params_switching
if /I "%_COMPARE_TGT_VERSION%" equ "LEQ" goto :_params_switching
goto :_params_validation

:_params_switching
set "_ARG_TMP_=%_COMPARE_TGT_VERSION%"
set "_COMPARE_TGT_VERSION=%_COMPARE_VERSION_MODE%"
set "_COMPARE_VERSION_MODE=%_ARG_TMP_%"

:_params_validation
set _ARG_TMP_=
if "%_COMPARE_SRC_VERSION%" equ "" (echo error 1%_COMPARE_SCRIPT_NAME%: missing argument ^<src_version^> &call :_usage &call :_clean_temp_variables &exit /b 1)
if "%_COMPARE_TGT_VERSION%" equ "" (echo error 2%_COMPARE_SCRIPT_NAME%: missing argument ^<tgt_version^> &call :_usage &call :_clean_temp_variables &exit /b 2)

:_params_postprocessing
call "%_COMPARE_SCRIPT_ROOT%\split_version.bat" "%_COMPARE_SRC_VERSION%" --no_errors --no_warnings --no_info
set _COMPARE_SRC_VERSION=%VERSION%
call "%_COMPARE_SCRIPT_ROOT%\split_version.bat" "%_COMPARE_TGT_VERSION%" --no_errors --no_warnings --no_info
set _COMPARE_TGT_VERSION=%VERSION%
if "%_COMPARE_VERSION_MODE%" equ "" set _COMPARE_VERSION_MODE=%VERSION_COMPARE%

if "%_COMPARE_VERSION_MODE%" equ "" set _COMPARE_VERSION_MODE=EQU
if /I "%_COMPARE_VERSION_MODE%" equ "EQU" (set "_COMPARE_VERSION_MODE=EQU" &goto :_params_done)
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" (set "_COMPARE_VERSION_MODE=GTR" &goto :_params_done)
if /I "%_COMPARE_VERSION_MODE%" equ "GEQ" (set "_COMPARE_VERSION_MODE=GEQ" &goto :_params_done)
if /I "%_COMPARE_VERSION_MODE%" equ "NEQ" (set "_COMPARE_VERSION_MODE=NEQ" &goto :_params_done)
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" (set "_COMPARE_VERSION_MODE=LSS" &goto :_params_done)
if /I "%_COMPARE_VERSION_MODE%" equ "LEQ" (set "_COMPARE_VERSION_MODE=LEQ" &goto :_params_done)
echo error 3%_COMPARE_SCRIPT_NAME%: invalid value '%_COMPARE_VERSION_MODE%' for optional argument [version_compare]
call :_clean_temp_variables
exit /b 3

:_params_done
dir "%~dpn0.---" 1>nul 2>nul
if %ERRORLEVEL% equ 0 (echo YOUR SHELL IS DEFECT -^> CREATE A NEW ONE &exit /b 99)
rem if "%_COMPARE_VERBOSE%" neq "" call :_verbose_params_list
if "%_COMPARE_HELP%" neq "" (call :_usage &call :_clean_temp_variables &goto :EOF)
goto :_execute

:_clean_temp_variables
set _COMPARE_SCRIPT_ROOT=
set _COMPARE_SCRIPT_NAME=
set _COMPARE_SRC_VERSION_MAJOR=
set _COMPARE_SRC_VERSION_MINOR=
set _COMPARE_SRC_VERSION_PATCH=
set _COMPARE_TGT_VERSION_MAJOR=
set _COMPARE_TGT_VERSION_MINOR=
set _COMPARE_TGT_VERSION_PATCH=
set _COMPARE_TGT_MINOR_MISSING=
set _COMPARE_TGT_PATCH_MISSING=
set _COMPARE_SRC_VERSION=
set _COMPARE_TGT_VERSION=
set _COMPARE_VERSION_MODE=
set _COMPARE_NO_WARNINGS=
set _COMPARE_NO_ERRORS=
set _COMPARE_NO_INFO=
set _COMPARE_VERBOSE=
set _COMPARE_HELP=
goto :EOF


:_execute
call "%_COMPARE_SCRIPT_ROOT%\split_version.bat" "%_COMPARE_SRC_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_SRC_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo error 4%_COMPARE_SCRIPT_NAME%: target version '%_COMPARE_SRC_VERSION%' not available or invalid
call :_clean_temp_variables
exit /b 4

:split_COMPARE_SRC_VERSION_ok
set "_COMPARE_SRC_VERSION_MAJOR=%VERSION_MAJOR%"
set "_COMPARE_SRC_VERSION_MINOR=%VERSION_MINOR%"
set "_COMPARE_SRC_VERSION_PATCH=%VERSION_PATCH%"

call "%_COMPARE_SCRIPT_ROOT%split_version.bat" "%_COMPARE_TGT_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_TGT_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo error 5%_COMPARE_SCRIPT_NAME%: target version '%_COMPARE_TGT_VERSION%' not available or invalid
call :_clean_temp_variables
exit /b 5

:split_COMPARE_TGT_VERSION_ok
set "_COMPARE_TGT_VERSION_MAJOR=%VERSION_MAJOR%"
set "_COMPARE_TGT_VERSION_MINOR=%VERSION_MINOR%"
set "_COMPARE_TGT_VERSION_PATCH=%VERSION_PATCH%"
set _COMPARE_TGT_MINOR_MISSING=
set _COMPARE_TGT_PATCH_MISSING=
if "%VERSION_MINOR%" equ "" set _COMPARE_TGT_MINOR_MISSING=true
if "%VERSION_PATCH%" equ "" set _COMPARE_TGT_PATCH_MISSING=true

rem handle missing sub versions
if "%_COMPARE_SRC_VERSION_MAJOR%" equ "" set _COMPARE_SRC_VERSION_MAJOR=0
if "%_COMPARE_SRC_VERSION_MINOR%" equ "" set _COMPARE_SRC_VERSION_MINOR=0
if "%_COMPARE_SRC_VERSION_PATCH%" equ "" set _COMPARE_SRC_VERSION_PATCH=0
if "%_COMPARE_TGT_VERSION_MAJOR%" equ "" set _COMPARE_TGT_VERSION_MAJOR=0
if "%_COMPARE_TGT_VERSION_MINOR%" equ "" set _COMPARE_TGT_VERSION_MINOR=0
if "%_COMPARE_TGT_VERSION_PATCH%" equ "" set _COMPARE_TGT_VERSION_PATCH=0

:compare_major_version
if %_COMPARE_SRC_VERSION_MAJOR% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR% goto :compare_major_version_ok
:compare_major_version_failed
rem support: compare_versions.bat 3.3 3.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if "%_COMPARE_NO_ERRORS%" equ "" echo error 6%_COMPARE_SCRIPT_NAME%: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.x.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 6

:compare_major_version_ok
if "%_COMPARE_SRC_VERSION_MAJOR%" NEQ "%_COMPARE_TGT_VERSION_MAJOR%" goto :version_compare_success
rem support: compare_versions.bat 3.1 3
if "%_COMPARE_TGT_MINOR_MISSING%" neq "" goto :version_compare_success

:compare_minor_version
if %_COMPARE_SRC_VERSION_MINOR% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MINOR% goto :compare_minor_version_ok
:compare_minor_version_failed
rem support: compare_versions.bat 3.3.1 3.2.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if "%_COMPARE_NO_ERRORS%" equ "" echo error 7%_COMPARE_SCRIPT_NAME%: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 7

:compare_minor_version_ok
if %_COMPARE_SRC_VERSION_MINOR% NEQ %_COMPARE_TGT_VERSION_MINOR% goto :version_compare_success
rem support: compare_versions.bat 3.3.1 3.3
if "%_COMPARE_TGT_PATCH_MISSING%" neq "" goto :version_compare_success

:compare_patch_version
if "%_COMPARE_SRC_VERSION_PATCH%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_PATCH%" goto :version_compare_success
if "%_COMPARE_NO_ERRORS%" equ "" echo error 8%_COMPARE_SCRIPT_NAME%: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 8

:version_compare_success
if "%_COMPARE_NO_INFO%" equ "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION%' met
call :_clean_temp_variables
exit /b 0
