@echo off
set "_MAKER_ROOT=%~dp0"
rem https://vesc-project.com/vesc_tool
rem https://vesc-project.com/node/309
rem https://github.com/vedderb/vesc_tool
rem http://github.com/vedderb/bldc


rem 1) clone VESC tool and fw 
echo.
echo 1) clone VESC FW and VESC Tool
rem defines: _VESC_DIR
rem defines: _VESC_TOOL_DIR
rem defines: _VESC_FW_DIR
call "%_MAKER_ROOT%\clone_vesc.bat"
if "%_VESC_DIR%" EQU "" (echo cloning VESC failed &goto :EOF)
if "%_VESC_TOOL_DIR%" EQU "" (echo cloning VESC-Tool failed &goto :EOF)
if "%_VESC_FW_DIR%" EQU "" (echo cloning VESC-FW failed &goto :EOF)
if not exist "%_VESC_DIR%" (echo cloning VESC failed &goto :EOF)
if not exist "%_VESC_TOOL_DIR%" (echo cloning VESC-Tool failed &goto :EOF)
if not exist "%_VESC_FW_DIR%" (echo cloning VESC-FW failed &goto :EOF)

rem 2) install Qt
echo.
echo 2) install Qt
pushd %_MAKER_ROOT%
call "%_MAKER_ROOT%\build_qt.bat" 6.6.3
echo.
popd
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT is not installed
  goto :EOF
)


rem echo test make
call which make 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_make_success
call which nmake 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :test_make_failed
doskey make=nmake
call which make 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_make_success
:test_make_failed
echo error: MAKE is not available
goto :EOF
:test_make_success
echo  make available


rem 3) configure VESC-Tool  build
echo.
echo 3) configure VESC-Tool build
echo ...tbd

rem 4) build VESC-Tool
echo.
echo 4) build VESC-Tool
echo ...tbd

rem 5) install VESC-Tool
echo.
echo 5) install VESC-Tool
echo ...tbd
