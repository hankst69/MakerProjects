@rem https://stackoverflow.com/questions/1216733/remove-a-directory-permanently-from-git
@rem https://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
@rem https://www.somethingorothersoft.com/2009/09/08/the-definitive-step-by-step-guide-on-how-to-delete-a-directory-permanently-from-git-on-widnows-for-dumbasses-like-myself
@rem https://www.somethingorothersoft.com/?p=80
@echo off
set "_start_dir=%~dp0"
set "_script_name=%~n0"
set "_start_dir=%cd%"

rem arg1: repo-url
rem arg2: subdir

set _clone_url=
set _clone_repo_name=
set _sub_dir=
set _test_mode=
set _forced_mode=
set _reset_mode=
:param_loop
if /I "%~1" equ "--test"      (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-t"          (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--forced"    (set "_forced_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-f"          (set "_forced_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--reset"     (set "_reset_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"          (set "_reset_mode=true" &shift &goto :param_loop)
if "%~1" neq "" if "%_clone_url%"    equ "" (set "_clone_url=%~1" &set "_clone_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_sub_dir%"      equ "" (set "_sub_dir=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unexpected argument '%~1' &shift &goto :param_loop)

if "%_clone_url%" equ "" (echo error: missing argument 1: 'clone-url' &goto :Usage)
if "%_sub_dir%" equ ""   (echo error: missing argument 2: 'sub-dir' &goto :Usage)
goto :Start

:Usage
echo.
echo USAGE: %_script_name% git-repo-url sub-dir [new-repo-url] [--test^|-t] [--reset^|-r]
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
set "_work_dir=%_start_dir%\_git_rm_dir"
set "_work_dir=%_start_dir%"
if not exist "%_work_dir%" mkdir "%_work_dir%"

set "_venv_gfr=%_work_dir%\.gitfilterrepo"
set "_repo_orig_dir=%_work_dir%\_git_rmdir_tmp"
set "_repo_new_dir=%_work_dir%\_git_rmdir_new"

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


cd /d "%_work_dir%"

if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"
mkdir "%_repo_orig_dir%"
cd /d "%_repo_orig_dir%"
echo.
echo -------------------------------------------------------
echo git clone "%_clone_url%" "%_repo_orig_dir%"
echo -------------------------------------------------------
call git clone "%_clone_url%" "%_repo_orig_dir%"


cd /d "%_repo_orig_dir%"
echo.
echo -------------------------------------------------------
echo git gc
echo -------------------------------------------------------
call git gc
rem https://www.somethingorothersoft.com/2009/09/08/the-definitive-step-by-step-guide-on-how-to-delete-a-directory-permanently-from-git-on-widnows-for-dumbasses-like-myself
goto :Exit
