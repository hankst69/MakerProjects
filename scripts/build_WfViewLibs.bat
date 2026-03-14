@echo off
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_WFVL_" 1>nul 2>nul
set "_WFVL_THIS_DIR=%~dp0"
set "_WFVL_START_DIR=%cd%"
set "_WFVL_VERSION=%MAKER_ENV_VERSION%"
set "_WFVL_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_WFVL_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_WFVL_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_WFVL_TGT_ARCH%"   equ "" set _WFVL_TGT_ARCH=x64
if "%_WFVL_BUILD_TYPE%" equ "" set _WFVL_BUILD_TYPE=release
rem apply hardcoded values
rem set _WFVL_TGT_ARCH=x64
rem set _WFVL_BUILD_TYPE=Debug
rem set _WFVL_BUILD_TYPE=Release
rem set _WFVL_BUILD_TYPE=MinSizeRel

rem welcome
echo BUILDING WFVIEW-Libs %_WFVL_VERSION% %_WFVL_TGT_ARCH% %_WFVL_BUILD_TYPE%

rem *** clone WFVIEW-Libs sources ***
call "%MAKER_BUILD%\clone_wfviewLibs.bat" %_WFVL_VERSION% %MAKER_ENV_VERBOSE% --silent

cd /d "%_WFVL_START_DIR%"
rem defines: WFVIEW_VERSION
rem defines: WFVIEW_DIR
rem defines: WFVIEW_BASE_DIR
rem defines: WFVIEW_SRC_DIR
if "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW-Libs failed &goto :EOF)
if "%WFVIEW_LIBS_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if "%WFVIEW_LIBS_SRC_DIR%" EQU "" (echo cloning WFVIEW-Libs failed &goto :EOF)
if not exist "%WFVIEW_DIR%" (echo cloning WFVIEW-Libs failed &goto :EOF)
if not exist "%WFVIEW_LIBS_SRC_DIR%" (echo cloning WFVIEW-Libs failed &goto :EOF)

set "_WFVL_DIR=%WFVIEW_DIR%"
set "_WFVL_SOURCES_DIR=%WFVIEW_LIBS_SRC_DIR%"
set "_WFVL_BIN_DIR=%WFVIEW_LIBS_DIR%"
set "_WFVL_BUILD_DIR=%WFVIEW_LIBS_SRC_DIR%\.build"

if "%MAKER_ENV_VERBOSE%" neq "" set _WFVL_

rem *** cleaning old build if demanded ***
if "%_WFVL_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_WFVL_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_WFVL_BUILD_DIR%" 1>nul 2>nul
)
if not exist "%_WFVL_BIN_DIR%" mkdir "%_WFVL_BIN_DIR%"
if not exist "%_WFVL_BUILD_DIR%" mkdir "%_WFVL_BUILD_DIR%"


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo BUILDING WFVIEW-Libs %WFVIEW_VERSION% from sources
rem echo see https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
echo.
rem define target QT framework and build system versions:
rem find current required QT version in: https://github.com/victronenergy/venus/blob/master/configs/dunfell/repos.conf#L5
set _WFVL_MSVS_VERSION=GEQ2019
set _WFVL_NINJA_VERSION=
set _WFVL_BUILD_SYSTEM=Ninja
set _WFVL_BUILD_SYSTEM=msvs

rem set _WFVL_QT_VERSION=6.8.3
rem echo *** THIS REQUIRES QT %_WFVL_QT_VERSION%
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo.

rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" %_WFVL_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
if /I "%_WFVL_BUILD_SYSTEM%" equ "Ninja" call "%MAKER_BUILD%\ensure_mingw.bat"
if /I "%_WFVL_BUILD_SYSTEM%" equ "Ninja" if %ERRORLEVEL% NEQ 0 goto :_exit

rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" %_WFVL_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available - switchng to MSVS build system
  set _WFVL_BUILD_SYSTEM=MSVS
  rem goto :Exit
)
rem ensure qt
rem call "%MAKER_BUILD%\ensure_qt.bat" %_WFVL_QT_VERSION% %MAKER_ENV_VERBOSE%
rem if %ERRORLEVEL% NEQ 0 (
rem    goto :_exit
rem )


echo.
echo BUILD WFVIEW-LIBRARIES (%_WFVL_BUILD_TYPE%)
rem
set "_WFVL_CONFIG_GENERATOR=Ninja"
set "_WFVL_CONFIG_OPTIONS="
if /I "%_WFVL_BUILD_SYSTEM%" equ "MSVS" set "_WFVL_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WFVL_BUILD_SYSTEM%" equ "MSVS" set "_WFVL_CONFIG_OPTIONS=-A %_WFVL_TGT_ARCH%"

set "_src_opus=%WFVIEW_OPUS_SRC_DIR%"
set "_bld_opus=%_WFVL_BUILD_DIR%\opus%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_bin_opus=%WFVIEW_OPUS_DIR%"
cd /d "%_bld_opus%"
echo cmake -S "%_src_opus%" -B "%_bld_opus%" --install-prefix "%_bin_opus%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%"
call cmake -S "%_src_opus%" -B "%_bld_opus%" --install-prefix "%_bin_opus%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
cd /d "%_bld_opus%"
echo cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
cd /d "%_bld_opus%"
echo cmake --install "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 


:_exit
cd /d "%_WFVL_BIN_DIR%"
cd /d "%_WFVL_START_DIR%"
