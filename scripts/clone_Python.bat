@rem https://github.com/hankst69/Python.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_PYTHON=%MAKER_PROJECTS%\Python"

set "_PYTHON_PROJECTS_DIR=%MAKER_PROJECTS_PYTHON%"
set "_PYTHON_ITKNOTEBOOKS_DIR=%MAKER_PROJECTS_PYTHON%\Jupyter\SimpleITK-Notebooks"
set "_PYTHON_GITFILTERREPO_DIR=%MAKER_PROJECTS_PYTHON%\Git-Filter-Repo"


call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_PYTHON_PROJECTS_DIR%"      "https://github.com/hankst69/Python.git" --changeDir
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_PYTHON_ITKNOTEBOOKS_DIR%"  "https://github.com/InsightSoftwareConsortium/SimpleITK-Notebooks.git"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_PYTHON_GITFILTERREPO_DIR%" "https://github.com/newren/git-filter-repo"
rem python "%_PYTHON_GITFILTERREPO_DIR%\git-filter-repo" --help