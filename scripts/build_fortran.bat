@rem https://fortran-lang.org/compilers/
@rem https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html
@rem https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler-download.html?operatingsystem=windows&distribution-windows=pip
@rem https://www.intel.com/content/www/us/en/developer/articles/system-requirements/fortran-compiler/2025.html
@rem https://www.intel.com/content/www/us/en/developer/articles/reference-implementation/intel-compilers-compatibility-with-microsoft-visual-studio-and-xcode.html
@rem https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/overview.html
@rem https://www.intel.com/content/www/us/en/docs/oneapi/installation-guide-windows/2025-2/intel-fortran-essentials.html#GUID-BAF3068A-5E28-419D-9000-F1CDBEC6FEAA
@echo off
call "%~dp0\maker_env.bat"
set "_BFRT_START_DIR=%cd%"
set "_BFRT_ARG1=%~1"

set _FRT_VERSION=
set _FRT_REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_FRT_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_FRT_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (if "%_FRT_VERSION%" equ "" set "_FRT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""             (echo error: unkown argument '%~1' &shift &goto :param_loop)

set "_FRT_ENV_DIR=%MAKER_ENV_BIN%\.ifort_env"

if "%_FRT_REBUILD%" neq "" (
  del /F /Q "%MAKER_ENV_BIN%\gfortran.bat" 2>NUL
  del /F /Q "%MAKER_ENV_BIN%\ifort.bat" 2>NUL
  del /F /Q "%MAKER_ENV_BIN%\ifx.bat" 2>NUL
  rmdir /s /q "%_FRT_ENV_DIR%" 1>nul 2>nul
  rmdir /s /q "%_FRT_SRC_DIR%" 1>nul 2>nul
)

rem test if ifort is already available
set _FRT_TOOL=gfortran.bat
rem if exist "%MAKER_ENV_BIN%\gfortran.bat" 
call "%MAKER_ENV_BIN%\gfortran.bat" --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_fortran
set _FRT_TOOL=ifort.bat
call "%MAKER_ENV_BIN%\ifort.bat" --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_fortran
set _FRT_TOOL=ifx.bat
call "%MAKER_ENV_BIN%\ifx.bat" --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_fortran


:FRT_build
echo.
echo installing ifort 
echo.

:build_gfortran
set _FRT_TOOL=gfortran.bat
set "_MGW_DIR=C:\ProgramData\mingw64"
set "_MGW_BIN_DIR=%_MGW_DIR%\mingw64\bin"
if not exist "%_MGW_BIN_DIR%\gfortran.exe" goto :build_fortran_OneApi
echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_ENV_BIN%\gfortran.bat"
echo @call "%_MGW_BIN_DIR%\gfortran.exe" %%*>>"%MAKER_ENV_BIN%\gfortran.bat"
goto :test_fortran

:build_ifort
echo *** THIS REQUIRES Python 3
echo.
rem --- validate python
call "%MAKER_DIR_SCRIPTS%\ensure_python.bat" 3 --no_infos
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)
if exist "%_FRT_ENV_DIR%\.venv_created" goto :test_fortran
:install_ifort
del /Y /Q "%MAKER_ENV_BIN%\ifort.bat"
call deactivate 1>nul 2>nul
if not exist "%_FRT_ENV_DIR%\.venv.created" (
  echo creating ifort environment ... ^(%_FRT_ENV_DIR%^)
  if not exist "%_FRT_ENV_DIR%" mkdir "%_FRT_ENV_DIR%"
  call python -m venv "%_FRT_ENV_DIR%" || exit /b
  call "%_FRT_ENV_DIR%\Scripts\activate.bat"
  rem
  echo.
  echo installing ifort ...
  call python -m pip install --upgrade pip    || exit /b
  call python -m pip install intel-fortran-rt || exit /b
  rem echo.
  echo done >"%_FRT_ENV_DIR%\.venv.created"
  call deactivate
)
if not exist "%_FRT_ENV_DIR%\.venv.created" (
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

echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_ENV_BIN%\ifort.bat"
echo @call "%_FRT_ENV_DIR%\Scripts\activate" >>"%MAKER_ENV_BIN%\ifort.bat"
echo @rem @call ifort.exe %%*>>"%MAKER_ENV_BIN%\ifort.bat"
echo @call ifx.exe %%*>>"%MAKER_ENV_BIN%\ifort.bat"
echo @call deactivate 1^>nul 2^>nul %%*>>"%MAKER_ENV_BIN%\ifort.bat"
rem type "%MAKER_ENV_BIN%\ifort.bat"
rem goto :test_fortran
rem
echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_ENV_BIN%\ifort.bat"
echo @call ifort %%*>>"%MAKER_ENV_BIN%\ifort.bat"
rem type "%MAKER_ENV_BIN%\ifort.bat"
goto :test_fortran


:test_fortran
rem test if PATH is already adapted to find fortran compiler
rem first change the current dir to not unwillingly call a local fortran from Maker project root and cause an iteration
cd /d "%MAKER_DIR_TOOLS%"
call %_FRT_TOOL% --validate 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%MAKER_ENV_BIN%"
call %_FRT_TOOL% --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_fortran_success
  
:test_fortran_failed
echo. error: fortran not available
goto :exit_script

:test_fortran_success
rem echo ifx /help
rem echo ifort /help
rem call ifort /help
call %_FRT_TOOL% --version /help

:exit_script
call deactivate 1>nul 2>nul
cd /d "%_BFRT_START_DIR%"
set _BFRT_START_DIR=
set _REBUILD=
goto :EOF