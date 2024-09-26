@echo off
set "_MAKER_ROOT=%~dp0"
rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2

set "_VICTRON_DIR=%_MAKER_ROOT%\Victron"
if not exist "%_VICTRON_DIR%" mkdir "%_VICTRON_DIR%"

pushd %_MAKER_ROOT%
call "%_MAKER_ROOT%\build_emsdk.bat" 3.1.37
call "%_MAKER_ROOT%\build_qt-wasm.bat" 6.6.3
popd

if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT is not installed
  goto :EOF
)

set "_GUIV2DIR=%_VICTRON_DIR%\gui-v2\"
set "_GUIV2BUILD=%_VICTRON_DIR%\build_gui-v2.bat"
set "_QTMQTTDIR=%_VICTRON_DIR%\qtmqtt\"

call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_GUIV2DIR%" "https://github.com/victronenergy/gui-v2.git" --changeDir
goto :EOF

rem Submodule 'qtmqtt' (https://code.qt.io/qt/qtmqtt.git)
rem vs https://github.com/qt/qtmqtt.git
rem
rem pushd "%_QTMQTTDIR%"
rem call git clone https://github.com/qt/qtmqtt.git .
rem call git checkout 6.6.3
rem popd
rem
rem call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_QTMQTTDIR%" "https://github.com/qt/qtmqtt.git" --switchBranch %_QT_VERSION%
pushd "%_VICTRON_DIR%"
rmdir /s /q "%_VICTRON_DIR%\qtmqtt_build"
if not exist "%_VICTRON_DIR%\qtmqtt_build" mkdir "%_VICTRON_DIR%\qtmqtt_build"
cd "%_VICTRON_DIR%\qtmqtt_build"
rem echo call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
rem echo call "%_QTMQTTDIR%\6.6.3\msvc2019_64\bin\qt-configure-module.bat" ..
rem echo call "%_QTMQTTDIR%\Tools\CMake_64\bin\cmake.exe" --build .
rem echo call "%_QTMQTTDIR%\Tools\CMake_64\bin\cmake.exe" --install . --verbose
popd

echo @echo off>"%_GUIV2BUILD%"
echo push "%_GUIV2DIR%" >>"%_GUIV2BUILD%"
echo call git submodule update --init>>"%_GUIV2BUILD%"
echo mkdir build>>"%_GUIV2BUILD%"
echo cd build/ >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"