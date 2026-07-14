@echo off
if /I "%~1" equ "-?" goto :_usage
if /I "%~1" equ "-h" goto :_usage
if /I "%~1" equ "--help" goto :_usage
goto :_start

:_usage
echo USAGE:
echo %~n0 [version] [--gnu^|--msvs] [--release^|--debug] [-?^|-h^|--help]
goto :EOF

:_start
call "%~dp0\maker_env.bat" %*
call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_WVL_" 1>nul 2>nul
set "_WVL_THIS_DIR=%~dp0"
set "_WVL_START_DIR=%cd%"

set "_WVL_VERSION=%MAKER_VERSION%"
set "_WVL_REBUILD=%MAKER_REBUILD%"
set "_WVL_BUILD_ARCH=%MAKER_BUILD_ARCH%"
set "_WVL_BUILD_TYPE=%MAKER_BUILD_TYPE%"
set "_WVL_BUILD_MODE=%MAKER_BUILD_MODE%"
set "_WVL_BUILD_SYSTEM=%MAKER_BUILD_SYSTEM%"
set "_WVL_BUILD_CONFIG=%MAKER_BUILD_CONFIG%"

rem apply defaults
if "%_WVL_VERSION%" equ "" set _WVL_VERSION=
set "_WVL_BUILD_INFO=WFVIEW-LIBRARIES %_WVL_VERSION% %MAKER_BUILD_INFO%"

rem debug
if "%MAKER_MSG_VERBOSE%" neq "" set MAKER
if "%MAKER_MSG_VERBOSE%" neq "" set _WVL_
if "%MAKER_MSG_VERBOSE%" neq "" set _WFV_


echo.########################################################################################################################
echo # BUILDING %_WVL_BUILD_INFO%
echo.########################################################################################################################
echo.

rem *** clone WFVIEW-Libs sources ***
call "%MAKER_DIR_SCRIPTS%\clone_wfviewLibs.bat" %_WVL_VERSION% %MAKER_MSG_VERBOSE% --silent
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
set "_WVL_BUILD_DIR=%WFVIEW_LIBS_SRC_DIR%\._%_WVL_BUILD_CONFIG%"

cd /d "%_WVL_START_DIR%"
if "%MAKER_MSG_VERBOSE%" neq "" set _WVL_

rem *** cleaning old build if demanded ***
rem due potential switch from msvs libs to gnu .a files or vice versa, we have to always delete the bin folder to force reinstallation
rem remark: we use the same lib folder strucutre for both build systems (reference to inlude and lib folders in wfview CmakeLists.txt))
rem set _WVL_REBUILD=-r
if "%_WVL_REBUILD%" neq "" (
  echo.
  echo.************************************************************************************************************************
  echo.* preparing rebuild...
  echo * -^> removing "%_WVL_BIN_DIR%" ...
  rmdir /s /q "%_WVL_BIN_DIR%" 1>nul 2>nul
  echo * -^> removing "%_WVL_BUILD_DIR%" ...
  rmdir /s /q "%_WVL_BUILD_DIR%" 1>nul 2>nul
  echo.************************************************************************************************************************
)

rem ensure base folders exist
if not exist "%_WVL_BIN_DIR%" mkdir "%_WVL_BIN_DIR%"
if not exist "%_WVL_BUILD_DIR%" mkdir "%_WVL_BUILD_DIR%"


:_rebuild
rem *** ensuring prerequisites ***
set _WVL_CMAKE_VERSION=GEQ3.22
set _WVL_MSVS_VERSION=GEQ2019
set _WVL_MSVS_ARCH=amd64
set _WVL_NINJA_VERSION=GEQ1.10
echo.
echo.************************************************************************************************************************
echo * REBUILDING %_WVL_BUILD_INFO%
echo * -^> requires: VisualStudio 2019 or 2022 or MinGW
echo * -^> requires: Cmake 3.22 or newer
rem echo * -^> requires: QT %_WFV_QT_VERSION%
echo.************************************************************************************************************************

rem ensure BuildSystem availability
if /I "%_WVL_BUILD_SYSTEM%" neq "gnu" if /I "%_WVL_BUILD_SYSTEM%" neq "msvs" (
  echo error: BuildSystem %_WVL_BUILD_SYSTEM% is not available
  goto :_exit
)
if /I "%_WVL_BUILD_SYSTEM%" equ "gnu"  call "%MAKER_DIR_SCRIPTS%\ensure_mingw.bat" %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MinGW is not available
  goto :_exit
)
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" call "%MAKER_DIR_SCRIPTS%\ensure_msvs.bat" %_WVL_MSVS_VERSION% %_WVL_MSVS_ARCH% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MSVS %_WVL_MSVS_VERSION% %_WVL_MSVS_ARCH% is not available
  goto :_exit
)

rem validate cmake
call "%MAKER_DIR_SCRIPTS%\validate_cmake.bat" %_WVL_CMAKE_VERSION% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: CMAKE %_WVL_CMAKE_VERSION% is not available
  goto :_exit
)
rem ensure ninja
if /I "%_WVL_BUILD_SYSTEM%" equ "gnu" if %ERRORLEVEL% NEQ 0 goto :_exit
call "%MAKER_DIR_SCRIPTS%\validate_ninja.bat" %_WVL_NINJA_VERSION% --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA %_WVL_NINJA_VERSION% is not available
  goto :_exit
)
rem ensure fortran (ensure and validate not implemented yet) 
if /I "%_WVL_BUILD_SYSTEM%" neq "gnu" call "%MAKER_DIR_SCRIPTS%\build_fortran.bat" %MAKER_MSG_VERBOSE%
rem echo.


set "_WVL_CONFIG_GENERATOR=Ninja"
set "_WVL_CONFIG_OPTIONS="
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_WVL_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_WVL_CONFIG_OPTIONS=-A %_WVL_BUILD_ARCH%"

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
rem WFVIEW_ANR_DIR
rem WFVIEW_ANR_SRC_DIR
rem WFVIEW_LIBSNDFILE_DIR
rem WFVIEW_LIBSNDFILE_SRC_DIR
rem WFVIEW_R8BRAIN_DIR
rem WFVIEW_R8BRAIN_SRC_DIR
rem WFVIEW_LIBFT4222_DIR
rem WFVIEW_LIBFT4222_SRC_DIR
rem WFVIEW_LIBFT4222_SRC_DIR_WINDOWS
rem WFVIEW_LIBFT4222_SRC_DIR_LINUX

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
rem Use RTAUDIO_BUILD_SHARED_LIBS / RTAUDIO_BUILD_STATIC_LIBS if they are defined, otherwise default to standard BUILD_SHARED_LIBS.
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
:: Available targets (use: cmake --build . --target TARGET):
:: ------------+--------------------------------------------------------------
:: Target      |   Description
:: ------------+--------------------------------------------------------------
:: install     | Install Eigen. Headers will be installed to:
::             |     <CMAKE_INSTALL_PREFIX>/<INCLUDE_INSTALL_DIR>
::             |   Using the following values:
::             |     CMAKE_INSTALL_PREFIX: C:/GIT/Maker/projects/wfview/libs/eigen
::             |     INCLUDE_INSTALL_DIR:  include/eigen3
::             |   Change the install location of Eigen headers using:
::             |     cmake . -DCMAKE_INSTALL_PREFIX=yourprefix
::             |   Or:
::             |     cmake . -DINCLUDE_INSTALL_DIR=yourdir
:: uninstall   | Remove files installed by the install target
:: doc         | Generate the API documentation, requires Doxygen & LaTeX
:: install-doc | Install the API documentation
:: check       | Build and run the unit-tests. Read this page:
::             |   http://eigen.tuxfamily.org/index.php?title=Tests
:: blas        | Build BLAS library (not the same thing as Eigen)
:: lapack      | Build LAPACK subset library (not the same thing as Eigen):: 
:: ------------+--------------------------------------------------------------
rem cmake --build . --target install

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
rem see https://gitlab.com/hankst69/wfview-wasm/-/blob/0bf9f6016c5421801b325e7004cd2b53015f87e0/.github/workflows/macos-universal-qt6.bak -> Build QCustomPlot (Universal)
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

echo.
echo.************************************************************************************************************************
echo.* building libsndfile
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_LIBSNDFILE_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\libsndfile"
set "_cmake_bin=%WFVIEW_LIBSNDFILE_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" --log-level=VERBOSE -DOGG_FOUND=TRUE -DOPUS_FOUND=TRUE -DOPUS_LIBRARY="%WFVIEW_OPUS_DIR%" -DOPUS_INCLUDE_DIR="%WFVIEW_OPUS_DIR%\include"
call cmake --build "." --config %_WVL_BUILD_TYPE%
call cmake --install "." --config %_WVL_BUILD_TYPE%

echo.
echo.************************************************************************************************************************
echo.* building anr
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_ANR_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\anr"
set "_cmake_bin=%WFVIEW_ANR_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DLIBSNDFILE_DIR="%WFVIEW_LIBSNDFILE_DIR%" -DCMAKE_INSTALL_INCLUDEDIR="include" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE%
call cmake --install "." --config %_WVL_BUILD_TYPE%

echo.
echo.************************************************************************************************************************
echo.* building adpcm
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_ADPCM_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\adpcm"
set "_cmake_bin=%WFVIEW_ADPCM_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DLIBSNDFILE_DIR="%WFVIEW_LIBSNDFILE_DIR%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE%
call cmake --install "." --config %_WVL_BUILD_TYPE%

if /i "%_WVL_BUILD_SYSTEM%" neq "msvs" goto :skip_pthreads_windows
echo.
echo.************************************************************************************************************************
echo.* building pthreads (windows)
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_PTHREADS_SRC_DIR%"
set "_cmake_bld=%_WVL_BUILD_DIR%\pthreads"
set "_cmake_bin=%WFVIEW_PTHREADS_DIR%"
if not exist "%_cmake_bld%" mkdir "%_cmake_bld%"
cd /d "%_cmake_bld%"
call cmake -S "%_cmake_src%" -B "%_cmake_bld%" --install-prefix "%_cmake_bin%" -G "%_WVL_CONFIG_GENERATOR%" %_WVL_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WVL_BUILD_TYPE%" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DLIBSNDFILE_DIR="%WFVIEW_LIBSNDFILE_DIR%" --log-level=VERBOSE
call cmake --build "." --config %_WVL_BUILD_TYPE% 
call cmake --install "." --config %_WVL_BUILD_TYPE% 
rem nmake build
cd /d "%_cmake_src%"
call nmake all install
if exist "%_cmake_bin%" rmdir /s /q "%_cmake_bin%" 
mkdir "%_cmake_bin%"
call xcopy "%_cmake_src%\..\PTHREADS-BUILT" "%_cmake_bin%" /s
rmdir /s /q "%_cmake_src%\..\PTHREADS-BUILT"
:skip_pthreads_windows

rem echo.
rem echo.************************************************************************************************************************
rem echo.* building r8brain-free-src
rem echo.************************************************************************************************************************

echo.
echo.************************************************************************************************************************
echo.* building libft4222
echo.************************************************************************************************************************
set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR%\%WFVIEW_LIBFT4222_VERSION%.zip"
if /i "%_WVL_BUILD_SYSTEM%" equ "msvs" set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR_WINDOWS%"
if /i "%_WVL_BUILD_SYSTEM%" equ "gnu"  set "_cmake_src=%WFVIEW_LIBFT4222_SRC_DIR_LINUX%"
set "_cmake_bin=%WFVIEW_LIBFT4222_DIR%"
call "%MAKER_ENV_CORE%\extract_in_folder.bat" "%_cmake_bin%" "%_cmake_src%" %MAKER_MSG_SILENT%
if /I "%_WVL_BUILD_ARCH%" equ "x64" for /f %%i in ('dir /s /b "%WFVIEW_LIBFT4222_DIR%\*arm64*"') do if exist "%%~i\*" rmdir /s /q "%%~i"


:_exit
cd /d "%_WVL_BIN_DIR%"
rem cd /d "%_WVL_START_DIR%"
