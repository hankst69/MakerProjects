@echo off
if /I "%~1" equ "--projects" goto :clone_projects
if /I "%~1" equ "-p" goto :clone_projects
if /I "%~1" equ "--tools" goto :clone_tools
if /I "%~1" equ "-t" goto :clone_tools
if /I "%~1" equ "--clean_tools" goto :clean_tools
if /I "%~1" equ "-ct" goto :clean_tools
if /I "%~1" equ "-?" goto :usage
if /I "%~1" equ "-h" goto :usage
if /I "%~1" equ "--help" goto :usage
if /I "%~1" neq "" goto :clone

:usage
echo USAGE:  
echo. clone [-p  ^| --projects]
echo. clone [-t  ^| --tools]
echo. clone [-ct ^| --clean_tools]
echo. clone ^<project_name^> [version]
echo.
call "%~dp0\..\core\script_caller.bat" "clone" --no_usage
goto :EOF

:clone
call "%~dp0\..\core\script_caller.bat" "clone" %*
goto :EOF

:clone_tools
echo multi_clone llvm emsdk choco qt vesc gperf gperftools zstd
rem call "%~dp0\..\core\multi_clone.bat" llvm emsdk choco qt vesc gperf gperftools zstd &rem bison
goto :EOF

:clone_projects
echo multi_clone Python UserScripts ArduinoSketches han_Dev
rem call "%~dp0\..\core\multi_clone.bat" Python UserScripts ArduinoSketches han_Dev
echo multi_clone han_Solar Victron
rem call "%~dp0\..\core\multi_clone.bat" han_Solar Victron
echo multi_clone han_HAM wfview OpenWebRx HackRF
rem call "%~dp0\..\core\multi_clone.bat" han_HAM wfview OpenWebRx HackRF
echo multi_clone SOLID IPTools ROMO AppleTV
rem call "%~dp0\..\core\multi_clone.bat" SOLID IPTools ROMO AppleTV
goto :EOF

:clean_tools
call "%~dp0\maker_env.bat"
if not exist "%MAKER_DIR_TOOLS%\Emsdk" if not exist "%MAKER_DIR_TOOLS%\Choco" if not exist "%MAKER_DIR_QT%" if not exist "%MAKER_DIR_TOOLS%\VESC" (
  echo nothing to clean
  goto :EOF
)
echo.
echo ...about to delete cloned sources and build outputs of:
if exist "%MAKER_DIR_TOOLS%\Emsdk" (
  echo.
  echo %MAKER_DIR_TOOLS%\Emsdk
  dir /b "%MAKER_DIR_TOOLS%\Emsdk"
)
if exist "%MAKER_DIR_TOOLS%\Choco" (
  echo.
  echo %MAKER_DIR_TOOLS%\Choco
  dir /b "%MAKER_DIR_TOOLS%\Choco"
)
if exist "%MAKER_DIR_QT%" (
  echo.
  echo %MAKER_DIR_QT%
  dir /b "%MAKER_DIR_QT%"
)
if exist "%MAKER_DIR_TOOLS%\VESC" (
  echo.
  echo %MAKER_DIR_TOOLS%\VESC
  dir /b "%MAKER_DIR_TOOLS%\VESC"
)
echo.
if exist "%MAKER_DIR_TOOLS%\Emsdk" (
  echo.
  echo ...about to delete '%MAKER_DIR_TOOLS%\Emsdk'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_DIR_TOOLS%\Emsdk"
)
if exist "%MAKER_DIR_TOOLS%\Choco" (
  echo.
  echo ...about to delete '%MAKER_DIR_TOOLS%\Choco'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_DIR_TOOLS%\Choco"
)
if exist "%MAKER_DIR_QT%" (
  echo.
  echo ...about to delete '%MAKER_DIR_QT%'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_DIR_QT%"
)
if exist "%MAKER_DIR_TOOLS%\VESC" (
  echo.
  echo ...about to delete '%MAKER_DIR_TOOLS%\VESC'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_DIR_TOOLS%\VESC"
)
goto :EOF
