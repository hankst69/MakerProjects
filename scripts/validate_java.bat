@rem set "PATH=C:\Program Files\Java\jdk1.8.0_66\bin;%PATH%"
@call "%~dp0core\generic_validate.bat" "JAVA" "java -version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call java -version') do if /I %%%%j EQU version echo %%%%k" %*
