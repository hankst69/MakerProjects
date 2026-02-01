@rem https://stackoverflow.com/questions/2004024/how-to-permanently-delete-a-file-stored-in-git
@rem https://docs.github.com/de/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
@echo off
set "_script_dir=%~dp0"
set "_script_name=%~n0"
set "_start_dir=%cd%"

rem arg1: repo-url
rem arg2: file-to-delete

set _clone_url=
set _clone_repo_name=
set _file_to_delete=
set _file_to_delete_name=
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
if "%~1" neq "" if "%_clone_url%"      equ "" (set "_clone_url=%~1" &set "_clone_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_file_to_delete%" equ "" (set "_file_to_delete=%~1" &set "_file_to_delete_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unexpected argument '%~1' &shift &goto :param_loop)

if "%_clone_url%"      equ "" (echo error: missing argument 1: 'clone-url' &goto :Usage)
if "%_file_to_delete%" equ "" (echo error: missing argument 2: 'file-to-delete' &goto :Usage)
goto :Start

:Usage
echo.
echo USAGE: %_script_name% git-repo-url file-to-delete [--test^|-t] [--forced^|-f] [--reset^|-r]
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
set _file_to_delete=
set _file_to_delete_name=
set _test_mode=
set _forced_mode=
set _reset_mode=
goto :EOF


:Start
set "_work_dir=%_start_dir%\_git_rm_file"
set "_work_dir=%_start_dir%"
if not exist "%_work_dir%" mkdir "%_work_dir%"

set "_venv_gfr=%_work_dir%\.gitfilterrepo"
set "_repo_orig_dir=%_work_dir%\_git_rmfile_tmp"
set "_repo_new_dir=%_work_dir%\_git_rmfile_new"
call deactivate 1>nul 2>nul


:Reset
if "%_reset_mode%" neq "" if exist "%_venv_gfr%" rmdir /s /q "%_venv_gfr%"
if "%_reset_mode%" neq "" if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"


:Install
echo.
echo -------------------------------------------------------
echo installing git-filter-repo
echo -------------------------------------------------------
if exist "%_venv_gfr%\Scripts\git-filter-repo.exe" goto :git_filter_repo_installed
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
rem set "_File_TO_PERMANENTLY_REMOVE=%_file_to_delete%"
set "_File_TO_PERMANENTLY_REMOVE_win=%_file_to_delete:/=\%"
set "_File_TO_PERMANENTLY_REMOVE_unix=%_file_to_delete:\=/%"
rem set _File_TO_PERMANENTLY_REMOVE

cd /d "%_repo_orig_dir%"
if exist "%_File_TO_PERMANENTLY_REMOVE_win%" goto :git_clean_from_commit_history_do
echo.warning: the file to remove does not exist '%_File_TO_PERMANENTLY_REMOVE_win%'
if "%_forced_mode%" equ "" (
  echo.         use --forced option to remove that file from the git history
  goto :Exit
)
echo.
echo. '--forced' option active - continue removing

:git_clean_from_commit_history_do
echo.
echo -------------------------------------------------------
echo removing '%_File_TO_PERMANENTLY_REMOVE_unix%' permanently
echo -------------------------------------------------------
call "%_venv_gfr%\Scripts\activate"
set _dry_run=
if "%_test_mode%" neq "" set "_dry_run=--dry-run"
echo git-filter-repo --sensitive-data-removal --invert-paths --path "%_File_TO_PERMANENTLY_REMOVE_unix%" %_dry_run%
call git-filter-repo --sensitive-data-removal --invert-paths --path "%_File_TO_PERMANENTLY_REMOVE_unix%" %_dry_run%
call deactivate
goto :Exit

echo.
echo -------------------------------------------------------
echo. perform "git push --all --force" to update the remote repository with modified history
echo -------------------------------------------------------
goto :Exit
