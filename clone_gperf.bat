@rem https://github.com/gperftools/gperftools
@echo off
call "%~dp0\maker_env.bat"

set _GP_VERSION=
if "%~1" neq "" set "_GP_VERSION=%~1"

set "_GP_DIR=%MAKER_TOOLS%\GPerf"
set "_GP_SOURCES_DIR=%_gp_DIR%\gperf_sources%_GP_VERSION%\"

rem --- cloning GPerf
:gp_clone
rem if exist "%_GP_SOURCES_DIR%\qtbase\configure.bat" echo GPerf-CLONE %_gp_VERSION% already done &goto :gp_clone_done

rem --- ensure perl (is required for cloning the qt submodules)
rem call "%MAKER_SCRIPTS%\validate_perl.bat"
rem if %ERRORLEVEL% NEQ 0 goto :EOF
rem echo.

echo GPerf-CLONE %_GP_VERSION%
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_GP_SOURCES_DIR%" "https://github.com/gperftools/gperftools"
pushd "%_GP_SOURCES_DIR%"

rem call git pull
rem if not exist "%_gp_SOURCES_DIR%\qtbase\configure.bat" call perl "%_GP_SOURCES_DIR%\init-repository"
rem "%_GP_SOURCES_DIR%\configure" -init-submodules
rem "%_GP_SOURCES_DIR%\configure" -init-submodules -submodules qtdeclarative
rem popd

echo GPerf-CLONE %_GP_VERSION% done
:gp_clone_done

rem if not exist "%_gp_SOURCES_DIR%\qtbase\configure.bat" echo error: QT-CLONE %_gp_VERSION% failed &set _gp_SOURCES_DIR=
if "%_GP_SOURCES_DIR%" neq "" cd /d "%_GP_SOURCES_DIR%"
