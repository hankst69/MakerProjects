@rem https://github.com/KDAB/GammaRay.git
@rem https://github.com/KDAB/GammaRay/blob/master/INSTALL.md
@echo off
set "_BGR_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*

set "_GR_VERSION=%MAKER_ENV_VERSION%"
set "_GT_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_GR_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_GR_TGT_ARCH%" equ "" set "_GR_TGT_ARCH=x64"
rem if "%_GR_VERSION%" equ "" set _GR_VERSION=3.1
set _GR_BUILD_TYPE=Release
set _GR_TGT_ARCH=x64

rem define target QT framework and build system
rem defaults:
set _GR_MSVS_VERSION=GEQ2019
set _GR_CMAKE_VERSION=GEQ3.16
set _GR_QT_VERSION=GEQ6.3
rem if we build GammaRay 3.0 this means that we like to meet the ChimaeraCUT3.6SDK Qt version from C:\Chimaera\CUT.SDK-3.6.0\bin\Release
if "%_GR_VERSION%" equ "3.0" set _GR_QT_VERSION=15.12
if "%_GR_VERSION%" equ "3.0" set _GR_MSVS_VERSION=2019
if "%_GR_VERSION%" equ "3.0" set _GR_CMAKE_VERSION=GEQ3.22

rem *** cloning sources ***
call "%MAKER_BUILD%\clone_gammaray.bat" %_GR_VERSION% %MAKER_ENV_VERBOSE% --silent
cd /d "%_BGR_START_DIR%"
rem defines: _GR_DIR
rem defines: _GR_SOURCES_DIR
if "%_GR_DIR%" EQU "" (echo cloning GammaRay %_GR_VERSION% failed &goto :Exit)
if "%_GR_SOURCES_DIR%" EQU "" (echo cloning GammaRay %_GR_VERSION% failed &goto :Exit)
if not exist "%_GR_DIR%" (echo cloning GammaRay %_GR_VERSION% failed &goto :Exit)
if not exist "%_GR_SOURCES_DIR%" (echo cloning GammaRay %_GR_VERSION% failed &goto :Exit)

set "_GR_BUILD_DIR=%_GR_DIR%\GammaRay_build%_GR_VERSION%"
set "_GR_BIN_DIR=%_GR_DIR%\GammaRay%_GR_VERSION%"

if "%MAKER_ENV_VERBOSE%" neq "" set _GR


rem *** cleaning GR build if demanded ***
if "%_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_GR_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_GR_BUILD_DIR%" 1>nul 2>nul
)


rem *** testing for existing GR build ***
if not exist "%_GR_BIN_DIR%\bin\gammaray.exe" goto :build_gr
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %_GR_VERSION% already available
  goto :gr_install_done
)
if %ERRORLEVEL% EQU 4 set "PATH=%_GR_BIN_DIR%\bin;%PATH%"
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %_GR_VERSION% already available
  goto :gr_install_done
)
call "%MAKER_BUILD%\build_qt.bat"
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %_GR_VERSION% already available
  goto :gr_install_done
)
echo error: GAMMARAY %_GR_VERSION% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %_GR_VERSION%'
goto :Exit


:build_gr
rem *** ensuring prerequisites ***

rem https://github.com/KDAB/GammaRay/blob/master/INSTALL.md
rem building Qt (libs and tools) requires:
rem
rem * mandatory: CMake 3.16 or newer
rem * mandatory: a C++ compiler with C++11 support (MSVC2019 or MSVC2022 or ...)
rem * mandatory: QT6.3 (or QT5.15 for GammaRay up to version 3.0)
rem * optional:  Ninja
rem 
echo.
echo building GammaRay %_GR_VERSION% from sources
echo see https://github.com/KDAB/GammaRay/blob/master/INSTALL.md
echo.
echo *** THIS REQUIRES Cmake 3.16 or newer
echo *** THIS REQUIRES QT6.3 or newer (for GammaRay up to version 3.0 QT5.15 minimum)
echo *** THIS REQUIRES VisualStudio 2019 or 2022
echo *** OTPIONAL: Ninja
echo.
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" %_GR_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" %_GR_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)
rem ensure qt
call "%MAKER_BUILD%\validate_qt.bat" %_GR_QT_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% EQU 0 goto :gr_configure
if "%_GR_VERSION%" neq "3.0" call "%MAKER_BUILD%\build_qt.bat"
if "%_GR_VERSION%" equ "3.0" call "%MAKER_BUILD%\build_qt.bat" %_GR_QT_VERSION%
call "%MAKER_BUILD%\validate_qt.bat" %_GR_QT_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)


rem *** configure GR build ***
:gr_configure
echo.
echo GAMMARAY-CONFIGURE %_GR_VERSION% (%_GR_BUILD_TYPE%)
rmdir /s /q "%_GR_BUILD_DIR%" 1>nul 2>nul
rmdir /s /q "%_GR_BIN_DIR%" 1>nul 2>nul 
mkdir "%_GR_BIN_DIR%"
mkdir "%_GR_BUILD_DIR%"
rem pushd "%_GR_BUILD_DIR%"
rem call cmake -S "%_GR_SOURCES_DIR%" -G Ninja -DCMAKE_INSTALL_PREFIX="%_GR_BIN_DIR%" .
rem popd
echo cmake -S "%_GR_SOURCES_DIR%" -B "%_GR_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_GR_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_GR_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_GR_BIN_DIR%" -DCMAKE_PREFIX_PATH="%_QT_BIN_DIR%"
call cmake -S "%_GR_SOURCES_DIR%" -B "%_GR_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_GR_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_GR_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_GR_BIN_DIR%" -DCMAKE_PREFIX_PATH="%_QT_BIN_DIR%"
:gr_configure_done


rem *** perform GR build ***
:gr_build
echo.
echo GAMMARAY-BUILD %_GR_VERSION% (%_GR_BUILD_TYPE%)
pushd "%_GR_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_GR_BUILD_TYPE%
popd
:gr_build_done

rem *** perform QT install ***
:gr_install
:gr_install_do
  echo.
  echo GAMMARAY-INSTALL %_GR_VERSION% (%_GR_BUILD_TYPE%)
  pushd "%_GR_BUILD_DIR%"
  call cmake --install .
  popd
:gr_install_test

rem todo...
goto :gr_install_done
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :gr_install_done
rem echo error: QT-INSTALL %_QT_VERSION% failed
goto :Exit

:gr_install_done
rem -- create shortcuts
echo @start /D "%_GR_BIN_DIR%\bin" /MAX /B %_GR_BIN_DIR%\bin\gammaray.exe %%*>"%MAKER_BIN%\gammaray.bat"
call "%MAKER_BUILD%\validate_gammaray.bat"


:Exit
cd /d "%_GR_DIR%"
cd /d "%_BGR_START_DIR%"
set _BGR_START_DIR=
set _REBUILD=
rem set _GR_VERSION=
rem set _GR_DIR=
rem set _GR_SOURCES_DIR=
rem set _GR_BUILD_DIR=
rem set _GR_BIN_DIR=
