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
call "%MAKER_SCRIPTS%\clear_temp_envs.bat" "_WVL_" 1>nul 2>nul
set "_WVL_THIS_DIR=%~dp0"
set "_WVL_START_DIR=%cd%"
set "_WVL_VERSION=%MAKER_ENV_VERSION%"
set "_WVL_BUILD_SYSTEM=%MAKER_ENV_BUILDSYSTEM%"
set "_WVL_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_WVL_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"
set "_WVL_REBUILD=%MAKER_ENV_REBUILD%"

rem apply defaults
if "%_WVL_TGT_ARCH%"     equ "" set _WVL_TGT_ARCH=x64
if "%_WVL_BUILD_TYPE%"   equ "" set _WVL_BUILD_TYPE=release
if "%_WVL_BUILD_SYSTEM%" equ "" set _WVL_BUILD_SYSTEM=msvs
set "_WVL_BUILD_CFG=%_WVL_BUILD_SYSTEM:~0,2%%_WVL_TGT_ARCH:~1%%_WVL_BUILD_TYPE:~0,3%"
set "_WVL_BUILD_INFO=%_WVL_VERSION% ^(%_WVL_BUILD_SYSTEM% %_WVL_TGT_ARCH% %_WVL_BUILD_TYPE%^)"

rem debug
if "%MAKER_ENV_VERBOSE%" neq "" set MAKER
if "%MAKER_ENV_VERBOSE%" neq "" set _WVL_
if "%MAKER_ENV_VERBOSE%" neq "" set _WFV_

rem welcome
echo BUILDING WFVIEW-LIBRARIES %_WVL_BUILD_INFO%

rem *** clone WFVIEW-Libs sources ***
call "%MAKER_BUILD%\clone_wfviewLibs.bat" %_WVL_VERSION% %MAKER_ENV_VERBOSE% --silent
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

set "_WVL_DIR=%WFVIEW_DIR%"
set "_WVL_SOURCES_DIR=%WFVIEW_LIBS_SRC_DIR%"
set "_WVL_BIN_DIR=%WFVIEW_LIBS_DIR%"
set "_WVL_BUILD_DIR=%WFVIEW_LIBS_SRC_DIR%\._%_WVL_BUILD_CFG%"

cd /d "%_WVL_START_DIR%"
if "%MAKER_ENV_VERBOSE%" neq "" set _WVL_

rem *** cleaning old build if demanded ***
if "%_WVL_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_WVL_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_WVL_BUILD_DIR%" 1>nul 2>nul
)
rem due potential switch from msvs libs to gnu .a files or vice versa, we have to always delete the bin folder to force reinstallation
rem remark: we use the same lib folder strucutre for both build systems (reference to inlude and lib folders in wfview CmakeLists.txt))
echo preparing build...
rem rmdir /s /q "%_WVL_BIN_DIR%" 1>nul 2>nul

rem ensure base folders exist
if not exist "%_WVL_BIN_DIR%" mkdir "%_WVL_BIN_DIR%"
if not exist "%_WVL_BUILD_DIR%" mkdir "%_WVL_BUILD_DIR%"


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo BUILDING WFVIEW-LIBRARIES %_WVL_BUILD_INFO% from sources
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo *** THIS REQUIRES Cmake 3.22 or newer
echo *** THIS REQUIRES Fortran (for Eigen)
echo.
set _WVL_CMAKE_VERSION=GEQ3.22
set _WVL_MSVS_VERSION=GEQ2019
set _WVL_MSVS_ARCH=amd64
set _WVL_NINJA_VERSION=GEQ1.10

rem ensure BuildSystem availability
if /I "%_WVL_BUILD_SYSTEM%" neq "gnu" if /I "%_WVL_BUILD_SYSTEM%" neq "msvs" (
  echo error: BuildSystem %_WVL_BUILD_SYSTEM% is not available
  goto :_exit
)
if /I "%_WVL_BUILD_SYSTEM%" equ "gnu"  call "%MAKER_BUILD%\ensure_mingw.bat" %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MinGW is not available
  goto :_exit
)
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" call "%MAKER_BUILD%\ensure_msvs.bat" %_WVL_MSVS_VERSION% %_WVL_MSVS_ARCH% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MSVS %_WVL_MSVS_VERSION% %_WVL_MSVS_ARCH% is not available
  goto :_exit
)

rem validate cmake
call "%MAKER_BUILD%\validate_cmake.bat" %_WVL_CMAKE_VERSION% %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: CMAKE %_WVL_CMAKE_VERSION% is not available
  goto :_exit
)
rem ensure ninja
if /I "%_WVL_BUILD_SYSTEM%" equ "gnu" if %ERRORLEVEL% NEQ 0 goto :_exit
call "%MAKER_BUILD%\validate_ninja.bat" %_WVL_NINJA_VERSION% --no_errors %MAKER_ENV_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA %_WVL_NINJA_VERSION% is not available
  goto :_exit
)

rem ensure fortran (ensure and validate not implemented yet) 
call "%MAKER_BUILD%\build_fortran.bat" %MAKER_ENV_VERBOSE%


echo.
echo BUILD WFVIEW-LIBRARIES %_WVL_BUILD_INFO%
rem
set "_WVL_CONFIG_GENERATOR=Ninja"
set "_WVL_CONFIG_OPTIONS="
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_WVL_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_WVL_CONFIG_OPTIONS=-A %_WVL_TGT_ARCH%"

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
rem WFVIEW_LIBFT4222_DIR
rem WFVIEW_LIBFT4222_SRC_DIR
rem WFVIEW_LIBFT4222_SRC_DIR_WINDOWS
rem WFVIEW_LIBFT4222_SRC_DIR_LINUX

echo.
echo.************************************************************************************************************************
echo.* building libft4222
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip"
if /i "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR_WINDOWS%"
if /i "%_WVL_BUILD_SYSTEM%" equ "gnu"  set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR_LINUX%"
set "_cmake_bin=%WFVIEW_LIBFT4222_DIR%"
call "%MAKER_SCRIPTS%\extract_in_folder.bat" "%_cmake_bin%" "%_cmake_src%" %MAKER_ENV_SILENT%
if /I "%_WVL_TGT_ARCH%" equ "x64" for /f %%i in ('dir /s /b "%WFVIEW_LIBFT4222_DIR%\*arm64*"') do if exist "%%~i\*" rmdir /s /q "%%~i"

echo.
echo.************************************************************************************************************************
echo.* building opus
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_OPUS_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\opus"
set "_cmake_bin=%WFVIEW_OPUS_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 

echo.
echo.************************************************************************************************************************
echo.* building rtaudio
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_RTAUDIO_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\rtaudio"
set "_cmake_bin=%WFVIEW_RTAUDIO_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 

echo.
echo.************************************************************************************************************************
echo.* building eigen
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_EIGEN_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\eigen"
set "_cmake_bin=%WFVIEW_EIGEN_DIR%"
rem there are issues building eigen as Debug
set "_WVL_BUILD_TYPE_EIGEN=%_WVL_BUILD_TYPE%"
set "_WVL_BUILD_TYPE_EIGEN=release"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE_EIGEN%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE_EIGEN% 
call cmake --install "." --config %_WVL_BUILD_TYPE_EIGEN% 

echo.
echo.************************************************************************************************************************
echo.* building portaudio
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_PORTAUDIO_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\portaudio"
set "_cmake_bin=%WFVIEW_PORTAUDIO_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 

echo.
echo.************************************************************************************************************************
echo.* building qcustomplot
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_QCUSTOMPLOT_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\qcustomplot"
set "_cmake_bin=%WFVIEW_QCUSTOMPLOT_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 

echo.
echo.************************************************************************************************************************
echo.* building hidapi
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_HIDAPI_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\hidapi"
set "_cmake_bin=%WFVIEW_HIDAPI_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 

rem echo.
rem echo.************************************************************************************************************************
rem echo.* building r8brain-free-src
rem echo.************************************************************************************************************************

:_exit
cd /d "%_WVL_BIN_DIR%"
rem cd /d "%_WVL_START_DIR%"
