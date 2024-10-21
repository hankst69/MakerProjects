@echo off
endlocal
pushd
rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
rem https://pypi.org/project/aqtinstall/#:~:text=Same%20as%20usual%2C%20it%20can%20be%20installed%20with,some%20of%20which%20are%20precompiled%20in%20several%20platforms.
set "_MAKER_ROOT=%~dp0"
set "_QT_DIR=%~dp0Qt"
set "_QT_ENV_DIR=%_QT_DIR%\.qt_env"
set "_QT_INSTALL_MAKE=%_QT_DIR%\.qt_make"
set "_TOOLS_DIR=%_MAKER_ROOT%.tools"
set "_TOOLS_QTCREATOR_DIR=%_TOOLS_DIR%\.qtcreator"

set _QT_VERSION=6.6.3
if "%~1" neq "" set "_QT_VERSION=%~1"


rem --test if qt-creater is already available
if not exist "%_TOOLS_QTCREATOR_DIR%\bin\qtcreator.exe" (
  if exist "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
    if not exist "%_TOOLS_QTCREATOR_DIR%" mkdir "%_TOOLS_QTCREATOR_DIR%"
    call xcopy /S /Y /Q "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator" "%_TOOLS_QTCREATOR_DIR%" 1>NUL
  )
)
if not exist "%_TOOLS_QTCREATOR_DIR%\bin\qtcreator.exe" (
  del /Y "%_TOOLS_DIR%\qtcreator.bat"
) else (
  echo @pushd "%_TOOLS_QTCREATOR_DIR%\bin">"%_TOOLS_DIR%\qtcreator.bat"
  echo @call qtcreator.exe %%* >>"%_TOOLS_DIR%\qtcreator.bat"
  echo @popd>>"%_TOOLS_DIR%\qtcreator.bat"
)
rem type "%_TOOLS_DIR%\qtcreator.bat"
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem echo QtCreator already available
  goto :test_qtcreator_success
)
rem if exist "%_TOOLS_DIR%\qtcreator.bat" path
if exist "%_TOOLS_DIR%\qtcreator.bat" set "Path=%Path%;%_TOOLS_DIR%;%_TOOLS_QTCREATOR_DIR%\bin"
rem if exist "%_TOOLS_DIR%\qtcreator.bat" path
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem echo QtCreator already available
  goto :test_qtcreator_success
)

echo.
echo rebuilding Qt-Creator from sources
echo.
echo *** THIS REQUIRES VisualStudio 2019 ^(currently^) ***
echo *** THIS REQUIRES running in an ELEVATED SHELL ^(currently^) ***
if "%VSCMD_VER:~0,2%" neq "16" (echo error: wrong VisualStudio version &goto :EOF)
echo.

rem -- ensure python is available
rem call "%_MAKER_ROOT%\setup_python.bat"
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: python not available
  goto :exit_script
)
:test_python_success
set _VERSION_NR=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "_VERSION_NR=%%j"
echo using: python %_VERSION_NR%
set _VERSION_NR=


rem -- ensure make is available
call "%_MAKER_ROOT%\build_make.bat"
call which make 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo error: MAKE is not available
  goto :exit_script
)
:test_make_success


rem -- ensure qt_install makefiles are available
if not exist "%_QT_INSTALL_MAKE%\MakeFile" (
  call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_QT_INSTALL_MAKE%" "http://github.com/vedderb/bldc" --silent
)
if not exist "%_QT_INSTALL_MAKE%\MakeFile" (
  echo error: QT Make files not available
  goto :exit_script
)
:test_qtmake_success


rem -- ensure aqtinstall is available (in QT-python env)
call deactivate 1>nul 2>nul
if not exist "%_QT_ENV_DIR%\.venv.created" (
  echo creating Qt environment ... ^(%_QT_ENV_DIR%^)
  if not exist "%_QT_ENV_DIR%" mkdir "%_QT_ENV_DIR%"
  call python -m venv "%_QT_ENV_DIR%" || exit /b
  call "%_QT_ENV_DIR%\Scripts\activate.bat"
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
  echo done >"%_QT_ENV_DIR%\.venv.created"
  call deactivate
)
if not exist "%_QT_ENV_DIR%\.venv.created" (
  echo error: QT-Installer 'aqtinstall' not available
  goto :exit_script
)
:test_qtinstall_success
 

rem install Qt-tools (make) and create shortcuts
echo.
call "%_QT_ENV_DIR%\Scripts\activate.bat"
echo installing Qt-Creator ...
pushd "%_QT_INSTALL_MAKE%"
call make qt_install || exit /b
popd
call "%_QT_ENV_DIR%\Scripts\deactivate.bat"
if not exist "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
  echo. error: building QtCreator failed
  goto :exit_script
)


rem -- create shortcuts
if not exist "%_TOOLS_QTCREATOR_DIR%\bin\qtcreator.exe" (
  if not exist "%_TOOLS_QTCREATOR_DIR%" mkdir "%_TOOLS_QTCREATOR_DIR%"
  call xcopy /S /Y /Q "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator" "%_TOOLS_QTCREATOR_DIR%" 1>NUL
)
echo @pushd "%_TOOLS_QTCREATOR_DIR%\bin">"%_TOOLS_DIR%\qtcreator.bat"
echo @call qtcreator.exe %%* >>"%_TOOLS_DIR%\qtcreator.bat"
echo @popd>>"%_TOOLS_DIR%\qtcreator.bat"

call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%_TOOLS_DIR%;%_TOOLS_QTCREATOR_DIR%\bin"
call which qtcreator.bat 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_qtcreator_success
  
rem start qtcreator:
rem call "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe"
rem call "%_TOOLS_QTCREATOR_DIR%\bin\qtcreator.exe"
rem call "%_TOOLS_QTCREATOR_DIR%\qtcreator.bat"
rem call qtcreator

:test_qtcreator_failed
echo. error: Qt-Creator not available
goto :exit_script

:test_qtcreator_success
rem call which qtcreator -l -d
echo qtcreator (to start Qt-Creator)


:exit_script
popd
