@rem https://github.com/gperftools/gperftools
@echo off
set "MAKER_BUILD=%~dp0"
set "_BGPT_START_DIR=%cd%"

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

set "_GPT_VERSION=%_VERSION%"
set "_GPT_BUILD_TYPE=%_BUILD_TYPE%"
rem apply defaults
if "%_GPT_VERSION%" equ "" set _GPT_VERSION=
if "%_GPT_BUILD_TYPE%" equ "" set _GPT_=Release
set "_GPT_TGT_ARCH=x64"
set _GPT_BUILD_TYPE=Release


rem (1) *** cloning GPerf sources ***
call "%MAKER_BUILD%\clone_gperftools.bat" %_GPT_VERSION%
rem defines: _GPT_DIR
rem defines: _GPT_SOURCES_DIR
if "%_GPT_DIR%" EQU "" (echo cloning gperf %_GPT_VERSION% failed &goto :Exit)
if "%_GPT_SOURCES_DIR%" EQU "" (echo cloning gperf %_GPT_VERSION% failed &goto :Exit)
if not exist "%_GPT_DIR%" (echo cloning gperf %_GPT_VERSION% failed &goto :Exit)
if not exist "%_GPT_SOURCES_DIR%" (echo cloning gperf %_GPT_VERSION% failed &goto :Exit)

set "_GPT_BUILD_DIR=%_GPT_DIR%\build%_GPT_VERSION%"
set "_GPT_BIN_DIR=%_GPT_DIR%\gperftools%_GPT_VERSION%"


rem (2) *** cleaning QT build if demanded ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_GPT_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_GPT_BUILD_DIR%" 1>nul 2>nul
)

rem (3) *** testing for existing gperf build ***
if exist "%_GPT_BIN_DIR%\bin\tcmalloc_minimal.dll" goto :install_GPT_done


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

rem :configure_gpt
echo.
echo GPERFTOOLS-CONFIG %_GPT_VERSION% %_GPT_BUILD_TYPE% (Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR% x64)
cd "%_GPT_SOURCES_DIR%"
echo cmake -S "%_GPT_SOURCES_DIR%" -G "Visual Studio 17 2022" -B "%_GPT_BUILD_DIR%" -DCMAKE_INSTALL_PREFIX="%_GPT_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GPT_BUILD_TYPE%"
call cmake -S . -G "Visual Studio 17 2022" -B "%_GPT_BUILD_DIR%" -DCMAKE_INSTALL_PREFIX="%_GPT_BIN_DIR%" -DCMAKE_BUILD_TYPE="%_GPT_BUILD_TYPE%"
echo GPERFTOOLS-CONFIG done

rem :build_gpt
echo.
echo GPERFTOOLS-BUILD (%_GPT_BUILD_DIR%)
cd "%_GPT_BUILD_DIR%"
call cmake --build . --parallel 4 --config %_GPT_BUILD_TYPE%
echo GPERFTOOLS-BUILD done

rem :install_gpt
echo.
echo GPERFTOOLS-INSTALL (%_GPT_BIN_DIR%)
cd "%_GPT_BUILD_DIR%"
call cmake --install .

if not exist "%_GPT_BIN_DIR%" (
  mkdir "%_GPT_BIN_DIR%\bin"
  mkdir "%_GPT_BIN_DIR%\gperftools"
  call xcopy /S /Y /Q "%_GPT_BUILD_DIR%\%_GPT_BUILD_TYPE%" "%_GPT_BIN_DIR%\bin" 1>NUL
  call xcopy /S /Y /Q "%_GPT_BUILD_DIR%\gperftools" "%_GPT_BIN_DIR%\gperftools" 1>NUL
)
:install_GPT_done
echo GPERFTOOLS-INSTALL done

rem :ensure_gpt
if not exist "%_GPT_BIN_DIR%\bin\tcmalloc_minimal.dll" goto :Exit
call "%MAKER_BUILD%\validate_gperftools.bat" %_GPT_VERSION% 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_GPT_BIN_DIR%\bin"

:Exit
cd "%_GPT_DIR%"
"%MAKER_BUILD%\validate_gperftools.bat" %_GPT_VERSION%
