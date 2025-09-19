@rem https://github.com/hankst69/Python.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_PYTHON=%MAKER_PROJECTS%\Python"
set "_PYTHON_PROJECTS_DIR=%MAKER_PROJECTS_PYTHON%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_PYTHON_PROJECTS_DIR%" "https://github.com/hankst69/Python.git" --changeDir
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_PYTHON_PROJECTS_DIR%\Jupyter\SimpleITK-Notebooks" "https://github.com/InsightSoftwareConsortium/SimpleITK-Notebooks.git"
