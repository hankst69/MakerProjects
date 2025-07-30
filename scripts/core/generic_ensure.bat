@echo off
pushd "%cd%"
call :_ge_validate %*
if %ERRORLEVEL% EQU 0 popd & exit /b 0
call :_ge_build %*
rem call :_ge_validate %*
if %ERRORLEVEL% EQU 0 popd & exit /b 0
popd
exit /b 999
goto :EOF

:_ge_validate
set "_PROJ_NAME=%~1"
set _PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "_PROJ_ARGS=%_PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%~dp0\maker_env.bat" %_PROJ_ARGS%
call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS%
if %ERRORLEVEL% EQU 0 exit /b 0
goto :EOF

:_ge_build
set "_PROJ_NAME=%~1"
set _PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "_PROJ_ARGS=%_PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%~dp0\maker_env.bat" %_PROJ_ARGS%
echo warning: %_PROJ_NAME% %MAKER_ENV_VERSION% is not available - trying to build from sources
if "%MAKER_ENV_VERBOSE%" neq "" echo on
call "%MAKER_BUILD%\build_%_PROJ_NAME%.bat" %_PROJ_ARGS%
if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
goto :EOF
