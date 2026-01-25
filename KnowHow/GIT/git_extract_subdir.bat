@echo off
set "_script_dir=%~dp0"
set "_script_name=%~n0"
set "_start_dir=%cd%"

rem arg1: repo-url
rem arg2: subdir
rem arg3: new_repo_url

set _clone_url=
set _clone_repo_name=
set _sub_dir=
set _new_repo_url=
set _new_repo_name=
set _test_mode=
set _reset_mode=
:param_loop
if /I "%~1" equ "--test"      (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-t"          (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--reset"     (set "_reset_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"          (set "_reset_mode=true" &shift &goto :param_loop)
if "%~1" neq "" if "%_clone_url%"    equ "" (set "_clone_url=%~1" &set "_clone_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_sub_dir%"      equ "" (set "_sub_dir=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_new_repo_url%" equ "" (set "_new_repo_url=%~1" &set "_new_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unexpected argument '%~1' &shift &goto :param_loop)

if "%_clone_url%" equ "" (echo error: missing argument 1: 'clone-url' &goto :Usage)
if "%_sub_dir%" equ ""   (echo error: missing argument 2: 'sub-dir' &goto :Usage)
goto :Start

:Usage
echo.
echo USAGE: %_script_name% git-repo-url sub-dir [new-repo-url] [--reset^|-r]
echo.
goto :Exit

:Exit
rem cd /d "%_work_dir%"
set _script_dir=
set _script_name=
set _start_dir=
set _work_dir=
set _venv_gfr=
set _repo_orig_dir=
set _repo_new_dir=
set _clone_url=
set _clone_repo_name=
set _sub_dir=
set _test_mode=
set _forced_mode=
set _reset_mode=
goto :EOF


:Start
set "_work_dir=%_start_dir%\_git_extract_dir"
set "_work_dir=%_start_dir%"
if not exist "%_work_dir%" mkdir "%_work_dir%"

set "_venv_gfr=%_work_dir%\.gitfilterrepo"
set "_repo_orig_dir=%_work_dir%\_git_xtdir_tmp"
set "_repo_new_dir=%_work_dir%\_git_xtdir_new"

call deactivate 1>nul 2>nul
echo.
echo -------------------------------------------------------
echo installing git-filter-repo
echo -------------------------------------------------------
if "%_reset_mode%" neq "" if exist "%_venv_gfr%" rmdir /s /q "%_venv_gfr%"
if exist "%_venv_gfr%\Scripts\git-filter-repo.exe" (
  call "%_venv_gfr%\Scripts\activate"
  goto :git_filter_repo_installed
)
call python -m venv "%_venv_gfr%"
call "%_venv_gfr%\Scripts\activate"
call python -m pip install --upgrade pip
call python -m pip install git-filter-repo
:git_filter_repo_installed


if "%_test_mode%" neq "" goto :_test
cd /d "%_work_dir%"


if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"
mkdir "%_repo_orig_dir%"
cd /d "%_repo_orig_dir%"
echo.
echo -------------------------------------------------------
echo git clone "%_clone_url%" "%_repo_orig_dir%"
echo -------------------------------------------------------
call git clone "%_clone_url%" "%_repo_orig_dir%"

:_test
cd /d "%_repo_orig_dir%"
echo.
echo -------------------------------------------------------
echo git-filter-repo --path "%_sub_dir%/"
echo -------------------------------------------------------
call git-filter-repo --path "%_sub_dir%/"
echo.
echo -------------------------------------------------------
echo git-filter-repo --path-rename "%_sub_dir%/:"
echo -------------------------------------------------------
call git-filter-repo --path-rename "%_sub_dir%/:"

cd /d "%_work_dir%"
if exist "%_repo_new_dir%" rmdir /s /q "%_repo_new_dir%"
mkdir "%_repo_new_dir%"
cd /d "%_repo_new_dir%"
echo.
echo -------------------------------------------------------
echo git init
call git init
echo.
echo xcopy /R /Y /S /E "%_repo_orig_dir%\.git" "%_repo_new_dir%\.git"
xcopy /R /Y /S /E "%_repo_orig_dir%\.git" "%_repo_new_dir%\.git"
echo.
echo git reset --hard
call git reset --hard
echo.
dir /b .
call deactivate
if "%_new_repo_url%" equ "" goto :EOF
echo.
echo -------------------------------------------------------
echo git remote add origin "%_new_repo_url%"
call git remote add origin "%_new_repo_url%"
echo git branch -M main
call git branch -M main
echo.
echo -------------------------------------------------------
echo now call "git push -u origin main"
rem call git push -u origin main
goto :Exit
