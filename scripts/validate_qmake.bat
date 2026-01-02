@call "%~dp0\core\generic_validate.bat" "QMAKE" "qmake --version" "for /f ""tokens=1,2,3,4,* delims= "" %%%%i in ('call qmake --version') do if /I %%%%j EQU Qt if /I %%%%k EQU version echo %%%%l" %*
