@rem validate cmake:
@rem @call "%~dp0validate.bat" "GPERF" "gperf --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call gperf --version') do if /I %%%%j EQU gperf echo %%%%k.0" %*
@call "%~dp0validate.bat" "GPERF" "gperf --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call gperf --version') do if /I %%%%j EQU gperf for /f ""tokens=1,* delims=-"" %%%%l in ('echo %%%%k') do echo %%%%l.%%%%m" %*
