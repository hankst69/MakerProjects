@echo off
rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
rem ...tbd
call clang --version 1>nul 2>nul
if %ERRORLEVEL% equ 0 exit /b 0
exit /b 1