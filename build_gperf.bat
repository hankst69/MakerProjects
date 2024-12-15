@rem https://github.com/gperftools/gperftools
@echo off
call "%~dp0\maker_env.bat"
set "_BGP_START_DIR=%cd%"

set _GP_VERSION=
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (set "_GP_VERSION=%~1" &shift &goto :param_loop)


rem (1) *** cloning GPerf sources ***
call "%MAKER_ROOT%\clone_gperf.bat" %_GP_VERSION%
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
if exist "%_GP_BIN_DIR%\bin\tcmalloc_minimal.dll" goto :install_gp_done


rem (4) *** ensuring prerequisites ***

rem https://doc.qt.io/qt-6/windows-building.html
rem building gperf requires:
rem
rem * mandatory: CMake 3.16 or newer
rem * mandatory: 
rem * mandatory: MSVC2019 or MSVC2022 or Mingw-w64 13.1


:configure_gp
set _GP_BUILD_TYPE=Release
echo GPERF-CONFIG %_GP_VERSION% %_GP_BUILD_TYPE% (Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR% x64)
cd "%_GP_SOURCES_DIR%"
echo cmake -S "%_GP_SOURCES_DIR%" -G "Visual Studio 17 2022" -B "%_GP_BUILD_DIR%" -DCMAKE_INSTALL_PREFIX="%_LLVM_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%"
call cmake -S . -G "Visual Studio 17 2022" -B "%_GP_BUILD_DIR%" -DCMAKE_INSTALL_PREFIX="%_LLVM_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GP_BUILD_TYPE%"
echo GPERF-CONFIG done

:build_gp
echo GPERF-BUILD (%_GP_BUILD_DIR%)
cd "%_GP_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_GP_BUILD_TYPE%
echo GPERF-BUILD done

:install_gp
echo GPERF-INSTALL (%_GP_BIN_DIR%)
cd "%_GP_BUILD_DIR%"
call cmake --install .

if not exist "%_GP_BIN_DIR%" (
  mkdir "%_GP_BIN_DIR%\bin"
  mkdir "%_GP_BIN_DIR%\gperftools"
  call xcopy /S /Y /Q "%_GP_BUILD_DIR%\%_GP_BUILD_TYPE%" "%_GP_BIN_DIR%\bin" 1>NUL
  call xcopy /S /Y /Q "%_GP_BUILD_DIR%\gperftools" "%_GP_BIN_DIR%\gperftools" 1>NUL
)
:install_gp_done
echo GPERF-INSTALL done

:validate_gp
rem extend path to find gperf tools
call which tcmalloc_minimal.dll 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_GP_BIN_DIR%\bin"
call which tcmalloc_minimal.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo GPERF %_GP_VERSION% available &goto :validate_gp_done
echo error: GPERF %_GP_VERSION% failed
goto :Exit
:validate_gp_done

:Exit
cd "%_GP_DIR%"
goto :EOF

