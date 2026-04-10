@rem https://github.com/llvm/llvm-project
@rem https://llvm.org/docs/GettingStarted.html
@echo off
call "%~dp0\maker_env.bat" %* --silent

set "_CLLVM_VERSION=%MAKER_VERSION%"

set "LLVM_DIR=%MAKER_TOOLS%\LLVM"
set "LLVM_SOURCES_DIR=%LLVM_DIR%\llvm-project%_CLLVM_VERSION%"

rem if "%MAKER_MSG_VERBOSE%" neq "" set _LLVM_
if "%_CLLVM_VERSION%" neq "" goto :llvm_clone_version


rem --- cloning LLVM
:llvm_clone_latest
rem if not exist "%LLVM_DIR%" mkdir "%LLVM_DIR%"
rem if not exist "%LLVM_SOURCES_DIR%" mkdir "%LLVM_SOURCES_DIR%"
if exist "%LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --changeDir
rem call git config --add remote.origin.fetch "^refs/heads/users/*"
rem call git config --add remote.origin.fetch "^refs/heads/revert-*"
rem call git config --edit
rem call git pull
goto :llvm_clone_done


:llvm_clone_version
rem https://github.com/llvm/llvm-project/tree/release/16.x
rem if not exist "%LLVM_DIR%" mkdir "%LLVM_DIR%"
rem if not exist "%LLVM_SOURCES_DIR%" mkdir "%LLVM_SOURCES_DIR%"
if exist "%LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --changeDir
if "%_CLLVM_VERSION%" neq "" call git switch release/%_CLLVM_VERSION%.x
call git pull

:llvm_clone_done
echo CLONE LLVM %_CLLVM_VERSION% done

cd "%LLVM_SOURCES_DIR%"
