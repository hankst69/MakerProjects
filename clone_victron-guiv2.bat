@echo off
rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2

set "_QT_BIN_DIR=%~dp0qt6\bin"
set "_QT_VERSION=6.6.3"
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT is not installed
  call "%~dp0clone_qt6.bat %_QT_VERSION%"
)

if not exists "%~dp0Victron" mkdir "%~dp0Victron"
set "_GUIV2DIR=%~dp0Victron\gui-v2\"
set "_GUIV2BUILD=%~dp0Victron\build_gui-v2.bat"
set "_QTMQTTDIR=%~dp0Victron\qtmqtt\"

rem Submodule 'qtmqtt' (https://code.qt.io/qt/qtmqtt.git)
rem vs https://github.com/qt/qtmqtt.git
rem
rem pushd "%_QTMQTTDIR%"
rem call git clone https://github.com/qt/qtmqtt.git .
rem call git checkout 6.6.3
rem popd
rem
rem call "%~dp0scripts\clone_in_folder.bat" "%_QTMQTTDIR%" "https://github.com/qt/qtmqtt.git" --switchBranch %_QT_VERSION%
goto :EOF

mkdir build
cd build
echo call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64
echo call "%_QTMQTTDIR%\6.6.3\msvc2019_64\bin\qt-configure-module.bat" ..
echo call "%_QTMQTTDIR%\Tools\CMake_64\bin\cmake.exe" --build .
echo call "%_QTMQTTDIR%\Tools\CMake_64\bin\cmake.exe" --install . --verbose
popd

echo @echo off>"%_GUIV2BUILD%"
echo push "%_GUIV2DIR%" >>"%_GUIV2BUILD%"
echo call git submodule update --init>>"%_GUIV2BUILD%"
echo mkdir build>>"%_GUIV2BUILD%"
echo cd build/ >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"
rem echo >>"%_GUIV2BUILD%"
call "%~dp0scripts\clone_in_folder.bat" "%_GUIV2DIR%" "https://github.com/victronenergy/gui-v2.git" --changeDir
