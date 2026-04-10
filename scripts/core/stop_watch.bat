@echo off

:stop_watch
set "_START_DATETIME=%~1"
set _DATE_=
set _TIME_=
set _DATETIME_=
set _DATE_UI=
set _TIME_UI=
set _DATE_YY=
set _DATE_MM=
set _DATE_DD=
set _TIME_HH=
set _TIME_MM=
set _TIME_SS=
set _TIME_MS=
for /f "tokens=2 delims=:" %%i in ('echo.^|date') do set "_DATE_=%%~i" &goto :stop_watch_next
:stop_watch_next
if "%_DATE_:~0,1%" equ " " set "_DATE_=%_DATE_:~1%"
if "%_DATE_:~-1%" equ " " set "_DATE_=%_DATE_:~0,-1%"
set _DATE_PT1=
set _DATE_PT2=
for /f "tokens=1,* delims= " %%i in ("%_DATE_%") do (set "_DATE_PT1=%%i" &set "_DATE_PT2=%%j")
if "%_DATE_PT2%" neq "" set "_DATE_=%_DATE_PT2%"
for /f "tokens=1,2,3 delims=/" %%i in ("%_DATE_%") do (set "_DATE_DD=%%i" &set "_DATE_MM=%%j" &set "_DATE_YY=%%k")
for /f "tokens=2,3,4 delims=:" %%i in ('echo.^|time') do if "%%j" neq "" (set "_TIME_HH=%%i" &set "_TIME_MM=%%j" &set "_TIME_SS=%%k")
set "_TIME_HH=%_TIME_HH: =%"
set "_TIME_MM=%_TIME_MM: =%"
for /f "tokens=1,2 delims=." %%i in ("%_TIME_SS%") do (set "_TIME_SS=%%i" &set "_TIME_MS=%%j")
set "_TIME_SS=%_TIME_SS: =%"
set "_TIME_MS=%_TIME_MS: =%"
set "_DATE_UI=%_DATE_%"
set "_DATE_=%_DATE_YY%-%_DATE_MM%-%_DATE_DD%"
set "_TIME_UI=%_TIME_HH%:%_TIME_MM%:%_TIME_SS%"
set "_TIME_=%_TIME_HH%-%_TIME_MM%-%_TIME_SS%.%_TIME_MS%"
set "_DATETIME_=%_DATE_%_%_TIME_%"
if "%_START_DATETIME%" equ "" goto :EOF
set _STARTT_HH=
set _STARTT_MM=
set _STARTT_SS=
set _STARTT_MS=
set _DIFFT_HH=
set _DIFFT_MM=
set _DIFFT_SS=
set _DIFFT_MS=
set _DIFFT_=
set _START_DATE=
set _START_TIME=
for /f "tokens=1,2 delims=_" %%i in ("%_START_DATETIME%") do (set "_START_DATE=%%i" &set "_START_TIME=%%j")
if "%_START_TIME%" equ "" set "_START_TIME=%_START_DATE%"
for /f "tokens=1,2,3 delims=-" %%i in ("%_START_TIME%") do (set "_STARTT_HH=%%i" &set "_STARTT_MM=%%j" &set "_STARTT_SS=%%k")
for /f "tokens=1,2 delims=." %%i in ("%_STARTT_SS%") do (set "_STARTT_SS=%%i" &set "_STARTT_MS=%%j")
if "%_STARTT_HH:~0,1%" equ "0" set "_STARTT_HH=%_STARTT_HH:~1%"
if "%_STARTT_MM:~0,1%" equ "0" set "_STARTT_MM=%_STARTT_MM:~1%"
if "%_STARTT_SS:~0,1%" equ "0" set "_STARTT_SS=%_STARTT_SS:~1%"
set "_STOPT_HH=%_TIME_HH%"
set "_STOPT_MM=%_TIME_MM%"
set "_STOPT_SS=%_TIME_SS%"
if "%_STOPT_HH:~0,1%" equ "0" set "_STOPT_HH=%_STOPT_HH:~1%"
if "%_STOPT_MM:~0,1%" equ "0" set "_STOPT_MM=%_STOPT_MM:~1%"
if "%_STOPT_SS:~0,1%" equ "0" set "_STOPT_SS=%_STOPT_SS:~1%"
set /a _DIFFT_HH=%_STOPT_HH%-%_STARTT_HH%
set /a _DIFFT_MM=%_STOPT_MM%-%_STARTT_MM%
set /a _DIFFT_SS=%_STOPT_SS%-%_STARTT_SS%
if "%_STARTT_MS%" neq "" set /a _DIFFT_MS=%_TIME_MS%-%_STARTT_MS%
set "_DIFFT_=%_DIFFT_HH%:%_DIFFT_MM%:%_DIFFT_SS%"
set /a _DIFFTD_HSS=%_DIFFT_HH%*3600
set /a _DIFFTD_MSS=%_DIFFT_MM%*60
set /a _DIFFT_DUR_SS=%_DIFFTD_HSS%+%_DIFFTD_MSS%
set /a _DIFFT_DUR_SS=%_DIFFT_DUR_SS%+%_DIFFT_SS%
goto :EOF
