@call "%~dp0core\generic_validate.bat" "QT" "uic.exe --version" "for /f ""tokens=1,* delims= "" %%%%i in ('call uic.exe --version') do if /I %%%%i EQU uic echo %%%%j" %*
@goto :EOF
@echo off
set "_QT_TEST_TOOL_NAME=uic"
set "_QT_TEST_TOOL=%QT_BIN_DIR%\bin\uic.exe"
call "%~dp0core\generic_validate.bat" "QT" "%_QT_TEST_TOOL% --version" "for /f ""tokens=1,* delims= "" %%%%i in ('call %_QT_TEST_TOOL% --version') do if /I %%%%i EQU %_QT_TEST_TOOL_NAME% echo %%%%j" 1>nul 2>nul
if %ERRORLEVEL% EQU 4 echo warning: QT not locally build - trying to find an installed version
if %ERRORLEVEL% EQU 4 set "_QT_TEST_TOOL=uic"
call "%~dp0core\generic_validate.bat" "QT" "%_QT_TEST_TOOL% --version" "for /f ""tokens=1,* delims= "" %%%%i in ('call %_QT_TEST_TOOL% --version') do if /I %%%%i EQU %_QT_TEST_TOOL_NAME% echo %%%%j" %*
set _QT_TEST_TOOL=
set _QT_TEST_TOOL_NAME=
