@echo off
call "%~dp0\maker_env.bat" %*

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_WFV_" 1>nul 2>nul
set "_WFV_THIS_DIR=%~dp0"
set "_WFV_START_DIR=%cd%"
set "_WFV_VERSION=%MAKER_ENV_VERSION%"
set "_WFV_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_WFV_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_WFV_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_WFV_TGT_ARCH%"   equ "" set _WFV_TGT_ARCH=x64
if "%_WFV_BUILD_TYPE%" equ "" set _WFV_BUILD_TYPE=MinSizeRel
rem apply hardcoded values
rem set _WFV_TGT_ARCH=x64
rem set _WFV_BUILD_TYPE=Debug
rem set _WFV_BUILD_TYPE=Release
rem set _WFV_BUILD_TYPE=MinSizeRel

rem welcome
echo BUILDING WFVIEW %_WFV_VERSION%

rem *** clone WFVIEW sources ***
call "%MAKER_BUILD%\clone_wfview.bat" %_WFV_VERSION% %MAKER_ENV_VERBOSE% --silent

cd /d "%_WFV_START_DIR%"
rem defines: WFVIEW_VERSION
rem defines: WFVIEW_DIR
rem defines: WFVIEW_BASE_DIR
rem defines: WFVIEW_SRC_DIR
if "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if "%WFVIEW_SCR_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_SCR_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)

set "_WFV_DIR=%WFVIEW_DIR%"
set "_WFV_SOURCES_DIR=%WFVIEW_SCR_DIR%"
set "_WFV_BUILD_DIR=%WFVIEW_BASE_DIR%_build%WFVIEW_VERSION%"
set "_WFV_BIN_DIR=%WFVIEW_BASE_DIR%%WFVIEW_VERSION%"

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
echo BUILDING WFVIEW %WFVIEW_VERSION% from sources
rem echo see https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
echo.
rem define target QT framework and build system versions:
rem find current required QT version in: https://github.com/victronenergy/venus/blob/master/configs/dunfell/repos.conf#L5
set _WFV_MSVS_VERSION=GEQ2019
set _WFV_NINJA_VERSION=
set _WFV_BUILD_SYSTEM=NINJA
set _WFV_QT_VERSION=6.8.3

call "%MAKER_SCRIPTS%\split_version.bat" "0.0.0" 1>nul
if "%WFVIEW_VERSION%" neq "" call "%MAKER_SCRIPTS%\split_version.bat" "%WFVIEW_VERSION%"
if "%VERSION_MAJOR%.%VERSION_MINOR%" equ "1.1" set _WFV_QT_VERSION=6.6.3
rem seems newest VS2022 (July 2025) requires Qt6.8.3 for CMake and Ninja to work
rem set _WFV_QT_VERSION=6.8.3

rem echo *** THIS REQUIRES QT 6.6.3 REMARK: find current required version in: https://github.com/victronenergy/venus/blob/master/configs/dunfell/repos.conf#L5
echo *** THIS REQUIRES QT %_WFV_QT_VERSION% REMARK: find current required version in: https://github.com/victronenergy/venus/blob/master/configs/dunfell/repos.conf#L5
echo *** THIS REQUIRES VisualStudio 2019 or 2022
echo.
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" %_WFV_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" %_WFV_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available - switchng to MSVS build system
  set _WFV_BUILD_SYSTEM=MSVS
  rem goto :Exit
)
rem ensure qt
call "%MAKER_BUILD%\ensure_qt.bat" %_WFV_QT_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
   goto :_exit
)

rem ensure 7z
rem call "%MAKER_BUILD%\ensure_7z.bat"
rem if %ERRORLEVEL% NEQ 0 (
rem    set "path=%path%;%_maker_dir%\tools"
rem    rem goto :_exit
rem )
rem ensure gzip
rem call "%MAKER_BUILD%\ensure_gzip.bat"
rem if %ERRORLEVEL% NEQ 0 (
rem    set "path=%path%;%_maker_dir%\tools"
rem    goto :_exit
rem )



rem *** cmake configure ***
:_configure
echo.
echo WFVIEW-CONFIGURE %WFVIEW_VERSION% (%_WFV_BUILD_TYPE%)
rem next 3 lines only work if the build folder is a sub folder within the source folder:
rem pushd "%_WFV_BUILD_DIR%"
rem call "%QT_CMAKE%" -DCMAKE_BUILD_TYPE=MinSizeRel ..\
rem popd
rem
cd /d "%_WFV_BUILD_DIR%"
rem
if /I "%_WFV_BUILD_SYSTEM%" equ "NINJA" goto :_configure_4_ninja
if /I "%_WFV_BUILD_SYSTEM%" equ "MSVS" goto :_configure_4_msvs
:_configure_4_ninja
 echo     qt-cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_WFV_BIN_DIR%"
 call "%QT_CMAKE%" -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_WFV_BIN_DIR%"
 goto :_configure_done
:_configure_4_msvs
 echo     qt-cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_WFV_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_WFV_BIN_DIR%"
 call "%QT_CMAKE%" -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_WFV_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_WFV_BIN_DIR%"  -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
 rem  "%QT_CMAKE%" -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_WFV_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_WFV_BIN_DIR%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%" --log-level=VERBOSE
 goto :_configure_done
:_configure_done


rem *** cmake build ***
:_build
echo.
echo WFVIEW-BUILD %WFVIEW_VERSION% (%_WFV_BUILD_TYPE%)
cd /d "%_WFV_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_WFV_BUILD_TYPE%
:_build_done

