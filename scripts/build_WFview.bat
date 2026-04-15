@echo off
if /I "%~1" equ "-?" goto :_usage
if /I "%~1" equ "-h" goto :_usage
if /I "%~1" equ "--help" goto :_usage
goto :_start

:_usage
echo USAGE:
echo %~n0 [version] [--gnu^|--msvs] [--release^|--debug] [--open^|-o] [-?^|-h^|--help]
goto :EOF

:_start
call "%~dp0\maker_env.bat" %* --silent

call "%MAKER_ENV_CORE%\clear_temp_envs.bat" "_WFV_" 1>nul 2>nul
set "_WFV_THIS_DIR=%~dp0"
set "_WFV_START_DIR=%cd%"

set "_WFV_VERSION=%MAKER_VERSION%"
set "_WFV_REBUILD=%MAKER_REBUILD%"
set "_WFV_BUILD_ARCH=%MAKER_BUILD_ARCH%"
set "_WFV_BUILD_TYPE=%MAKER_BUILD_TYPE%"
set "_WFV_BUILD_MODE=%MAKER_BUILD_MODE%"
set "_WFV_BUILD_SYSTEM=%MAKER_BUILD_SYSTEM%"
set "_WFV_BUILD_CONFIG=%MAKER_BUILD_CONFIG%"

set _WFV_OPEN_PROJECT=
for /f %%i in ("%MAKER_UNKNOWN_SWITCHES%") do if /I "%%~i" equ "--open" set _WFV_OPEN_PROJECT=--open
for /f %%i in ("%MAKER_UNKNOWN_SWITCHES%") do if /I "%%~i" equ "-o" set _WFV_OPEN_PROJECT=--open
set _WVL_REBUILD=
for /f %%i in ("%MAKER_UNKNOWN_SWITCHES%") do if /I "%%~i" equ "-rebuild+" set _WVL_REBUILD=--rebuild
for /f %%i in ("%MAKER_UNKNOWN_SWITCHES%") do if /I "%%~i" equ "-r+" set _WVL_REBUILD=--rebuild
if "%_WVL_REBUILD%" neq "" set "_WFV_REBUILD=%_WVL_REBUILD%"

rem apply defaults
if "%_WFV_VERSION%" equ "" set _WFV_VERSION=
set "_WFV_BUILD_INFO=WFVIEW %_WFV_VERSION% %MAKER_BUILD_INFO%"

rem debug
rem if "%MAKER_MSG_VERBOSE%" neq "" set MAKER_ENV
rem if "%MAKER_MSG_VERBOSE%" neq "" set _WFV_


rem welcome
echo BUILD WFVIEW %_WFV_BUILD_INFO%

rem *** clone WFVIEW sources ***
call "%MAKER_DIR_SCRIPTS%\clone_wfview.bat" %_WFV_VERSION% %MAKER_MSG_VERBOSE% --silent
rem defines: WFVIEW_VERSION
rem defines: WFVIEW_DIR
rem defines: WFVIEW_BASE_DIR
rem defines: WFVIEW_SRC_DIR
if "%WFVIEW_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if "%WFVIEW_SRC_DIR%" EQU "" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_DIR%" (echo cloning WFVIEW failed &goto :EOF)
if not exist "%WFVIEW_SRC_DIR%" (echo cloning WFVIEW failed &goto :EOF)

set "_WFV_DIR=%WFVIEW_DIR%"
set "_WFV_SOURCES_DIR=%WFVIEW_SRC_DIR%"
set "_WFV_BIN_DIR=%WFVIEW_DIR%\%WFVIEW_BASE_DIR%%WFVIEW_VERSION%"
set "_WFV_BUILD_DIR=%_WFV_SOURCES_DIR%\._%_WFV_BUILD_CONFIG%"


cd /d "%_WFV_START_DIR%"
if "%MAKER_MSG_VERBOSE%" neq "" set _WFV_

rem *** cleaning old build if demanded ***
if "%_WFV_REBUILD%" neq "" (
  echo preparing rebuild...
  rmdir /s /q "%_WFV_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_WFV_BUILD_DIR%" 1>nul 2>nul
)
if not exist "%_WFV_BIN_DIR%" mkdir "%_WFV_BIN_DIR%"
if not exist "%_WFV_BUILD_DIR%" mkdir "%_WFV_BUILD_DIR%"


set "_WFV_EXECUTABLE=%_WFV_BIN_DIR%\bin\wfview.exe"
if not exist "%_WFV_EXECUTABLE%" goto :_rebuild
goto :_build


:_rebuild
rem *** ensuring prerequisites ***
echo.
echo.************************************************************************************************************************
echo * REBUILDING WFVIEW %_WFV_BUILD_INFO%
echo.************************************************************************************************************************
echo *** THIS REQUIRES QT %_WFV_QT_VERSION%
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or MinGW
echo *** THIS REQUIRES Cmake 3.22 or newer
echo.
set _WFV_CMAKE_VERSION=GEQ3.22
set _WFV_MSVS_VERSION=GEQ2019
set _WFV_MSVS_ARCH=amd64
set _WFV_NINJA_VERSION=GEQ1.10
set _WFV_QT_VERSION=6.8.3

rem ensure BuildSystem availability
if /I "%_WFV_BUILD_SYSTEM%" neq "gnu" if /I "%_WFV_BUILD_SYSTEM%" neq "msvs" (
  echo error: BuildSystem %_WFV_BUILD_SYSTEM% is not available
  goto :_exit
)
if /I "%_WFV_BUILD_SYSTEM%" equ "gnu"  call "%MAKER_DIR_SCRIPTS%\ensure_mingw.bat" %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MinGW is not available
  goto :_exit
)
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" call "%MAKER_DIR_SCRIPTS%\ensure_msvs.bat" %_WFV_MSVS_VERSION% %_WFV_MSVS_ARCH% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: MSVS %_WFV_MSVS_VERSION% %_WFV_MSVS_ARCH% is not available
  goto :_exit
)
rem ensure ninja
if /I "%_WFV_BUILD_SYSTEM%" equ "gnu" call "%MAKER_DIR_SCRIPTS%\validate_ninja.bat" %_WFV_NINJA_VERSION% --no_errors %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: NINJA %_WFV_NINJA_VERSION% is not available
  goto :_exit
)
rem ensure qt
call "%MAKER_DIR_SCRIPTS%\ensure_qt.bat" %_WFV_QT_VERSION% %_WFV_BUILD_SYSTEM% %_WFV_BUILD_TYPE% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: QT %_WFV_QT_VERSION% %_WFV_BUILD_SYSTEM% %_WFV_BUILD_TYPE% is not available
  goto :_exit
)
rem validate qt-cmake
call "%MAKER_DIR_SCRIPTS%\validate_qt-cmake.bat" %_WFV_CMAKE_VERSION% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: QT-CMAKE %_WFV_CMAKE_VERSION% is not available
  goto :_exit
)
rem validate cmake
call "%MAKER_DIR_SCRIPTS%\validate_cmake.bat" %_WFV_CMAKE_VERSION% %MAKER_MSG_VERBOSE%
if %ERRORLEVEL% NEQ 0 (
  echo error: CMAKE %_WFV_CMAKE_VERSION% is not available
  goto :_exit
)

rem *** build required libraries ***
echo.
call "%MAKER_DIR_SCRIPTS%\build_wfviewlibs.bat" %_WVL_REBUILD% %_WFV_VERSION% %_WFV_BUILD_SYSTEM% %_WFV_BUILD_TYPE% %_WFV_BUILD_MODE% %_WFV_BUILD_ARCH% %MAKER_MSG_VERBOSE% %MAKER_MSG_SILENT%
if %ERRORLEVEL% NEQ 0 (
  echo error: BUILDING of WFVIEW-LIBRARIES failed
  goto :_exit
)
if "%WFVIEW_LIBS_DIR%" equ ""        (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if not exist "%WFVIEW_LIBS_DIR%"     (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if "%WFVIEW_LIBS_SRC_DIR%" equ ""    (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)
if not exist "%WFVIEW_LIBS_SRC_DIR%" (echo error: BUILDING of WFVIEW-LIBRARIES failed &goto :_exit)


:_qmake2cmake
rem *** generate CmakeLists.txt ***
if not exist "%_WFV_SOURCES_DIR%\CmakeLists.txt" (
  call "%MAKER_DIR_SCRIPTS%\build_qmake2cmake.bat"
  if %ERRORLEVEL% NEQ 0 goto :_exit
  cd "%_WFV_SOURCES_DIR%"
  call qmake2cmake wfview.pro -o CmakeLists.txt --min-qt-version %_WFV_QT_VERSION%
)


:_configure
rem *** cmake configure ***
echo.
echo.************************************************************************************************************************
echo * CONFIGURE WFVIEW %_WFV_BUILD_INFO%
echo.************************************************************************************************************************
cd /d "%_WFV_BUILD_DIR%"
set "_WFV_CONFIG_GENERATOR=Ninja"
set "_WFV_CONFIG_OPTIONS="
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" set "_WFV_CONFIG_GENERATOR=Visual Studio %MSVS_VERSION_MAJOR% %MSVS_YEAR%"
if /I "%_WFV_BUILD_SYSTEM%" equ "msvs" set "_WFV_CONFIG_OPTIONS=-A %_WFV_BUILD_ARCH%"
echo qt-cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_WFV_BIN_DIR%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%"
call "%QT_CMAKE%" -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_WFV_BIN_DIR%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" --log-level=VERBOSE
rem echo cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_WFV_BIN_DIR%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"
rem call cmake -S "%_WFV_SOURCES_DIR%" -B "%_WFV_BUILD_DIR%" --install-prefix "%_WFV_BIN_DIR%" -G "%_WFV_CONFIG_GENERATOR%" %_WFV_CONFIG_OPTIONS% -DCMAKE_BUILD_TYPE="%_WFV_BUILD_TYPE%" -DCMAKE_PREFIX_PATH="%QT_BIN_DIR%"


:_open
rem *** open generated project ***
cd /d "%_WFV_BUILD_DIR%"
if "%_WFV_OPEN_PROJECT%" neq "" echo cmake --open .
if "%_WFV_OPEN_PROJECT%" neq "" call cmake --open .


:_build
rem *** cmake build ***
echo.
echo.************************************************************************************************************************
echo * BUILD WFVIEW %_WFV_BUILD_INFO%
echo.************************************************************************************************************************
cd /d "%_WFV_BUILD_DIR%"
echo cmake --build . --config %_WFV_BUILD_TYPE%
call cmake --build . --config %_WFV_BUILD_TYPE% --parallel %MAKER_NUM_PARALLEL%


:_install
rem *** cmake install ***
echo.
echo.************************************************************************************************************************
echo * INSTALL WFVIEW %_WFV_BUILD_INFO%
echo.************************************************************************************************************************
cd /d "%_WFV_BUILD_DIR%"
echo cmake --install . --config %_WFV_BUILD_TYPE%
cmake --install . --config %_WFV_BUILD_TYPE%
rem workaround: copy also library dependencies into bin (todo: fix CmakeLists.txt)
cd /d "%WFVIEW_LIBS_DIR%"
for /f %%i in ('dir /s /b *.dll') do copy "%%~i" "%_WFV_BIN_DIR%\bin"
rem workaround: copy also wfview config files (todo: fix CmakeLists.txt)
cd /d "%_WFV_SOURCES_DIR%"
if not exist "%_WFV_BIN_DIR%\bin\rigs\*" mkdir /s /q "%_WFV_BIN_DIR%\bin\rigs"
call xcopy /S /Y /Q "%_WFV_SOURCES_DIR%\rigs" "%_WFV_BIN_DIR%\bin\rigs\"


:_exit
cd /d "%_WFV_START_DIR%"
if not exist "%_WFV_EXECUTABLE%" goto :EOF
echo.
echo BUILD WFVIEW %_WFV_BUILD_INFO% COMPLETE
echo.
echo to start wfview:
echo "%_WFV_EXECUTABLE%"
start /D "%_WFV_BIN_DIR%\bin" wfview.exe
