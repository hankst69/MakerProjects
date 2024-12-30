@rem https://github.com/llvm/llvm-project
@rem https://llvm.org/docs/GettingStarted.html
@echo off
call "%~dp0\maker_env.bat"

set _LLVM_VERSION=
if "%~1" neq "" set "_LLVM_VERSION=%~1"

set "_LLVM_DIR=%MAKER_TOOLS%\LLVM"
set "_LLVM_SOURCES_DIR=%_LLVM_DIR%\llvm-project%_LLVM_VERSION%"
if "%_LLVM_VERSION%" neq "" goto :llvm_clone_version


rem --- cloning LLVM
:llvm_clone_latest
rem if not exist "%_LLVM_DIR%" mkdir "%_LLVM_DIR%"
rem if not exist "%_LLVM_SOURCES_DIR%" mkdir "%_LLVM_SOURCES_DIR%"
if exist "%_LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --changeDir
rem call git config --add remote.origin.fetch "^refs/heads/users/*"
rem call git config --add remote.origin.fetch "^refs/heads/revert-*"
rem call git config --edit
rem call git pull
goto :llvm_clone_done


:llvm_clone_version
rem https://github.com/llvm/llvm-project/tree/release/16.x
rem if not exist "%_LLVM_DIR%" mkdir "%_LLVM_DIR%"
rem if not exist "%_LLVM_SOURCES_DIR%" mkdir "%_LLVM_SOURCES_DIR%"
if exist "%_LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --changeDir
if "%_LLVM_VERSION%" neq "" call git switch release/%_LLVM_VERSION%.x
call git pull

:llvm_clone_done
echo LLVM-CLONE %_LLVM_VERSION% done

cd "%_LLVM_SOURCES_DIR%"
