@echo off
rem https://vesc-project.com/vesc_tool
rem https://vesc-project.com/node/309
rem https://github.com/vedderb/vesc_tool
rem http://github.com/vedderb/bldc

set "_MAKER_ROOT=%~dp0"
set "_QT_DIR=%~dp0Qt"
set "_QT_ENV_DIR=%_QT_DIR%\.qt_env"

if not exist "%_QT_DIR%" mkdir "%_QT_DIR%"

set "_TOOLS_DIR=%_MAKER_ROOT%\.tools"
set "_TOOLS_QTCREATOR_DIR=%_TOOLS_DIR%\.qtcreator"


echo.
echo 1) clone VESC FW and VESC Tool
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


rem pushd "%_VESC_FW_DIR%"
rem call make | grep "supported boards"
rem popd
set _VESC_BOARD=100_250


echo.
echo 1) install Make
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 call "%_MAKER_ROOT%\build_make.bat"
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: MAKE is not available
  goto :EOF
)

echo.
echo.
echo 2) build VESC-FW SDK
pushd "%_VESC_FW_DIR%"
call make arm_sdk_install
popd

echo.
echo.
echo 3) build VESC-Board FW
pushd "%_VESC_FW_DIR%"
call make | grep "supported boards"
rem
call make %_VESC_BOARD%
popd
dir "%_VESC_FW_DIR%\builds\%_VESC_BOARD%"
popd

echo.
echo.
echo 4) install Qt
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  echo QtCreator already available
  goto :test_qtcreator_success
)
if exist "%_TOOLS_DIR%\qtcreator.bat" set "Path=%Path%;%_TOOLS_DIR%;%_TOOLS_QTCREATOR_DIR%\bin"
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  echo QtCreator already available
  goto :test_qtcreator_success
)
rem pushd %_MAKER_ROOT%
rem call "%_MAKER_ROOT%\build_qt.bat" 6.6.3
rem echo.
rem popd
rem if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
rem   echo QT is not installed
rem   goto :EOF
rem )

rem echo test python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python not available
goto :EOF
:test_python_success
set _VERSION_NR=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "_VERSION_NR=%%j"
echo using: python %_VERSION_NR%
set _VERSION_NR=

rem -- install qt-creator via a aqt tool from a dedicated python environment
call deactivate 1>nul 2>nul
if not exist "%_VESC_FW_DIR%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
  echo creating Qt environment ... ^(%_QT_ENV_DIR%^)
  if not exist "%_QT_ENV_DIR%" mkdir "%_QT_ENV_DIR%"
  call python -m venv "%_QT_ENV_DIR%" || exit /b
  call "%_QT_ENV_DIR%\Scripts\activate.bat"
  rem
  echo installing AQT ...
  call python -m pip install --upgrade pip  || exit /b
  call python -m pip install aqtinstall  || exit /b
  rem
  echo.
  pushd "%_VESC_FW_DIR%"
  call make qt_install || exit /b
  popd
  echo done >"%_QT_ENV_DIR%\.venv.created"
  call deacrtivate
)
echo Qt ready ... ^(%_QT_ENV_DIR%^)

if not exist "%_VESC_FW_DIR%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
  echo. error: building QtCreator failed
  goto :EOF
)
if not exist "%_TOOLS_QTCREATOR_DIR%" mkdir "%_TOOLS_QTCREATOR_DIR%"
call xcopy /S /Y /Q "%_VESC_FW_DIR%\tools\Qt\Tools\QtCreator" "%_TOOLS_QTCREATOR_DIR%" 1>NUL

echo @pushd "%_TOOLS_QTCREATOR_DIR%\bin">"%_TOOLS_DIR%\qtcreator.bat"
echo @call qtcreator.exe %%* >>"%_TOOLS_DIR%\qtcreator.bat"
echo @popd>>"%_TOOLS_DIR%\qtcreator.bat"

call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%_TOOLS_DIR%;%_TOOLS_QTCREATOR_DIR%\bin"
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_qtcreator_success
  
call "%_VESC_FW_DIR%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe"
:test_qtcreator_failed
echo. error: QtCreator not available
goto :EOF

:test_qtcreator_success
echo.
call which qtcreator -l -d
call qtcreator
goto :EOF



echo.
echo.
echo 6) install VESC-Tool
echo ...tbd
