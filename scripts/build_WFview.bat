@echo off
if /I "%~1" equ "-?" goto :_usage
if /I "%~1" equ "-h" goto :_usage
if /I "%~1" equ "--help" goto :_usage
goto :_start

:_usage
echo USAGE:
echo %~n0 [version] [--gnu^|--msvs] [-?^|-h^|--help]
goto :EOF

:_start
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_WFV_" 1>nul 2>nul
set "_WFV_THIS_DIR=%~dp0"
set "_WFV_START_DIR=%cd%"
set "_WFV_VERSION=%MAKER_ENV_VERSION%"
set "_WFV_BUILD_SYSTEM=%MAKER_ENV_BUILDSYSTEM%"
set "_WFV_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_WFV_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_WFV_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_WFV_TGT_ARCH%"   equ ""   set _WFV_TGT_ARCH=x64
if "%_WFV_BUILD_TYPE%" equ ""   set _WFV_BUILD_TYPE=release
if "%_WFV_BUILD_SYSTEM%" equ "" set _WFV_BUILD_SYSTEM=gnu
rem apply hardcoded values
rem set _WFV_TGT_ARCH=x64
rem set _WFV_BUILD_TYPE=Debug
rem set _WFV_BUILD_TYPE=Release
rem set _WFV_BUILD_TYPE=MinSizeRel

rem debug
if "%MAKER_ENV_VERBOSE%" neq "" set MAKER
if "%MAKER_ENV_VERBOSE%" neq "" set _WFV_

rem welcome
echo BUILDING WFVIEW %_WFV_VERSION%(%_WFV_BUILD_SYSTEM% %_WFV_TGT_ARCH% %_WFV_BUILD_TYPE%)

rem *** clone WFVIEW sources ***
call "%MAKER_BUILD%\clone_wfview.bat" %_WFV_VERSION% %MAKER_ENV_VERBOSE% --silent
rem defines: WFVIEW_VERSION
rem defines: WFVIEW_DIR
rem defines: WFVIEW_BASE_DIR
rem defines: WFVIEW_SRC_DIR
if "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if "%WFVIEW_SRC_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_DIR%" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_SRC_DIR%" (echo cloning WFVIEW failed &goto :EOF)

set "_WFV_DIR=%WFVIEW_DIR%"
set "_WFV_SOURCES_DIR=%WFVIEW_SRC_DIR%"
set "_WFV_BIN_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%%WFVIEW_VERSION%"
set "_WFV_BUILD_DIR=%_WFV_SOURCES_DIR%\.build_%_WFV_BUILD_SYSTEM%%_WFV_TGT_ARCH%%_WFV_BUILD_TYPE%"

cd /d "%_WFV_START_DIR%"
if "%MAKER_ENV_VERBOSE%" neq "" set _WFV_

rem *** cleaning old build if demanded ***
if "%_WFV_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_WFV_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_WFV_BUILD_DIR%" 1>nul 2>nul
)
if not exist "%_WFV_BIN_DIR%" mkdir "%_WFV_BIN_DIR%"
if not exist "%_WFV_BUILD_DIR%" mkdir "%_WFV_BUILD_DIR%"


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo REBUILDING WFVIEW %WFVIEW_VERSION%(%_WFV_BUILD_SYSTEM% %_WFV_TGT_ARCH% %_WFV_BUILD_TYPE%) from sources
echo.
set _WFV_CMAKE_VERSION=GEQ3.22
set _WFV_MSVS_VERSION=GEQ2019
set _WFV_NINJA_VERSION=
set _WFV_QT_VERSION=6.8.3
echo *** THIS REQUIRES QT %_WFV_QT_VERSION%
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo *** THIS REQUIRES Cmake 3.22 or newer
echo.

rem ensure BuildSystem availability
if /I "%_WFV_BUILD_SYSTEM%" equ "gnu"  call "%MAKER_BUILD%\ensure_mingw.bat" %MAKER_ENV_VERBOSE%
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" call "%MAKER_BUILD%\ensure_msvs.bat" %_WFV_MSVS_VERSION% %_WFV_TGT_ARCH% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
if /I "%_WFV_BUILD_SYSTEM%" neq "gnu" if /I "%_WFV_BUILD_SYSTEM%" neq "msvs" (echo error: BuildSystem %_WFV_BUILD_SYSTEM% is not available &goto :_exit)
rem ensure ninja
if /I "%_WFV_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\validate_ninja.bat" %_WFV_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA is not available - switchng to MSVS build system
  goto :_exit
)
rem ensure qt
call "%MAKER_BUILD%\ensure_qt.bat" %_WFV_QT_VERSION% %MAKER_ENV_VERBOSE% %_WFV_BUILD_SYSTEM%
if %ERRORLEVEL% NEQ 0 (
   goto :_exit
)
rem validate qt-cmake
call "%MAKER_BUILD%\validate_qt-cmake.bat" %_VCG_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)


rem *** build required libraries ***
echo.
rem we fixate the buildsystem for the wfview-libraries to GNU since the eigen lib requires a fortran compiler which would require setup of Intel Fortran compiler for the windows build
rem call "%MAKER_BUILD%\build_wfviewlibs.bat" %_WFV_REBUILD% %_WFV_VERSION% %_WFV_BUILD_TYPE% %_WFV_TGT_ARCH% %MAKER_ENV_VERBOSE% %MAKER_ENV_SILENT% --gnu
call "%MAKER_BUILD%\build_wfviewlibs.bat" %_WFV_REBUILD% %_WFV_VERSION% %_WFV_BUILD_TYPE% %_WFV_TGT_ARCH% %MAKER_ENV_VERBOSE% %MAKER_ENV_SILENT% %_WFV_BUILD_SYSTEM%
if %ERRORLEVEL% NEQ 0 (
  echo error: BUILDING of WFVIEW-LIBRARIES failed
  goto :_exit
)
if "%WFVIEW_LIBS_DIR%" equ ""        (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if not exist "%WFVIEW_LIBS_DIR%"     (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if "%WFVIEW_LIBS_SRC_DIR%" equ ""    (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if not exist "%WFVIEW_LIBS_SRC_DIR%" (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)


rem *** generate CmakeLists.txt ***
if not exist "%_WFV_SOURCES_DIR%\CmakeLists.txt" (
  call "%MAKER_BUILD%\build_qmake2cmake.bat"
  if %ERRORLEVEL% NEQ 0 goto :_exit
  cd "%_WFV_SOURCES_DIR%"
  call qmake2cmake wfview.pro -o CmakeLists.txt --min-qt-version %_WFV_QT_VERSION%
)


rem *** cmake configure ***
:_configure
echo.
echo WFVIEW-CONFIGURE %WFVIEW_VERSION%(%_WFV_BUILD_SYSTEM% %_WFV_TGT_ARCH% %_WFV_BUILD_TYPE%)
cd /d "%_WFV_BUILD_DIR%"
set "_WFV_CONFIG_GENERATOR=Ninja"
set "_WFV_CONFIG_OPTIONS="
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" set "_WFV_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" set "_WFV_CONFIG_OPTIONS=-A %_WFV_TGT_ARCH%"
echo qt-cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_cmake_bin%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%"
call "%QT_CMAKE%" -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_cmake_bin%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" --log-level=VERBOSE
:_configure_done


rem *** cmake build ***
:_build
echo.
echo WFVIEW-BUILD %WFVIEW_VERSION%(%_WFV_BUILD_SYSTEM% %_WFV_TGT_ARCH% %_WFV_BUILD_TYPE%)
cd /d "%_WFV_BUILD_DIR%"
rem call cmake --build . --config %_WFV_BUILD_TYPE% --parallel 4
echo qt-cmake --build . --config %_WFV_BUILD_TYPE% 
rem call "%QT_CMAKE%" --build .
call "%QT_CMAKE%" --build . --config %_WFV_BUILD_TYPE% 
:_build_done

:_exit
cd /d "%_WFV_START_DIR%"
