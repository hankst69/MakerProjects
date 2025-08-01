@rem @call "%~dp0\core\generic_ensure.bat" QT %*
@rem @exit /b %ERRORLEVEL%
@echo off
call "%~dp0\build_qt.bat" %*
rem since there exists typically already a Qt installation in the path (e.g. from Anaconda) we have to go the long way
rem or maybe this has to move into build_qt.bat
rem call "%~dp0\core\generic_ensure.bat" QT %*
rem if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
if "%QT_BIN_DIR%" equ "" exit /b 0
set "_QT_TEST_TOOL=uic"
set "_QT_TEST_TOOL_NAME=uic"
call "%~dp0\core\generic_validate.bat" "QT" "%_QT_TEST_TOOL% --version" "for /f ""tokens=1,* delims= "" %%%%i in ('call %_QT_TEST_TOOL% --version') do if /I %%%%i EQU %_QT_TEST_TOOL_NAME% echo %%%%j" %* 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "path=%QT_BIN_DIR%\bin;%path%"
set _QT_TEST_TOOL=
set _QT_TEST_TOOL_NAME=
call "%~dp0\validate_qt.bat" %* --no_warnings
rem exit /b %ERRORLEVEL%
