@rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
@call "%~dp0\validate.bat" "LLVM-CLANG" "clang --version" "for /f ""tokens=2,3 delims= "" %%%%i in ('call clang --version') do if ""%%%%i"" equ ""version"" for /f ""tokens=1,* delims=g"" %%%%k in (""%%%%j"") do echo %%%%k" %*
