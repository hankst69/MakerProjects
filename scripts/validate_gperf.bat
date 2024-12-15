@rem validate cmake:
@call "%~dp0validate.bat" "GPERF" "tcmalloc_minimal_unittest --gtest_list_tests" "call echo 0.0.0" %*
@goto :EOF
@echo off
call which tcmalloc_minimal.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo GPERF available &exit /b 0
echo error: GPERF validate failed
exit /b 1
