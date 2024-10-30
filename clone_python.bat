@rem https://github.com/hankst69/Python.git
@call "%~dp0scripts\clone_in_folder.bat" "%~dp0projects\Python" "https://github.com/hankst69/Python.git" --changeDir
@call "%~dp0scripts\clone_in_folder.bat" "%~dp0projects\Python\Jupyter\SimpleITK-Notebooks" "https://github.com/InsightSoftwareConsortium/SimpleITK-Notebooks.git"
