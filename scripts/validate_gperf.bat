@rem validate cmake:
@rem @call "%~dp0validate.bat" "CMAKE" "cmake --version" "for /f ""tokens=1-3 delims= "" %%%%i in ('call cmake --version') do if /I %%%%j EQU version echo %%%%k" %*
@echo off
call which tcmalloc_minimal.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo GPERF available &exit /b 0
echo error: GPERF validate failed
exit /b 1
