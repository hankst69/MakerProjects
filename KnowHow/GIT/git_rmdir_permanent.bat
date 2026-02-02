@rem https://stackoverflow.com/questions/1216733/remove-a-directory-permanently-from-git
@rem https://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
@rem https://www.somethingorothersoft.com/2009/09/08/the-definitive-step-by-step-guide-on-how-to-delete-a-directory-permanently-from-git-on-widnows-for-dumbasses-like-myself
@rem https://www.somethingorothersoft.com/
@rem https://commandmasters.com/commands/git-filter-repo-common/
@echo off
set "_script_dir=%~dp0"
set "_script_name=%~n0"
set "_start_dir=%cd%"

rem arg1: repo-url
rem arg2: dir-to-delete

set _clone_url=
set _clone_repo_name=
set _sub_dir_to_delete=
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
if "%~1" neq "" if "%_clone_url%"         equ "" (set "_clone_url=%~1" &set "_clone_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_sub_dir_to_delete%" equ "" (set "_sub_dir_to_delete=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unexpected argument '%~1' &shift &goto :param_loop)

if "%_clone_url%" equ "" (echo error: missing argument 1: 'clone-url' &goto :Usage)
if "%_sub_dir_to_delete%" equ "" (echo error: missing argument 2: 'sub-dir' &goto :Usage)
goto :Start

:Usage
echo.
echo USAGE: %_script_name% git-repo-url sub-dir-to-delete [--test^|-t] [--forced^|-f] [--reset^|-r]
echo.
goto :Exit

:Exit
rem cd /d "%_work_dir%"
cd /d "%_start_dir%"
set _script_dir=
set _script_name=
set _start_dir=
set _work_dir=
set _venv_gfr=
set _repo_orig_dir=
set _repo_new_dir=
set _clone_url=
set _clone_repo_name=
set _sub_dir_to_delete=
set _test_mode=
set _forced_mode=
set _reset_mode=
goto :EOF


:Start
rem set "_work_dir=%_start_dir%\_git_rm_file"
set "_work_dir=%_start_dir%"
if not exist "%_work_dir%" mkdir "%_work_dir%"

set "_venv_gfr=%_work_dir%\.gitfilterrepo"
set "_repo_orig_dir=%_work_dir%\_git_rm_tmp"
set "_repo_new_dir=%_work_dir%\_git_rm_new"
call deactivate 1>nul 2>nul


:Reset
if "%_reset_mode%" neq "" if exist "%_venv_gfr%" rmdir /s /q "%_venv_gfr%"
if "%_reset_mode%" neq "" if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"


:Install
if exist "%_venv_gfr%\Scripts\git-filter-repo.exe" goto :git_filter_repo_installed
echo.
echo -------------------------------------------------------
echo installing git-filter-repo
echo -------------------------------------------------------
call python -m venv "%_venv_gfr%"
call "%_venv_gfr%\Scripts\activate"
call python -m pip install --upgrade pip
call python -m pip install git-filter-repo
call deactivate
:git_filter_repo_installed


cd /d "%_work_dir%"
if exist "%_repo_orig_dir%" goto :git_clean_from_commit_history


:Clone
if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"
mkdir "%_repo_orig_dir%"
cd /d "%_repo_orig_dir%"
echo.
echo -------------------------------------------------------
echo git clone "%_clone_url%" "%_repo_orig_dir%"
echo -------------------------------------------------------
call git clone "%_clone_url%" "%_repo_orig_dir%"


:git_clean_from_commit_history
set "_Dir_TO_PERMANENTLY_REMOVE="%_sub_dir_to_delete%"
set "_Dir_TO_PERMANENTLY_REMOVE_win=%_sub_dir_to_delete:/=\%"
set "_Dir_TO_PERMANENTLY_REMOVE_unix=%_sub_dir_to_delete:\=/%"

cd /d "%_repo_orig_dir%"
rem https://www.somethingorothersoft.com/2009/09/08/the-definitive-step-by-step-guide-on-how-to-delete-a-directory-permanently-from-git-on-widnows-for-dumbasses-like-myself

if exist "%_Dir_TO_PERMANENTLY_REMOVE_win%\*" goto :git_clean_from_commit_history_do
echo.warning: the directory to remove does not exist '%_Dir_TO_PERMANENTLY_REMOVE_win%'
if "%_forced_mode%" equ "" (
  echo.         use --forced option to remove that directory from the git history
  goto :Exit
)
echo.
echo. '--forced' option active - continue removing

:git_clean_from_commit_history_do
echo.
echo -------------------------------------------------------
echo removing '%_Dir_TO_PERMANENTLY_REMOVE_unix%' permanently
echo -------------------------------------------------------
echo.
echo git gc
call git gc
echo git count-objects -v
call git count-objects -v
echo -----------------------
echo.
call "%_venv_gfr%\Scripts\activate"
set _dry_run=
if "%_test_mode%" neq "" set "_dry_run=--dry-run"
rem echo git-filter-repo --index-filter "git rm -r --cached --ignore-unmatch %_Dir_TO_PERMANENTLY_REMOVE_unix%" HEAD %_dry_run%
rem call git-filter-repo --index-filter "git rm -r --cached --ignore-unmatch %_Dir_TO_PERMANENTLY_REMOVE_unix%" HEAD %_dry_run%
rem echo.
rem call git update-ref -d refs/original/refs/heads/master
rem if exist ".git/refs/original" rmdir /s /q ".git/refs/original"
rem call git reflog expire --expire=now --all
rem call git gc --prune=now
rem echo -----------------------
echo git filter-repo --path "%_Dir_TO_PERMANENTLY_REMOVE_unix%" --invert-paths
call git filter-repo --path "%_Dir_TO_PERMANENTLY_REMOVE_unix%" --invert-paths
call deactivate
echo -----------------------
echo.
rem echo git gc
rem call git gc
echo git count-objects -v
call git count-objects -v
echo -----------------------
echo.
goto :Exit

echo.
echo -------------------------------------------------------
rem echo. perform "git push --all --force" to update the remote repository with modified history
echo perfom "git push --force --mirror origin" to update the remote repository with modified history
echo -------------------------------------------------------
goto :Exit
