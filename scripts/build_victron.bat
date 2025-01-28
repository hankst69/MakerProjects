@rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
@echo off
set "_BVCG_START_DIR=%cd%"

call "%~dp0\maker_env.bat" %*
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_VCG_" 1>nul 2>nul

set "_VCG_VERSION=%MAKER_ENV_VERSION%"
set "_VCG_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_VCG_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_VCG_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_VCG_TGT_ARCH%" equ "" set "_VCG_TGT_ARCH=x64"
set _VCG_BUILD_TYPE=Release
set _VCG_TGT_ARCH=x64

rem define target QT framework and build system defaults:
set _VCG_QT_VERSION=6.6.3
set _VCG_MSVS_VERSION=GEQ2019


rem *** clone Victron GUI-V2 ***
echo VENUS-GUIV2-CLONE %MAKER_ENV_VERSION%
call "%MAKER_BUILD%\clone_victron.bat" %MAKER_ENV_VERSION% %MAKER_ENV_VERBOSE% --silent
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
set "_VCG_BUILD_DIR=%VICTRON_GUIV2_BASE_DIR%_build%VICTRON_GUIV2_VERSION%"
set "_VCG_BIN_DIR=%_VICTRON_GUIV2_BASEDIR%%VICTRON_GUIV2_VERSION%"

if "%MAKER_ENV_VERBOSE%" neq "" set _VCG


rem *** cleaning old build if demanded ***
if "%_VCG_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_VCG_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_VCG_BUILD_DIR%" 1>nul 2>nul
)


rem *** testing for existing build ***
goto :_rebuild
rem todo adapt to Venus-QT-Gui...
if not exist "%VCG_BIN_DIR%\bin\gammaray.exe" goto :_rebuild
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %VCG_VERSION% already available
  goto :_install_done
)
if %ERRORLEVEL% EQU 4 set "PATH=%VCG_BIN_DIR%\bin;%PATH%"
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %VCG_VERSION% already available
  goto :_install_done
)
call "%MAKER_BUILD%\build_qt.bat"
call "%MAKER_BUILD%\validate_gammaray.bat" 1>nul
if %ERRORLEVEL% EQU 0 (
  echo GAMMARAY %VCG_VERSION% already available
  goto :_install_done
)
echo error: GAMMARAY %VCG_VERSION% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %VCG_VERSION%'
goto :_exit


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo building Victron Venus-GUI-V2 %VICTRON_GUIV2_VERSION% from sources
echo see https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2#building-for-desktop
echo.
echo *** THIS REQUIRES QT6.3.3 REMARK: find current required version in: https://github.com/victronenergy/venus/blob/master/configs/dunfell/repos.conf#L5
echo *** THIS REQUIRES VisualStudio 2019 or 2022
echo.
rem ensure msvs version and amd64 target architecture
call "%MAKER_BUILD%\ensure_msvs.bat" %_VCG_MSVS_VERSION% amd64 %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
rem ensure qt
call "%MAKER_BUILD%\validate_qt.bat" %_VCG_QT_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 call "%MAKER_BUILD%\build_qt.bat" %_VCG_QT_VERSION%
call "%MAKER_BUILD%\validate_qt.bat" %_VCG_QT_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
rem validate ninja
call "%MAKER_BUILD%\validate_ninja.bat" --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)


rem *** cmake configure ***
:_configure
echo.
echo VENUS-GUIV2-CONFIGURE %VICTRON_GUIV2_VERSION% (%_VCG_BUILD_TYPE%)
rmdir /s /q "%_VCG_BUILD_DIR%" 1>nul 2>nul
rmdir /s /q "%_VCG_BIN_DIR%" 1>nul 2>nul 
mkdir "%_VCG_BIN_DIR%"
mkdir "%_VCG_BUILD_DIR%"
rem next 3 lines only work if the build folder is a sub folder within the source folder:
rem pushd "%_VCG_BUILD_DIR%"
rem call "%QT_CMAKE%" -DCMAKE_BUILD_TYPE=MinSizeRel ..\
rem popd
rem
pushd "%_VCG_BUILD_DIR%"
rem
rem          qt-cmake -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_VCG_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%"
rem call "%QT_CMAKE%" -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_VCG_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%"  -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
rem call "%QT_CMAKE%" -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%" -A %_VCG_TGT_ARCH% -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%"  --log-level=VERBOSE  -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
rem
 echo     qt-cmake -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%"
 call "%QT_CMAKE%" -S "%_VCG_SOURCES_DIR%" -B "%_VCG_BUILD_DIR%" -G "Ninja" -DCMAKE_BUILD_TYPE="%_VCG_BUILD_TYPE%" -DCMAKE_INSTALL_PREFIX="%_VCG_BIN_DIR%"
popd
:_configure_done


rem *** cmake build ***
:_build
echo.
echo VENUS-GUIV2-BUILD %VICTRON_GUIV2_VERSION% (%_VCG_BUILD_TYPE%)
pushd "%_VCG_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_VCG_BUILD_TYPE%
popd
:_build_done


rem *** cmake install ***
:_install
rem todo: skip install when already done...
:_install_do
echo.
echo VENUS-GUIV2-INSTALL %VICTRON_GUIV2_VERSION% (%_VCG_BUILD_TYPE%)
pushd "%_VCG_BUILD_DIR%"
call cmake --install .
popd

:_install_test
rem todo: validate install success...
goto :_install_done
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%QT_BIN_DIR%\bin"
rem call which Qt6WebSockets.dll 1>nul 2>nul
rem if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :_install_done
rem echo error: QT-INSTALL %_QT_VERSION% failed
goto :_exit

:_install_done
rem -- create shortcuts
rem echo @start /D "%_GR_BIN_DIR%\bin" /MAX /B %_GR_BIN_DIR%\bin\gammaray.exe %%*>"%MAKER_BIN%\gammaray.bat"
rem call "%MAKER_BUILD%\validate_victron-gui.bat"


:_exit
cd /d "%_VCG_DIR%"
cd /d "%_BVCG_START_DIR%"
set _BVCG_START_DIR=
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_VCG_"
