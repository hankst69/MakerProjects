@echo off
rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
rem https://pypi.org/project/aqtinstall/#:~:text=Same%20as%20usual%2C%20it%20can%20be%20installed%20with,some%20of%20which%20are%20precompiled%20in%20several%20platforms.
set "_MAKER_ROOT=%~dp0"
set "_QT_DIR=%_MAKER_ROOT%Qt"
set "_QT_CREATOR_ENV_DIR=%_QT_DIR%\.qt_creator"

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"

if not exist "%_QT_DIR%" mkdir "%_QT_DIR%"

rem ensure python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python not available
goto :EOF
:test_python_success
set _VERSION_NR=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "_VERSION_NR=%%j"
echo using: python %_VERSION_NR%
set _VERSION_NR=

rem ensure make
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 call "%_MAKER_ROOT%\build_make.bat"
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: MAKE is not available
  goto :EOF
)

rem -- install qt-creator in a dedicated python environment
call deactivate 1>nul 2>nul
if not exist "%_QT_CREATOR_ENV_DIR%\.venv.created" (
  echo creating Qt-Creator environment ... ^(%_QT_CREATOR_ENV_DIR%^)
  if not exist "%_QT_CREATOR_ENV_DIR%" mkdir "%_QT_CREATOR_ENV_DIR%"
  call python -m venv "%_QT_CREATOR_ENV_DIR%" || exit /b
  call "%_QT_CREATOR_ENV_DIR%\Scripts\activate.bat"
  rem
  echo.
  echo installing Qt-Installer 'aqtinstall' ...
  call python -m pip install --upgrade pip  || exit /b
  call python -m pip install aqtinstall  || exit /b
  rem
  rem call python -m aqt list-qt windows desktop --arch %_QT_VERSION%
  echo.
  echo aqt list-qt windows desktop --arch %_QT_VERSION%
  call aqt list-qt windows desktop --arch %_QT_VERSION%
  echo.
  echo aqt list-qt windows desktop --modules %_QT_VERSION% wasm_multithread
  call aqt list-qt windows desktop --modules %_QT_VERSION% wasm_multithread
  rem call aqt list-qt windows desktop --modules %_QT_VERSION% wasm_singlethread
  echo.
  echo aqt list-qt windows desktop --modules %_QT_VERSION% win64_mingw
  call aqt list-qt windows desktop --modules %_QT_VERSION% win64_mingw
  rem echo.
  rem call aqt install-qt windows desktop %_QT_VERSION% win64_mingw -m all
  echo.
  echo installing Qt-Creator ...
  pushd 
  call make qt_install || exit /b
  rem python -m pip install setuptools^>=36.0.0,^<58.0.0 wheel --no-cache-dir ||call deactivate& exit /b
  echo done >"%_QT_CREATOR_ENV_DIR%\.venv.created"
)
echo Qt-Creator ready ... ^(%_QT_CREATOR_ENV_DIR%^)
goto :EOF

echo @"%_QT_CREATOR_ENV_DIR%\tools\Qt\Tools\QtCreator\bin\qtcreator"
echo @"%_QT_CREATOR_ENV_DIR%\tools\Qt\Tools\QtCreator\bin\qtcreator">"%_QT_DIR%\qtcreator.bat"



