@goto :_start
:_usage
set _COMPARE_VERSION_MODE=
echo compare_versions ^<src_version^> ^<tgt_version^> [compare_mode] [--no_errors^|-ne] [--no_warnings^|-nw] [--no_info^|-ni] [--verbose^|-v] [--help^|-h^|-?]
echo.
echo   src_version  : major[.minor[.patch]]
echo   tgt_version  : major[.minor[.patch]]
echo   compare_mode : EQU^|GTR^|GEQ^|LSS^|LEQ
echo.
echo examples:
echo   compare_versions 3.12.5 3    GEQ
echo   compare_versions 2.3    2    GTR
echo   compare_versions 2      2.5  GEQ
goto :EOF

:_start
@echo off
set "_SCRIPT_ROOT=%~dp0"
set "_SCRIPT_NAME=%~n0"
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
if "%_ARG_TMP_:~0,1%" equ "-" (echo %_SCRIPT_NAME% warning: unknown switch '%_ARG_TMP_%' &goto :_param_loop)
if "%_ARG_TMP_%" neq "" if "%_COMPARE_SRC_VERSION%"  equ "" (set "_COMPARE_SRC_VERSION=%_ARG_TMP_%" &goto :_param_loop)
if "%_ARG_TMP_%" neq "" if "%_COMPARE_TGT_VERSION%"  equ "" (set "_COMPARE_TGT_VERSION=%_ARG_TMP_%" &goto :_param_loop)
if "%_ARG_TMP_%" neq "" if "%_COMPARE_VERSION_MODE%" equ "" (set "_COMPARE_VERSION_MODE=%_ARG_TMP_%" &goto :_param_loop)
if "%_ARG_TMP_%" neq "" (echo %_SCRIPT_NAME% warning: unknown argument '%_ARG_TMP_%' &goto :_param_loop)
:_param_loop_finish
set _ARG_TMP_=

:_params_postprocessing
if "%_COMPARE_SRC_VERSION%" equ "" (echo %_SCRIPT_NAME% error 1: missing argument ^<src_version^> &call :_clean_temp_variables &exit /b 1)
if "%_COMPARE_TGT_VERSION%" equ "" (echo %_SCRIPT_NAME% error 2: missing argument ^<tgt_version^> &call :_clean_temp_variables &exit /b 2)
if "%_COMPARE_VERSION_MODE%" equ "" set _COMPARE_VERSION_MODE=EQU
if /I "%_COMPARE_VERSION_MODE%" equ "EQU" goto :_params_done
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" goto :_params_done
if /I "%_COMPARE_VERSION_MODE%" equ "GEQ" goto :_params_done
if /I "%_COMPARE_VERSION_MODE%" equ "NEQ" goto :_params_done
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" goto :_params_done
if /I "%_COMPARE_VERSION_MODE%" equ "LEQ" goto :_params_done
echo %_SCRIPT_NAME% error 3: invalid value '%_COMPARE_VERSION_MODE%' for optional argument [version_compare]
call :_clean_temp_variables
exit /b 3

:_params_done
dir "%~dpn0.---" 1>nul 2>nul
if %ERRORLEVEL% equ 0 (echo YOUR SHELL IS DEFECT -^> CREATE A NEW ONE &goto :EOF)
rem if "%_COMPARE_VERBOSE%" neq "" call :_verbose_params_list
if "%_COMPARE_HELP%" neq "" (call :_usage &call :_clean_temp_variables &goto :EOF)
goto :_execute

:_clean_temp_variables
set _SCRIPT_ROOT=
set _SCRIPT_NAME=
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
call "%_SCRIPT_ROOT%\split_version.bat" "%_COMPARE_SRC_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_SRC_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 4: target version '%_COMPARE_SRC_VERSION%' not available or invalid
call :_clean_temp_variables
exit /b 4

:split_COMPARE_SRC_VERSION_ok
set "_COMPARE_SRC_VERSION_MAJOR=%VERSION_MAJOR%"
set "_COMPARE_SRC_VERSION_MINOR=%VERSION_MINOR%"
set "_COMPARE_SRC_VERSION_PATCH=%VERSION_PATCH%"

call "%_SCRIPT_ROOT%split_version.bat" "%_COMPARE_TGT_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_TGT_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 5: target version '%_COMPARE_TGT_VERSION%' not available or invalid
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
if "%_COMPARE_SRC_VERSION_MAJOR%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_major_version_ok
:compare_major_version_failed
rem support: compare_versions.bat 3.3 3.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if "%_COMPARE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 6: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.x.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 6

:compare_major_version_ok
if "%_COMPARE_SRC_VERSION_MAJOR%" NEQ "%_COMPARE_TGT_VERSION_MAJOR%" goto :version_compare_success
rem support: compare_versions.bat 3.1 3
if "%_COMPARE_TGT_MINOR_MISSING%" neq "" goto :version_compare_success

:compare_minor_version
if "%_COMPARE_SRC_VERSION_MINOR%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_minor_version_ok
:compare_minor_version_failed
rem support: compare_versions.bat 3.3.1 3.2.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if "%_COMPARE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 7: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 7

:compare_minor_version_ok
if "%_COMPARE_SRC_VERSION_MINOR%" NEQ "%_COMPARE_TGT_VERSION_MINOR%" goto :version_compare_success
rem support: compare_versions.bat 3.3.1 3.3
if "%_COMPARE_TGT_PATCH_MISSING%" neq "" goto :version_compare_success

:compare_patch_version
if "%_COMPARE_SRC_VERSION_PATCH%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_PATCH%" goto :version_compare_success
if "%_COMPARE_NO_ERRORS%" equ "" echo %_SCRIPT_NAME% error 8: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
call :_clean_temp_variables
exit /b 8

:version_compare_success
if "%_COMPARE_NO_INFO%" equ "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION%' met
rem if "%_COMPARE_NO_INFO%%_COMPARE_TGT_MINOR_MISSING%%_COMPARE_TGT_PATCH_MISSING%" equ "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' met
rem if "%_COMPARE_NO_INFO%" equ "" if "%_COMPARE_TGT_PATCH_MISSING%" neq "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%' met
rem if "%_COMPARE_NO_INFO%" equ "" if "%_COMPARE_TGT_MINOR_MISSING%" neq "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%' met
call :_clean_temp_variables
exit /b 0
