@echo off
set "_MAKER_ROOT=%~dp0.."

rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
rem ...tbd
:test_llvm_success
