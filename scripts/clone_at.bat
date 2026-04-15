@echo off
@rem https://hera.siemens-healthineers.com/tfs/AXProd/XRay/_git/helium-imgsys-core
@rem https://hera.siemens-healthineers.com/tfs/AXProd/XRay/_git/helium-imgsys-Algo
call "%~dp0\maker_env.bat" %* --silent

set "AT_VERSION=%MAKER_VERSION%"

set "AT_DIR=%MAKER_DIR_AT%"

set "AT_IMGSYS_CORE_SOURCES_DIR=%AT_DIR%\imgsys-Core"
set "AT_IMGSYS_ALGO_SOURCES_DIR=%AT_DIR%\imgsys-Algo"

if "%MAKER_MSG_VERBOSE%" neq "" set AT_


:at_clone
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%AT_IMGSYS_CORE_SOURCES_DIR%" "https://hera.siemens-healthineers.com/tfs/AXProd/XRay/_git/helium-imgsys-core" --depth 1 --changeDir
call git pull
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%AT_IMGSYS_ALGO_SOURCES_DIR%" "https://hera.siemens-healthineers.com/tfs/AXProd/XRay/_git/helium-imgsys-Algo" --changeDir
call git pull

rem link "_Globals" folder from helium-imgsys-core into helium-imgsys-Algo
if not exist "%AT_IMGSYS_ALGO_SOURCES_DIR%\_Globals" mklink /D /J "%AT_IMGSYS_ALGO_SOURCES_DIR%\_Globals" "%AT_IMGSYS_CORE_SOURCES_DIR%\_Globals"
if not exist "%AT_IMGSYS_ALGO_SOURCES_DIR%\_Globals\Singapore.snk" mklink /H "%AT_IMGSYS_ALGO_SOURCES_DIR%\_Globals\Singapore.snk" "%AT_IMGSYS_CORE_SOURCES_DIR%\Tools\AT.Helium.Analyzer\AT.Helium.Analyzer\Singapore.snk"


if "%AT_VERSION%" equ "" goto :at_clone_done
cd /d "%AT_IMGSYS_ALGO_SOURCES_DIR%"
call git switch "%AT_VERSION%"
call git pull


:at_clone_done
echo CLONE AT %AT_VERSION% done
cd /d "%AT_DIR%"
