@rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
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

call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_VCG_" 1>nul 2>nul
set "_VCG_START_DIR=%cd%"
set "_VCG_VERSION=%MAKER_ENV_VERSION%"
set "_VCG_BUILD_SYSTEM=%MAKER_ENV_BUILDSYSTEM%"
set "_VCG_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_VCG_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_VCG_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_VCG_TGT_ARCH%"     equ "" set _VCG_TGT_ARCH=x64
if "%_VCG_BUILD_TYPE%"   equ "" set _VCG_BUILD_TYPE=Release
if "%_VCG_BUILD_SYSTEM%" equ "" set _VCG_BUILD_SYSTEM=msvs
rem apply hardcoded values
rem set _VCG_TGT_ARCH=x64
rem set _VCG_BUILD_TYPE=Debug
rem set _VCG_BUILD_TYPE=Release
rem set _VCG_BUILD_TYPE=MinSizeRel

rem welcome
echo BUILDING VENUS-GUIV2 %_VCG_VERSION% (%_VCG_BUILD_SYSTEM% %_VCG_TGT_ARCH% %_VCG_BUILD_TYPE%)

rem *** clone Victron GUI-V2 ***
call "%MAKER_BUILD%\clone_victron.bat" %_VCG_VERSION% %MAKER_ENV_VERBOSE% --silent
cd /d "%_VCG_START_DIR%"
rem defines: VICTRON_DIR
rem defines: VICTRON_GUIV2_VERSION
rem defines: VICTRON_GUIV2_BASE_DIR
rem defines: VICTRON_GUIV2_SRC_DIR
if "%VICTRON_DIR%" EQU "" (echo cloning Victron GUI-V2 failed &goto :EOF)
if "%VICTRON_GUIV2_SRC_DIR%" EQU "" (echo cloning Victron GUI-V2 failed &goto :EOF)
if not exist "%VICTRON_DIR%" (echo cloning Victron GUI-V2 failed &goto :EOF)
if not exist "%VICTRON_GUIV2_SRC_DIR%" (echo cloning Victron GUI-V2 failed &goto :EOF)

set "_VCG_DIR=%VICTRON_DIR%"
set "_VCG_SOURCES_DIR=%VICTRON_GUIV2_SRC_DIR%"
set "_VCG_BIN_DIR=%VICTRON_GUIV2_BASE_DIR%%VICTRON_GUIV2_VERSION%"
rem set "_VCG_BUILD_DIR=%VICTRON_GUIV2_BASE_DIR%_build%VICTRON_GUIV2_VERSION%"
set "_VCG_BUILD_DIR=%VICTRON_GUIV2_SRC_DIR%_build_%_VCG_BUILD_SYSTEM%%_WFV_TGT_ARCH%%_WFV_BUILD_TYPE%"

if "%MAKER_ENV_VERBOSE%" neq "" set _VCG_


rem *** cleaning old build if demanded ***
if "%_VCG_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_VCG_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_VCG_BUILD_DIR%" 1>nul 2>nul
)
if not exist "%_VCG_BIN_DIR%" mkdir "%_VCG_BIN_DIR%"
if not exist "%_VCG_BUILD_DIR%" mkdir "%_VCG_BUILD_DIR%"


rem *** testing for existing build ***
goto :_rebuild
if not exist "%_VCG_BIN_DIR%\bin\venus-gui-v2.exe" goto :_rebuild
goto :_install_test
rem not used here
rem echo try rebuilding via '%~n0 --rebuild %_VCG_VERSION%'
goto :_exit


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo BUILDING Victron Venus-GUI-V2 %VICTRON_GUIV2_VERSION% from sources
echo see https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
echo.
rem D:\GIT\Maker\projects\-Victron\venus-guiv2\bin>venus-gui-v2.exe --version
rem Victron gui version: v1.1.3
rem -> QT 6.6.3
rem D:\GIT\Maker>D:\GIT\Maker\projects\Victron\venus-guiv2\bin\venus-gui-v2.exe --version
rem Victron gui version: v1.2.7
rem -> QT 6.8.3
rem
rem define target QT framework and build system versions:
rem find current required QT version in: https://github.com/victronenergy/gui-v2/blob/main/scripts/.env
set _VCG_CMAKE_VERSION=GEQ3.22
set _VCG_MSVS_VERSION=GEQ2019
set _VCG_NINJA_VERSION=
set _VCG_QT_VERSION=6.8.3

call "%MAKER_SCRIPTS%\set_version_env.bat" "VICTRON_GUIV2" "%VICTRON_GUIV2_VERSION%"
if "%VICTRON_GUIV2__VERSION_MAJOR%.%VICTRON_GUIV2_VERSION_MINOR%" equ "1.1" set _VCG_QT_VERSION=6.6.3
rem seems newest VS2022 (July 2025) requires Qt6.8.3 for CMake and Ninja to work
rem set _VCG_QT_VERSION=6.8.3

echo *** THIS REQUIRES QT %_VCG_QT_VERSION% REMARK: find current required version in: https://github.com/victronenergy/gui-v2/blob/main/scripts/.env
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo *** THIS REQUIRES Cmake 3.22 or newer
echo.
rem ensure BuildSystem availability
if /I "%_VCG_BUILD_SYSTEM%" equ "gnu"  call "%MAKER_BUILD%\ensure_mingw.bat" %MAKER_ENV_VERBOSE%
if /I "%_VCG_BUILD_SYSTEM%" equ "msvs" call "%MAKER_BUILD%\ensure_msvs.bat" %_VCG_MSVS_VERSION% %_VCG_TGT_ARCH% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
if /I "%_VCG_BUILD_SYSTEM%" neq "gnu" if /I "%_VCG_BUILD_SYSTEM%" neq "msvs" (echo error: BuildSystem %_VCG_BUILD_SYSTEM% is not available &goto :_exit)

rem ensure ninja
if /I "%_VCG_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\validate_ninja.bat" %_VCG_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available - switching to MSVS build system
  goto :_exit
)
rem ensure qt
call "%MAKER_BUILD%\ensure_qt.bat" %_VCG_QT_VERSION% %MAKER_ENV_VERBOSE% %_VCG_BUILD_SYSTEM%
if %ERRORLEVEL% NEQ 0 (
   goto :_exit
)
rem validate qt-cmake
call "%MAKER_BUILD%\validate_qt-cmake.bat" %_VCG_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)


rem *** cmake configure ***
:_configure
echo.
echo VENUS-GUIV2-CONFIGURE %_VCG_VERSION% (%_VCG_BUILD_SYSTEM% %_VCG_TGT_ARCH% %_VCG_BUILD_TYPE%)
rem next 3 lines only work if the build folder is a sub folder within the source folder:
rem pushd "%_VCG_BUILD_DIR%"
rem call "%QT_CMAKE%" -DCMAKE_BUILD_TYPE=MinSizeRel ..\
rem popd
rem
cd /d "%_VCG_BUILD_DIR%"
rem
if /I "%_VCG_BUILD_SYSTEM%" equ "GNU" goto :_configure_4_gnu
if /I "%_VCG_BUILD_SYSTEM%" equ "MSVS" goto :_configure_4_msvs
:_configure_4_gnu
 echo qt-cmake -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" --install-prefix "%_VCG_BIN_DIR%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
 call "%QT_CMAKE%" -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" --install-prefix "%_VCG_BIN_DIR%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"  --log-level=VERBOSE
 goto :_configure_done
:_configure_4_msvs
 echo qt-cmake -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_VCG_TGT_ARCH% --install-prefix "%_VCG_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
 call "%QT_CMAKE%" -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_VCG_TGT_ARCH% --install-prefix "%_VCG_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"  --log-level=VERBOSE
 goto :_configure_done
:_configure_done


rem *** cmake build ***
:_build
echo.
echo VENUS-GUIV2-BUILD %VICTRON_GUIV2_VERSION% (%_VCG_BUILD_TYPE%)
cd /d "%_VCG_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_VCG_BUILD_TYPE%
:_build_done


rem *** cmake install ***
:_install
rem todo: skip install when already done...
:_install_do
echo.
echo VENUS-GUIV2-INSTALL %_VCG_VERSION% (%_VCG_BUILD_SYSTEM% %_VCG_TGT_ARCH% %_VCG_BUILD_TYPE% -^> %_VCG_BIN_DIR%)
cd /d "%_VCG_BUILD_DIR%"
call cmake --install . --config %_VCG_BUILD_TYPE%
rem echo on
rem set "_VCG_BIN_DIR=%_VCG_BUILD_DIR%"
mkdir "%_VCG_BIN_DIR%\bin" 1>nul 2>nul
copy /Y "%_VCG_BUILD_DIR%\bin\%_VCG_BUILD_TYPE%\venus*" "%_VCG_BIN_DIR%\bin"

:_install_test
rem todo: validate install success...
if not exist "%_VCG_BIN_DIR%\bin\venus-gui-v2.exe" echo error: Victron-GUI build failed &goto :_exit
goto :_install_done
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%QT_BIN_DIR%\bin"
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :_install_done
rem echo error: QT-INSTALL %_QT_VERSION% failed
goto :_exit

:_install_done
set "VCG_BIN_DIR=%_VCG_BIN_DIR%"
set "VCG_VERSION=%_VCG_VERSION%"
if "%MAKER_ENV_VERBOSE%" neq "" set VCG_
cd /d "%VCG_BIN_DIR%\bin"
echo.
echo to start venus-gui-v2 in demo modus:
echo %cd%\venus-gui-v2.exe --mock
rem start /D "%VCG_BIN_DIR%\bin" /MAX /B venus-gui-v2.exe --mock
start /D "%VCG_BIN_DIR%\bin" venus-gui-v2.exe --mock


:_exit
cd /d "%_VCG_START_DIR%"
rem cd /d "%VICTRON_DIR%"
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_VCG_"
