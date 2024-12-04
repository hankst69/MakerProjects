@rem https://github.com/llvm/llvm-project
@echo off
call "%~dp0\maker_env.bat"

set _LLVM_VERSION=
if "%~1" neq "" set "_LLVM_VERSION=%~1"

set "_LLVM_DIR=%MAKER_TOOLS%\LLVM"
set "_LLVM_SOURCES_DIR=%_LLVM_DIR%\llvm-project"

rem --- cloning LLVM
:llvm_clone
rem if not exist "%_LLVM_DIR%" mkdir "%_LLVM_DIR%"
rem if not exist "%_LLVM_SOURCES_DIR%" mkdir "%_LLVM_SOURCES_DIR%"
if exist "%_LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done

rem call "%_ROOT_DIR%scripts\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --config core.autocrlf=false --changeDir
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --changeDir

rem call git config --add remote.origin.fetch "^refs/heads/users/*"
rem call git config --add remote.origin.fetch "^refs/heads/revert-*"
rem call git config --edit
rem call git pull

:qt_clone_done
echo LLVM-CLONE %_LLVM_VERSION% done

rem cd "%_LLVM_DIR%"
