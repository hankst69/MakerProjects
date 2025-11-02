@echo off
rem pushd "%cd%"
rem echo *** GENERIC_ENSURE "%*" ***


:ge_main
rem echo call :ge_validate %*
call :ge_validate %* --
if %ERRORLEVEL% EQU 0 goto :EOF
rem echo call :ge_build %*
call :ge_build %* 
if %ERRORLEVEL% EQU 0 goto :EOF
exit /b %ERRORLEVEL%
goto :EOF


:ge_validate
set "_PROJ_NAME=%~1"
set _PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "_PROJ_ARGS=%_PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%~dp0\maker_env.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
if "%MAKER_ENV_VERBOSE%" neq "" echo "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS% 1>nul 2>nul
rem echo %ERRORLEVEL%
if %ERRORLEVEL% EQU 0 call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
goto :EOF


:ge_build
set "_PROJ_NAME=%~1"
set _PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "_PROJ_ARGS=%_PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%~dp0\maker_env.bat" %_PROJ_ARGS%
echo warning: %_PROJ_NAME% %MAKER_ENV_VERSION% is not available - trying to build from sources
if "%MAKER_ENV_VERBOSE%" neq "" echo "%MAKER_BUILD%\build_%_PROJ_NAME%.bat" %_PROJ_ARGS%
call "%MAKER_BUILD%\build_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
goto :EOF
