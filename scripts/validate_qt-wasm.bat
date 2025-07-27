@echo off
set "_QTW_TEST_TOOL=qmake"
call "%~dp0\core\generic_validate.bat" "QTW" "%_QTW_TEST_TOOL% --version" "for /f ""tokens=1,2,3,4,* delims= "" %%%%i in ('call %_QTW_TEST_TOOL% --version') do if /I %%%%j EQU Qt if /I %%%%k EQU version echo %%%%l" %*
rem echo %ERRORLEVEL%
set _QTW_TEST_TOOL=
rem echo %ERRORLEVEL%
