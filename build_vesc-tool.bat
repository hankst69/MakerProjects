@echo off
rem https://vesc-project.com/vesc_tool
rem https://vesc-project.com/node/309
rem https://github.com/vedderb/vesc_tool
rem http://github.com/vedderb/bldc
set "_MAKER_ROOT=%~dp0"

echo.
echo 1) ensure Make is available
call "%_MAKER_ROOT%\build_make.bat"
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: MAKE is not available
  goto :EOF
)

echo.
echo 2) ensure Qt-Creator is available
call "%_MAKER_ROOT%\build_qt-creator.bat"
call which qtcreator 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: QtCreator is not available
  goto :EOF
)

echo.
echo 3) clone VESC-FW and VESC Tool
call "%_MAKER_ROOT%\clone_vesc.bat"
rem defines: _VESC_DIR
rem defines: _VESC_TOOL_DIR
rem defines: _VESC_FW_DIR
if "%_VESC_DIR%" EQU "" (echo error: cloning VESC failed &goto :EOF)
if "%_VESC_TOOL_DIR%" EQU "" (echo error: cloning VESC-Tool failed &goto :EOF)
if "%_VESC_FW_DIR%" EQU "" (echo error: cloning VESC-FW failed &goto :EOF)
if not exist "%_VESC_DIR%" (echo error: cloning VESC failed &goto :EOF)
if not exist "%_VESC_TOOL_DIR%" (echo error: cloning VESC-Tool failed &goto :EOF)
if not exist "%_VESC_FW_DIR%" (echo error: cloning VESC-FW failed &goto :EOF)


rem based on output of: call make | grep "supported boards"
set _VESC_BOARD=100_250

echo.
echo.
echo 4) build VESC-FW SDK
pushd "%_VESC_FW_DIR%"
call make arm_sdk_install
popd

echo.
echo.
echo 5) build VESC-Board FW
pushd "%_VESC_FW_DIR%"
call make | grep "supported boards"
rem
call make %_VESC_BOARD%
rem call make all_fw
popd
dir "%_VESC_FW_DIR%\builds\%_VESC_BOARD%"
popd

echo.
echo.
echo 6) build VESC-Tool
echo ...use Qt-Creator
call qtcreator