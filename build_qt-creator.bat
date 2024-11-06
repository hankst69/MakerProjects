@rem https://github.com/vedderb/bldc?tab=readme-ov-file#on-all-platforms
@rem https://pypi.org/project/aqtinstall/#:~:text=Same%20as%20usual%2C%20it%20can%20be%20installed%20with,some%20of%20which%20are%20precompiled%20in%20several%20platforms.
@echo off
call "%~dp0\maker_env.bat"
set "_BQTC_START_DIR=%cd%"
set "_BQTC_ARG1=%~1"

set _QT_VERSION=6.6.3
set _REBUILD=
:param_loop
if /I "%~1" equ "--start"   (shift &goto :param_loop)
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (set "_QT_VERSION=%~1" &shift &goto :param_loop)

set "_QT_DIR=%~dp0tools\Qt"
set "_QT_ENV_DIR=%_QT_DIR%\.qt_env"
set "_QT_INSTALL_MAKE=%_QT_DIR%\.qt_make"
set "_QTCREATOR_BIN=%MAKER_BIN%\.qtcreator"

if "%_REBUILD%" neq "" (
  rmdir /s /q "%_QT_INSTALL_MAKE%" 1>nul 2>nul
  rem rmdir /s /q "%_QT_ENV_DIR%"  1>nul 2>nul
  rmdir /s /q "%_QTCREATOR_BIN%" 1>nul 2>nul
  del /F /Q "%MAKER_BIN%\qtcreator.bat" 2>NUL
)

rem --test if qt-creater is already available
if not exist "%_QTCREATOR_BIN%\bin\qtcreator.exe" (
  if exist "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
    if not exist "%_QTCREATOR_BIN%" mkdir "%_QTCREATOR_BIN%"
    call xcopy /S /Y /Q "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator" "%_QTCREATOR_BIN%" 1>NUL
  )
)
del /F /Q "%MAKER_BIN%\qtcreator.bat" 2>NUL
if exist "%_QTCREATOR_BIN%\bin\qtcreator.exe" (
  echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_BIN%\qtcreator.bat"
  echo @start /D "%_QTCREATOR_BIN%\bin" /B qtcreator.exe %%*>>"%MAKER_BIN%\qtcreator.bat"
)
rem type "%MAKER_BIN%\qtcreator.bat"
call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem echo QtCreator already available
  goto :test_qtcreator_success
)
rem if exist "%MAKER_BIN%\qtcreator.bat" set "Path=%Path%;%MAKER_BIN%;%_QTCREATOR_BIN%\bin"
if exist "%MAKER_BIN%\qtcreator.bat" set "Path=%Path%;%MAKER_BIN%"
call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 (
  rem echo QtCreator already available
  goto :test_qtcreator_success
)

echo.
echo rebuilding Qt-Creator from sources
echo.
echo *** THIS REQUIRES VisualStudio 2019 ^(currently^) ***
echo *** THIS REQUIRES running in an ELEVATED SHELL ^(currently^) ***
echo *** THIS REQUIRES Python 3
echo.

rem --- validate python
call "%MAKER_SCRIPTS%\validate_python.bat" 3
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)
rem --- ensure proper MSVS 2019 is available where target architecture matches python architecture
call "%MAKER_SCRIPTS%\ensure_msvs.bat" 2019 %PYTHON_ARCHITECTURE%
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)
rem -- ensure make is available
call "%MAKER_SCRIPTS%\validate_make.bat" GEQ3 1>nul
if %ERRORLEVEL% NEQ 0 call "%MAKER_ROOT%\build_make.bat"
call "%MAKER_SCRIPTS%\validate_make.bat"
if %ERRORLEVEL% NEQ 0 (
  goto :exit_script
)

rem -- ensure qt_install makefiles are available
if not exist "%_QT_INSTALL_MAKE%\MakeFile" (
  call "%MAKER_ROOT%\scripts\clone_in_folder.bat" "%_QT_INSTALL_MAKE%" "http://github.com/vedderb/bldc" --silent
)
if not exist "%_QT_INSTALL_MAKE%\MakeFile" (
  echo error: QT Make files not available
  goto :exit_script
)
:test_qtmake_success


rem -- ensure arm_sdk available
pushd "%_QT_INSTALL_MAKE%"
call make arm_sdk_install
popd


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
 

rem -- install Qt-tools (make) and create shortcuts
echo.
call "%_QT_ENV_DIR%\Scripts\activate.bat"
echo installing Qt-Creator ...
cd "%_QT_INSTALL_MAKE%"
call make qt_install
if %ERRORLEVEL% NEQ 0 (
  echo. error: build QtCreator failed ^(make qt_install failed^)
  goto :exit_script
)
call "%_QT_ENV_DIR%\Scripts\deactivate.bat"
if not exist "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator\bin\qtcreator.exe" (
  echo. error: build QtCreator failed ^(make qtcreator.exe does not exist^)
  goto :exit_script
)


rem -- create shortcuts
if not exist "%_QTCREATOR_BIN%\bin\qtcreator.exe" (
  if not exist "%_QTCREATOR_BIN%" mkdir "%_QTCREATOR_BIN%"
  call xcopy /S /Y /Q "%_QT_INSTALL_MAKE%\tools\Qt\Tools\QtCreator" "%_QTCREATOR_BIN%" 1>NUL
)
echo @if /I "%%~1" equ "--validate" ^(exit /b 0^)>"%MAKER_BIN%\qtcreator.bat"
echo @start /D "%_QTCREATOR_BIN%\bin" /B qtcreator.exe %%*>>"%MAKER_BIN%\qtcreator.bat"

call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "Path=%Path%;%MAKER_BIN%"
call qtcreator.bat --validate 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_qtcreator_success
  
:test_qtcreator_failed
echo. error: Qt-Creator not available
goto :exit_script

:test_qtcreator_success
rem call which qtcreator -l -d
echo qtcreator (to start Qt-Creator)
if /I "%_BQTC_ARG1%" equ "--start" call qtcreator


:exit_script
call "%_QT_ENV_DIR%\Scripts\deactivate.bat" 1>nul 2>nul
cd /d "%_BQTC_START_DIR%"
set _BQTC_START_DIR=
set _REBUILD=
rem set _QT_VERSION=6.6.3
rem set _QT_DIR=
rem set _QT_ENV_DIR=
rem set _QT_INSTALL_MAKE=
rem set _QTCREATOR_BIN=
goto :EOF