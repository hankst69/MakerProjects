@echo off
if /I "%~1" equ "-?" goto :_usage
if /I "%~1" equ "-h" goto :_usage
if /I "%~1" equ "--help" goto :_usage
goto :_start

:_usage
echo USAGE:
echo %~n0 [version] [--use_gcc] [-?^|-h^|--help]
goto :EOF

:_start
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

rem decide Build-Suite (Microsoft vs. GNU)
set _WFVL_USE_GCC=
if /I "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--use_gcc" set _WFVL_USE_GCC=--use_gcc
if /I "%MAKER_ENV_UNKNOWN_SWITCH_2%" equ "--use_gcc" set _WFVL_USE_GCC=--use_gcc
set _WFVL_BUILD_SYSTEM=msvs
set "_WFVL_BUILD_APPENDIX=_msvs"
if /I "%_WFVL_USE_GCC%" neq "" set _WFVL_BUILD_SYSTEM=gnu
if /I "%_WFVL_USE_GCC%" neq "" set _WFVL_BUILD_APPENDIX=


rem welcome
echo BUILDING WFVIEW-Libs%_WFVL_VERSION% : %_WFVL_TGT_ARCH% %_WFVL_BUILD_TYPE% %_WFVL_BUILD_SYSTEM%


rem *** clone WFVIEW-Libs sources ***
call "%MAKER_BUILD%\clone_wfviewLibs.bat" %_WFVL_VERSION% %MAKER_ENV_VERBOSE% --silent
rem defines: WFVIEW_VERSION
rem defines: WFVIEW_DIR
rem defines: WFVIEW_BASE_DIR
rem defines: WFVIEW_LIBS_DIR
rem defines: WFVIEW_LIBS_SRC_DIR
if "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW-Libs failed &goto :EOF)
if "%WFVIEW_LIBS_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if "%WFVIEW_LIBS_SRC_DIR%" EQU "" (echo cloning WFVIEW-Libs failed &goto :EOF)
if not exist "%WFVIEW_DIR%" (echo cloning WFVIEW-Libs failed &goto :EOF)
if not exist "%WFVIEW_LIBS_SRC_DIR%" (echo cloning WFVIEW-Libs failed &goto :EOF)

set "_WFVL_DIR=%WFVIEW_DIR%"
set "_WFVL_SOURCES_DIR=%WFVIEW_LIBS_SRC_DIR%"
set "_WFVL_BIN_DIR=%WFVIEW_LIBS_DIR%"
set "_WFVL_BUILD_DIR=%WFVIEW_LIBS_SRC_DIR%\.build%_WFVL_BUILD_APPENDIX%"

cd /d "%_WFVL_START_DIR%"
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
echo.
set _WFVL_CMAKE_VERSION=GEQ3.22
set _WFVL_MSVS_VERSION=GEQ2019
set _WFVL_NINJA_VERSION=
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo *** THIS REQUIRES Cmake 3.22 or newer
echo.

rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" %_WFVL_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
rem ensure msvs version and amd64 target architecture or MinGW gcc
if /I "%_WFVL_BUILD_SYSTEM%" neq "gnu" call "%MAKER_BUILD%\ensure_msvs.bat" %_WFVL_MSVS_VERSION% %_WFVL_TGT_ARCH% %MAKER_ENV_VERBOSE%
if /I "%_WFVL_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\ensure_gcc.bat" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  goto :_exit
)
rem ensure ninja
if /I "%_WFVL_BUILD_SYSTEM%" equ "gnu" call "%MAKER_BUILD%\ensure_mingw.bat"
if /I "%_WFVL_BUILD_SYSTEM%" equ "gnu" if %ERRORLEVEL% NEQ 0 goto :_exit
call "%MAKER_BUILD%\validate_ninja.bat" %_WFVL_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available - switchng to MSVS build system
  set _WFVL_BUILD_SYSTEM=msvs
  rem goto :_exit
)

echo.
echo BUILD WFVIEW-LIBRARIES (%_WFVL_BUILD_TYPE%)
rem
set "_WFVL_CONFIG_GENERATOR=Ninja"
set "_WFVL_CONFIG_OPTIONS="
if /I "%_WFVL_BUILD_SYSTEM%" equ "msvs" set "_WFVL_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WFVL_BUILD_SYSTEM%" equ "msvs" set "_WFVL_CONFIG_OPTIONS=-A %_WFVL_TGT_ARCH%"

rem WFVIEW_OPUS_DIR
rem WFVIEW_OPUS_SRC_DIR
rem WFVIEW_RTAUDIO_DIR
rem WFVIEW_RTAUDIO_SRC_DIR
rem WFVIEW_EIGEN_DIR
rem WFVIEW_EIGEN_SRC_DIR
rem WFVIEW_PORTAUDIO_DIR
rem WFVIEW_PORTAUDIO_SRC_DIR
rem WFVIEW_QCUSTOMPLOT_DIR
rem WFVIEW_QCUSTOMPLOT_SRC_DIR
rem WFVIEW_HIDAPI_DIR
rem WFVIEW_HIDAPI_SRC_DIR

set "_cmake_src=%WFVIEW_OPUS_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\opus_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_OPUS_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 

set "_cmake_src=%WFVIEW_RTAUDIO_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\rtaudio_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_RTAUDIO_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 

set "_cmake_src=%WFVIEW_EIGEN_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\eigen_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_EIGEN_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 

set "_cmake_src=%WFVIEW_PORTAUDIO_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\portaudio_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_PORTAUDIO_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 

set "_cmake_src=%WFVIEW_QCUSTOMPLOT_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\qcustomplot_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_QCUSTOMPLOT_DIR%"
rem if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
rem cd /d "%_cmake_bld%"
rem call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
rem call cmake --build "." --config %_WFVL_BUILD_TYPE% 
rem call cmake --install "." --config %_WFVL_BUILD_TYPE% 

set "_cmake_src=%WFVIEW_HIDAPI_SRC_DIR%"
set "_cmake_bld=%_WFVL_BUILD_DIR%\hidapi_%_WFVL_TGT_ARCH%%_WFVL_BUILD_TYPE%"
set "_cmake_bin=%WFVIEW_HIDAPI_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WFVL_CONFIG_GENERATOR%" %_WFVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WFVL_BUILD_TYPE% 
call cmake --install "." --config %_WFVL_BUILD_TYPE% 

:_exit
cd /d "%_WFVL_BIN_DIR%"
rem cd /d "%_WFVL_START_DIR%"
