@rem https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler-download.html?operatingsystem=windows&distribution-windows=pip
@rem https://www.intel.com/content/www/us/en/developer/articles/system-requirements/fortran-compiler/2025.html
@rem https://www.intel.com/content/www/us/en/developer/articles/reference-implementation/intel-compilers-compatibility-with-microsoft-visual-studio-and-xcode.html
@rem https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/overview.html
@rem https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/intel-fortran-essentials.html#GUID-BAF3068A-5E28-419D-9000-F1CDBEC6FEAA
@echo off
call "%~dp0\maker_env.bat"
set "_BIFRT_START_DIR=%cd%"
set "_BIFRT_ARG1=%~1"

set _IFRT_VERSION=
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (if "%_IFRT_VERSION%" equ "" set "_IFRT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""             (echo error: unkown argument '%~1' &shift &goto :param_loop)

set "_IFRT_ENV_DIR=%MAKER_BIN%\.ifort_env"

if "%_REBUILD%" neq "" (
  rmdir /s /q "%_IFRT_ENV_DIR%" 1>nul 2>nul
  rmdir /s /q "%_IFRT_SRC_DIR%" 1>nul 2>nul
  del /F /Q "%MAKER_BIN%\ifort.bat" 2>NUL
)

rem test if ifort is already available
if not exist "%_IFRT_ENV_DIR%\.venv_created" goto :ifrt_build
if not exist "%MAKER_BIN%\ifort.bat"         goto :ifrt_build
if not exist "%_IFRT_SRC_DIR%\*"             goto :ifrt_build

rem test if PATH is already adapted to find qtcreator.bat
rem first change the current dir to not unwillingly call the local qtcreator.bat from Maker project root and cause an iteration
cd "%MAKER_TOOLS%"
call ifort.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  goto :test_ifort_success
)
if exist "%MAKER_BIN%\ifort.bat" set "Path=%Path%;%MAKER_BIN%"
call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  goto :test_ifort_success
)

:ifrt_build
echo.
echo installinig ifort
echo.
echo *** THIS REQUIRES Python 3
echo.
rem --- validate python
call "%MAKER_BUILD%\ensure_python.bat" 3 --no_info
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)

if exist "%_IFRT_ENV_DIR%\.venv_created" goto :test_ifort

:install_ifort
del /Y /Q "%MAKER_BIN%\ifort.bat"
call deactivate 1>nul 2>nul
if not exist "%_IFRT_ENV_DIR%\.venv.created" (
  echo creating ifort environment ... ^(%_IFRT_ENV_DIR%^)
  if not exist "%_IFRT_ENV_DIR%" mkdir "%_IFRT_ENV_DIR%"
  call python -m venv "%_IFRT_ENV_DIR%" || exit /b
  call "%_IFRT_ENV_DIR%\Scripts\activate.bat"
  rem
  echo.
  echo installing ifort ...
  call python -m pip install --upgrade pip    || exit /b
  call python -m pip install intel-fortran-rt || exit /b
  rem echo.
  echo done >"%_IFRT_ENV_DIR%\.venv.created"
  call deactivate
)
if not exist "%_IFRT_ENV_DIR%\.venv.created" (
  echo error: ifort not available
  goto :exit_script
)

rem
rem so far this is only the required runtime but not the intel fortan compiler itself
rem
rem https://www.pscad.com/knowledge-base/article/916
rem
rem ifx [option] file1 [file2...] [/link link_options]
rem
rem example:
rem ifx hello.f90 
rem 
rem To display all available compiler options, use the following command:
rem ifx /help

echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_BIN%\ifort.bat"
echo @call "%_IFRT_ENV_DIR%\Scripts\activate" >>"%MAKER_BIN%\ifort.bat"
echo @rem @call ifort.exe %%*>>"%MAKER_BIN%\ifort.bat"
echo @call ifx.exe %%*>>"%MAKER_BIN%\ifort.bat"
echo @call deactivate 1^>nul 2^>nul %%*>>"%MAKER_BIN%\ifort.bat"
rem type "%MAKER_BIN%\ifort.bat"
echo @call ifort %%*>"%MAKER_BIN%\ifx.bat"
goto :test_ifort


:test_ifort
call ifort.bat --validate 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%MAKER_BIN%"
call ifort.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_ifort_success
  
:test_ifort_failed
echo. error: Qmake2Camke not available
goto :exit_script

:test_ifort_success
echo ifx /help
echo ifort /help
call ifort /help

:exit_script
call "%_IFRT_ENV_DIR%\Scripts\deactivate.bat" 1>nul 2>nul
cd /d "%_BIFRT_START_DIR%"
set _BIFRT_START_DIR=
set _REBUILD=
goto :EOF