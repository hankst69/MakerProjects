@echo off
echo.
echo ...about to delete all downloaded and compiled tools
echo.
echo %~dp0Qt
dir /b "%~dp0Qt"
echo.
echo %~dp0Emsdk
dir /b "%~dp0Emsdk"
echo.
echo abort with Ctrl-C (any other key to continue)
echo.
pause
echo.
rmdir /s /q "%~dp0Qt"
rmdir /s /q "%~dp0Emsdk"
