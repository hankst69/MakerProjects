@rem https://github.com/llvm/llvm-project
@rem https://llvm.org/docs/GettingStarted.html
@echo off
call "%~dp0\maker_env.bat" %* --silent

set "_CLLVM_VERSION=%MAKER_VERSION%"

rem set "LLVM_DIR=%MAKER_DIR_TOOLS%\LLVM"
set "LLVM_DIR=%MAKER_DIR_LLVM%"

set "LLVM_SOURCES_DIR=%LLVM_DIR%\llvm-project%_CLLVM_VERSION%"

rem if "%MAKER_MSG_VERBOSE%" neq "" set _LLVM_
if "%_CLLVM_VERSION%" neq "" goto :llvm_clone_version

set "_CLLVM_VERSION_NOINFOS=--no_infos"
if not exist "%LLVM_SOURCES_DIR%\*" set _CLLVM_VERSION_NOINFOS=
if "%MAKER_MSG_NOINFOS%" neq "" set "_CLLVM_VERSION_NOINFOS=%MAKER_MSG_NOINFOS%"


rem --- cloning LLVM
:llvm_clone_latest
rem if not exist "%LLVM_DIR%" mkdir "%LLVM_DIR%"
rem if not exist "%LLVM_SOURCES_DIR%" mkdir "%LLVM_SOURCES_DIR%"
if exist "%LLVM_SOURCES_DIR%\cmake\Modules\LLVMVersion.cmake" goto :llvm_clone_done
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --depth 1 --changeDir %_CLLVM_VERSION_NOINFOS%
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
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%LLVM_SOURCES_DIR%" "https://github.com/llvm/llvm-project.git" --changeDir %_CLLVM_VERSION_NOINFOS%
if "%_CLLVM_VERSION%" neq "" call git switch release/%_CLLVM_VERSION%.x
if "%_CLLVM_VERSION_NOINFOS%" equ "" (call git pull) else (call git pull 1>nul 2>nul)

:llvm_clone_done
if "%_CLLVM_VERSION_NOINFOS%" equ "" echo CLONE LLVM %_CLLVM_VERSION% done

cd "%LLVM_SOURCES_DIR%"
