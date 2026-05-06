@rem https://stackoverflow.com/questions/2004024/how-to-permanently-delete-a-file-stored-in-git
@rem https://docs.github.com/de/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
@echo off
set "_script_file=%~dpnx0"
set "_script_dir=%~dp0"
set "_script_name=%~n0"
set "_start_dir=%cd%"

rem arg1: repo-url
rem arg2: file-to-delete
rem arg3: [branch-name]

set _clone_url=
set _clone_repo_name=
set _file_to_delete=
set _file_to_delete_name=
set _branch_name=
set _test_mode=
set _forced_mode=
set _reset_mode=
set _diff_mode=
:param_loop
if /I "%~1" equ "--test"      (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-t"          (set "_test_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--forced"    (set "_forced_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-f"          (set "_forced_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--reset"     (set "_reset_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"          (set "_reset_mode=true" &shift &goto :param_loop)
if /I "%~1" equ "--diff"      (set "_diff_mode=--diff" &shift &goto :param_loop)
if /I "%~1" equ "-d"          (set "_diff_mode=--diff" &shift &goto :param_loop)
if "%~1" neq "" if "%_clone_url%"      equ "" (set "_clone_url=%~1" &set "_clone_repo_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_file_to_delete%" equ "" (set "_file_to_delete=%~1" &set "_file_to_delete_name=%~nx1" &shift &goto :param_loop)
if "%~1" neq "" if "%_branch_name%" equ "" (set "_branch_name=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unexpected argument '%~1' &shift &goto :param_loop)

if "%_diff_mode%" neq "" goto :Diff
if "%_clone_url%"      equ "" (echo error: missing argument 1: 'clone-url' &goto :Usage)
if "%_file_to_delete%" equ "" (echo error: missing argument 2: 'file-to-delete' &goto :Usage)
goto :Start

:Diff
echo *** %_script_name% compare vs. han_scripts version ***
echo diff "%_script_file%" "%HANSCRIPT_ROOT%\%_script_name%.bat"
if "%HANSCRIPT_ROOT%" equ "" echo ERROR: compare of '%_script_name%' against han_scripts version not possible - HANSCRIPT_ROOT not defined &goto :Exit
if not exist "%HANSCRIPT_ROOT%\%_script_name%.bat" echo ERROR: compare of '%_script_name%' against han_scripts version not possible - han_scripts version does not exist &goto :Exit
call diff "%_script_file%" "%HANSCRIPT_ROOT%\%_script_name%.bat"
goto :Exit

:Usage
echo.
echo USAGE: %_script_name% git-repo-url file-to-delete [branch-name] [--test^|-t] [--forced^|-f] [--reset^|-r] [--diff^|-d]
echo.
goto :Exit

:Exit
rem cd /d "%_work_dir%"
cd /d "%_start_dir%"
set _script_file=
set _script_dir=
set _script_name=
set _start_dir=
set _work_dir=
set _venv_gfr=
set _repo_orig_dir=
set _repo_new_dir=
set _clone_url=
set _clone_repo_name=
set _branch_name=
set _file_to_delete=
set _file_to_delete_name=
set _test_mode=
set _forced_mode=
set _reset_mode=
set _diff_mode=
set _file_to_permanently_remove_win=
set _file_to_permanently_remove_unix=
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
if not exist "%_repo_orig_dir%\.git\*" set "_reset_mode=true"
if "%_reset_mode%" equ "true" if exist "%_repo_orig_dir%" rmdir /s /q "%_repo_orig_dir%"
if "%_reset_mode%%_forced_mode%" equ "truetrue" if exist "%_venv_gfr%" rmdir /s /q "%_venv_gfr%"


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
if "%_branch_name%" equ "" goto :git_clean_from_commit_history
echo -------------------------------------------------------
echo git switch "%_branch_name%"
echo -------------------------------------------------------
pushd "%_repo_orig_dir%"
call git switch "%_branch_name%"
popd


:git_clean_from_commit_history
set "_file_to_permanently_remove_win=%_file_to_delete:/=\%"
set "_file_to_permanently_remove_unix=%_file_to_delete:\=/%"
rem set _file_to_permanently_remove

cd /d "%_repo_orig_dir%"
if exist "%_file_to_permanently_remove_win%" goto :git_clean_from_commit_history_do
echo.warning: the file to remove does not exist '%_file_to_permanently_remove_win%'
if "%_forced_mode%" equ "" (
  echo.         use --forced option to remove that file from the git history
  goto :Exit
)
echo.
echo. '--forced' option active - continue removing

:git_clean_from_commit_history_do
echo.
echo -------------------------------------------------------
echo removing '%_file_to_permanently_remove_unix%' permanently
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
echo git-filter-repo --sensitive-data-removal --invert-paths --path "%_file_to_permanently_remove_unix%" %_dry_run%
call git-filter-repo --sensitive-data-removal --invert-paths --path "%_file_to_permanently_remove_unix%" %_dry_run%
call deactivate
echo -----------------------
echo.
echo git gc
call git gc
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
