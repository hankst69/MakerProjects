@rem https://github.com/gperftools/gperftools
@echo off
set "MAKER_BUILD=%~dp0"
set "_BGP_START_DIR=%cd%"

set _VERSION=
set _REBUILD=
set _BUILD_TYPE=
:param_loop
if "%~1" equ "" goto :param_loop_exit
set "_ARG_=%~1"
if /I "%~1" equ "--rebuild"  (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"         (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "Debug"      (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%~1" equ "Release"    (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%_ARG_:~0,1%" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if /I "!_ARG_:~0,1!" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if "%~1" neq "" if "%_VERSION%" equ "" (set "_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unknown argument '%~1' &shift &goto :param_loop)
:param_loop_exit
set _ARG_=

set "_GP_VERSION=%_VERSION%"
set "_GP_BUILD_TYPE=%_BUILD_TYPE%"
rem apply defaults
if "%_GP_VERSION%" equ ""    set _GP_VERSION=
if "%_GP_BUILD_TYPE%" equ "" set _GP_BUILD_TYPE=Release
set "_GP_TGT_ARCH=x64"


rem (1) *** cloning GPerf sources ***
echo GPERF-CLONE %_GP_VERSION%
call "%MAKER_BUILD%\clone_gperf.bat" %_GP_VERSION%
echo GPERF-CLONE %_GP_VERSION% done

rem defines: _GP_DIR
rem defines: _GP_SOURCES_DIR
if "%_GP_DIR%" EQU "" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if "%_GP_SOURCES_DIR%" EQU "" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if not exist "%_GP_DIR%" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)
if not exist "%_GP_SOURCES_DIR%" (echo cloning gperf %_GP_VERSION% failed &goto :Exit)

set "_GP_BUILD_DIR=%_GP_DIR%\gperf_build%_GP_VERSION%"
set "_GP_BIN_DIR=%_GP_DIR%\gperf%_GP_VERSION%"

rem (2) *** cleaning QT build if demanded ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_GP_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_GP_BUILD_DIR%" 1>nul 2>nul
)

rem (3) *** testing for existing gperf build ***
if exist "%_GP_BIN_DIR%\bin\gperf.exe" goto :install_gp_done


rem (4) *** ensuring prerequisites ***

rem https://doc.qt.io/qt-6/windows-building.html
rem building gperf requires:
rem
rem * mandatory: CMake 3.16 or newer
rem * mandatory: 
rem * mandatory: MSVC2019 or MSVC2022 or Mingw-w64 13.1
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" GEQ2019 amd64
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)

:configure_gp
echo.
echo GPERF-CONFIG %_GP_VERSION% %_GP_BUILD_TYPE% (Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR% %_GP_TGT_ARCH%)
cd "%_GP_SOURCES_DIR%"
echo cmake -S "%_GP_SOURCES_DIR%" -G "Visual Studio 17 2022" -B "%_GP_BUILD_DIR%" -A %_GP_TGT_ARCH% -DCMAKE_INSTALL_PREFIX="%_GP_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%"
call cmake -S . -G "Visual Studio 17 2022" -B "%_GP_BUILD_DIR%" -A %_GP_TGT_ARCH% -DCMAKE_INSTALL_PREFIX="%_GP_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%"
echo GPERF-CONFIG done

:build_gp
echo.
echo GPERF-BUILD (%_GP_BUILD_DIR%)
cd "%_GP_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_GP_BUILD_TYPE%
echo GPERF-BUILD done

:install_gp
echo.
echo GPERF-INSTALL (%_GP_BIN_DIR%)
cd "%_GP_BUILD_DIR%"
call cmake --install .

:install_gp_done
echo GPERF-INSTALL done

:ensure_gp
call "%MAKER_BUILD%\validate_gperf.bat" %_GP_VERSION% 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_GP_BIN_DIR%\bin"

:Exit
cd "%_GP_DIR%"
call "%MAKER_BUILD%\validate_gperf.bat" %_GP_VERSION%
