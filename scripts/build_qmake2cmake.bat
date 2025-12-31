@rem https://www.piwheels.org/faq.html#venv
@echo off
call "%~dp0\maker_env.bat"
set "_BQMC_START_DIR=%cd%"
set "_BQMC_ARG1=%~1"

set _QMC_VERSION=
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (if "%_QMC_VERSION%" equ "" set "_QMC_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""             (echo error: unkown argument '%~1' &shift &goto :param_loop)

set "_QT_DIR=%MAKER_TOOLS%\Qt"
set "_QMC_ENV_DIR=%_QT_DIR%\.qm2cm_env"

if "%_REBUILD%" neq "" (
  rmdir /s /q "%_QMC_ENV_DIR%" 1>nul 2>nul
  del /F /Q "%MAKER_BIN%\qmake2cmake.bat" 2>NUL
)

rem test if qt-creater is already available
if not exist "%_QMC_ENV_DIR%\.venv_created" goto :qmc_build
if not exist "%MAKER_BIN%\qmake2cmake.bat"  goto :qmc_build

rem test if PATH is already adapted to find qtcreator.bat
rem first change the current dir to not unwillingly call the local qtcreator.bat from Maker project root and cause an iteration
cd "%MAKER_TOOLS%"
call qmake2cmake.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  goto :test_qm2cm_success
)
if exist "%MAKER_BIN%\qmake2cmake.bat" set "Path=%Path%;%MAKER_BIN%"
call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  goto :test_qm2cm_success
)

:qmc_build
del /F /Q "%MAKER_BIN%\qmake2cmake.bat" 2>NUL
echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_BIN%\qmake2cmake.bat"
echo @call "%_QMC_ENV_DIR%\Scripts\activate" >>"%MAKER_BIN%\qmake2cmake.bat"
echo @call qmake2cmake %%*>>"%MAKER_BIN%\qmake2cmake.bat"
echo @call deactivate 1^>nul 2^>nul %%*>>"%MAKER_BIN%\qmake2cmake.bat"
rem type "%MAKER_BIN%\qmake2cmake.bat"
echo @call "%MAKER_BIN%\qmake2cmake.bat" %%*>"%MAKER_BIN%\qm2cm.bat"

if exist "%_QMC_ENV_DIR%\.venv_created" goto :test_qm2cm

echo.
echo rebuilding Qmake2Cmake from sources
echo.
echo *** THIS REQUIRES Python 3
echo.

rem --- validate python
call "%MAKER_BUILD%\validate_python.bat" 3 --no_info
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)

call deactivate 1>nul 2>nul
if not exist "%_QMC_ENV_DIR%\.venv.created" (
  echo creating Qmake2Cmake environment ... ^(%_QMC_ENV_DIR%^)
  if not exist "%_QMC_ENV_DIR%" mkdir "%_QMC_ENV_DIR%"
  call python -m venv "%_QMC_ENV_DIR%" || exit /b
  call "%_QMC_ENV_DIR%\Scripts\activate.bat"
  rem
  echo.
  echo installing Qmake2Cmake ...
  call python -m pip install --upgrade pip  || exit /b
  call python -m pip install qmake2cmake  || exit /b
  rem echo.
  echo done >"%_QMC_ENV_DIR%\.venv.created"
  call deactivate
)
if not exist "%_QMC_ENV_DIR%\.venv.created" (
  echo error: Qmake2Cmake not available
  goto :exit_script
)
goto :test_qm2cm


:test_qm2cm
call qmake2cmake.bat --validate 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%MAKER_BIN%"
call qmake2cmake.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_qm2cm_success
  
:test_qm2cm_failed
echo. error: Qmake2Camke not available
goto :exit_script

:test_qm2cm_success
call qmake2cmake -h

:exit_script
call "%_QMC_ENV_DIR%\Scripts\deactivate.bat" 1>nul 2>nul
cd /d "%_BQMC_START_DIR%"
set _BQMC_START_DIR=
set _REBUILD=
goto :EOF