@rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2
@echo off
call "%~dp0\maker_env.bat"
set "_BVCG_START_DIR=%cd%"

rem 1) clone Victron GUI-V2
echo.
echo 1) clone Victron GUI-V2
call "%MAKER_ROOT%\clone_victron-guiv2.bat"
rem defines: _VICTRON_DIR
rem defines: _VICTRON_GUIV2_DIR
if "%_VICTRON_DIR%" EQU "" (echo cloning Victron GUI-V2 failed &goto :EOF)
if "%_VICTRON_GUIV2_DIR%" EQU "" (echo cloning Victron GUI-V2 failed &goto :EOF)
if not exist "%_VICTRON_DIR%" (echo cloning Victron GUI-V2 failed &goto :EOF)
if not exist "%_VICTRON_GUIV2_DIR%" (echo cloning Victron GUI-V2 failed &goto :EOF)

rem 2) install Qt
echo.
echo 2) install Qt
pushd %MAKER_ROOT%
call "%MAKER_ROOT%\build_qt.bat" 6.6.3
echo.
popd
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT is not installed
  goto :EOF
)

rem 3) configure GUI-V2 build
echo.
echo 3) configure GUI-V2 build
echo ...tbd

rem 4) build GUI-V2
echo.
echo 4) build GUI-V2
echo ...tbd

rem 5) install GUI-V2
echo.
echo 5) install GUI-V2
echo ...tbd

rem echo @echo off>"%_GUIV2BUILD%"
rem echo push "%_GUIV2DIR%" >>"%_GUIV2BUILD%"
rem echo call git submodule update --init>>"%_GUIV2BUILD%"
rem echo mkdir build>>"%_GUIV2BUILD%"
rem echo cd build/ >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"