@echo off
call "%~dp0\maker_env.bat"

:_msvs_available
call "%MAKER_SCRIPTS%\validate_python.bat" 1>nul
if "%ERRORLEVEL%" equ "0" goto :_python_available
echo error: PYTHON not available
exit /b 1

:_python_available
rem ensure msvs available and matches
call "%MAKER_SCRIPTS%\ensure_msvs.bat" "%PYTHON_ARCHITECTURE%" 1>nul
if "%ERRORLEVEL%" equ "0" goto :_msvs_matches_python
echo error: MSVS not available or incompatible
exit /b 2

:_msvs_matches_python
echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%  (matching python %PYTHON_VERSION% %PYTHON_ARCHITECTURE%)
exit /b 0
