@rem https://github.com/gperftools/gperftools
@echo off
set "_BGP_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
rem if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem init with command line arguments
set "_GP_VERSION=%MAKER_ENV_VERSION%"
set "_GP_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_GP_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_GP_BUILD_SYSTEM=%MAKER_ENV_BUILDSYSTEM%"

rem apply defaults
if "%_GP_VERSION%" equ ""      set _GP_VERSION=
if "%_GP_TGT_ARCH%" equ ""     set _GP_TGT_ARCH=x64
if "%_GP_BUILD_TYPE%" equ ""   set _GP_BUILD_TYPE=Release
if "%_GP_BUILD_SYSTEM%" equ "" set _GP_BUILD_SYSTEM=msvs
set "_GP_BUILD_CFG=%_GP_BUILD_SYSTEM:~0,2%%_GP_TGT_ARCH:~1%%_GP_BUILD_TYPE:~0,3%"

rem take shortcut if possible
set ERRORLEVEL=
call "%MAKER_BUILD%\validate_gperf.bat" "%_GP_VERSION%" %_GP_BUILD_SYSTEM% %_GP_TGT_ARCH% %_GP_BUILD_TYPE% %MAKER_ENV_VERBOSE% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit

rem install/build...
echo BUILDING GPERF %_GP_VERSION% (%_GP_BUILD_SYSTEM% %_GP_TGT_ARCH% %_GP_BUILD_TYPE%)

rem (1) *** cloning GPerf sources ***
call "%MAKER_BUILD%\clone_gperf.bat" "%_GP_VERSION%" %MAKER_ENV_VERBOSE%

rem defines: _GP_DIR
rem defines: _GP_SOURCES_DIR
if "%_GP_DIR%" EQU "" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if "%_GP_SOURCES_DIR%" EQU "" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if not exist "%_GP_DIR%" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if not exist "%_GP_SOURCES_DIR%" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)

set "_GP_BUILD_DIR=%_GP_DIR%\._%_GP_VERSION%%_GP_BUILD_CFG%"
set "_GP_BIN_DIR=%_GP_DIR%\gperf%_GP_VERSION%-%_GP_BUILD_SYSTEM%"

rem (2) *** cleaning QT build if demanded ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_GP_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_GP_BUILD_DIR%" 1>nul 2>nul
)

rem (3) *** testing for existing gperf build ***
if "%MAKER_ENV_VERBOSE%" neq "" echo on
if exist "%_GP_BIN_DIR%\bin\gperf.exe" goto :install_gp_done


rem (4) *** ensuring prerequisites ***

rem https://doc.qt.io/qt-6/windows-building.html
rem building gperf requires:
rem
rem * mandatory: CMake 3.16 or newer
rem * mandatory: 
rem * mandatory: MSVC2019 or MSVC2022 or Mingw-w64 13.1
rem ensure msvs version and amd64 target architecture
rem ensure msvs version and amd64 target architecture or MinGW gcc
rem
set _GP_NINJA_VERSION=
set _GP_CMAKE_VERSION=GEQ3.16
set _GP_MSVS_VERSION=GEQ2019
set _GP_MSVS_ARCH=amd64
if "%MAKER_ENV_VERBOSE%" neq "" set _GP_

if /I "%_GP_BUILD_SYSTEM%" equ "msvs" call "%MAKER_BUILD%\ensure_msvs.bat" %_GP_MSVS_VERSION% %_GP_MSVS_ARCH% %MAKER_ENV_VERBOSE%
if /I "%_GP_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\ensure_gcc.bat" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
if /I "%_GP_BUILD_SYSTEM%" neq "gnu" if /I "%_GP_BUILD_SYSTEM%" neq "msvs" (echo error: BuildSystem %_GP_BUILD_SYSTEM% is not available &goto :Exit)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" %_GP_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
if /I "%_GP_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  goto :Exit
)


:configure_gp
echo.
echo GPERF-CONFIGURE %_GP_VERSION% (%_GP_BUILD_SYSTEM% %_GP_TGT_ARCH% %_GP_BUILD_TYPE%)
if not exist "%_GP_BUILD_DIR%" mkdir "%_GP_BUILD_DIR%"
cd /d "%_GP_SOURCES_DIR%"
rem echo cmake -S "%_GP_SOURCES_DIR%" -B "%_GP_BUILD_DIR%" -G "Visual Studio 17 2022"  -A %_GP_TGT_ARCH% -DCMAKE_INSTALL_PREFIX="%_GP_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%"
set "_GP_CONFIG_GENERATOR=Ninja"
set "_GP_CONFIG_OPTIONS="
if /I "%_GP_BUILD_SYSTEM%" equ "msvs" set "_GP_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_GP_BUILD_SYSTEM%" equ "msvs" set "_GP_CONFIG_OPTIONS=-A %_GP_TGT_ARCH%"
echo cmake -S "%_GP_SOURCES_DIR%" -B "%_GP_BUILD_DIR%" --install-prefix "%_GP_BIN_DIR%" -G "%_GP_CONFIG_GENERATOR%" %_GP_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%" --log-level=VERBOSE
call cmake -S "%_GP_SOURCES_DIR%" -B "%_GP_BUILD_DIR%" --install-prefix "%_GP_BIN_DIR%" -G "%_GP_CONFIG_GENERATOR%" %_GP_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%" --log-level=VERBOSE
echo GPERF-CONFIG done

:build_gp
echo.
echo GPERF-BUILD (%_GP_BUILD_DIR%)
cd /d "%_GP_BUILD_DIR%"
call cmake --build . --config %_GP_BUILD_TYPE% &rem --parallel 4
echo GPERF-BUILD done

:install_gp
echo.
echo GPERF-INSTALL (%_GP_BIN_DIR%)
cd /d "%_GP_BUILD_DIR%"
call cmake --install .

:install_gp_done
echo GPERF-INSTALL done

:ensure_gp
call "%MAKER_BUILD%\validate_gperf.bat" "%_GP_VERSION%" %_GP_BUILD_SYSTEM% %_GP_TGT_ARCH% %_GP_BUILD_TYPE% %MAKER_ENV_VERBOSE% --no_warnings --no_errors --no_info
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_GP_BIN_DIR%\bin"

:Exit
cd /d "%_GP_DIR%"
call "%MAKER_BUILD%\validate_gperf.bat" "%_GP_VERSION%" %_GP_BUILD_SYSTEM% %_GP_TGT_ARCH% %_GP_BUILD_TYPE% %MAKER_ENV_VERBOSE% --no_warnings
