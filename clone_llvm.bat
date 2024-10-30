@rem https://github.com/llvm/llvm-project
@echo off
set "_ROOT_DIR=%~dp0"

set "_LLVM_DIR=%_ROOT_DIR%tools\LLVM"
set "_LLVM_SOURCES_DIR=%_ROOT_DIR%tools\LLVM\llvm-project"

rem if not exist "%_LLVM_DIR%" mkdir "%_LLVM_DIR%"
rem if not exist "%_LLVM_SOURCES_DIR%" mkdir "%_LLVM_SOURCES_DIR%"

rem call "%_ROOT_DIR%scripts\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --config core.autocrlf=false --changeDir
call "%_ROOT_DIR%scripts\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --changeDir

rem call git config --add remote.origin.fetch "^refs/heads/users/*"
rem call git config --add remote.origin.fetch "^refs/heads/revert-*"
rem call git config --edit
rem call git pull

rem cd "%_LLVM_DIR%"
