@echo off

rem validate perl (for opus optimization) (also see QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
set PERL_VERSION=

call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo error: perl is not available
exit /b 1

:test_perl_success
set PERL_VERSION=
for /f "tokens=1,2 delims=^(" %%i in ('call perl --version') do for /f "tokens=1,* delims=)" %%k in ("%%j") do set "PERL_VERSION=%%k"
echo using: perl %PERL_VERSION%
exit /b 0