@echo off
rem echo error: ensure_qt-wasm is not implelemnted
call "%~dp0\build_qt-wasm.bat" %*
set "path=%QTW_BIN_DIR%\bin;%path%"
call "%~dp0\ensure_emsdk.bat" %QTW_EMSDK_VERSION%
