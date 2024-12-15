@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_llvm.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: LLVM is not available - trying to build from sources
call "%MAKER_ROOT%\build_llvm.bat" %*
:Exit
"%MAKER_SCRIPTS%\validate_llvm.bat" %*
