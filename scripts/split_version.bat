@echo off
set VERSION_MAJOR=
set VERSION_MINOR=
set VERSION_PATCH=

set _SPLIT_TGT_VERSION=
set _SPLIT_NO_WARNINGS=
set _SPLIT_NO_ERRORS=
set _SPLIT_NO_INFO=
:param_loop
if /I "%~1" equ "--no_warnings" (set "_SPLIT_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_SPLIT_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_SPLIT_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_SPLIT_TGT_VERSION%" equ "" (set "_SPLIT_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""         (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_SPLIT_TGT_VERSION%" equ "" echo error 1: missing argument ^<tgt_version^>
if "%_SPLIT_TGT_VERSION%" equ "" exit /b 1

for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_MAJOR=%%~i
for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_MINOR=%%~j
for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_PATCH=%%~k

if "%VERSION_MAJOR%" neq "" goto :version_major_ok
if "%_SPLIT_NO_ERRORS%" equ "" echo error 2: MAJOR_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
exit /b 2
:version_major_ok
if "%VERSION_MINOR%" neq "" goto :version_minor_ok
if "%_SPLIT_NO_WARNINGS%" equ "" echo warning: MINOR_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
:version_minor_ok
if "%VERSION_PATCH%" neq "" goto :version_patch_ok
if "%_SPLIT_NO_WARNINGS%" equ "" echo warning: PATCH_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
:version_patch_ok

if "%_SPLIT_NO_INFO%" equ "" echo using: version %VERSION_MAJOR%.%VERSION_MINOR%.%VERSION_PATCH%
set _SPLIT_SPLIT_TGT_VERSION=
set _SPLIT_NO_WARNINGS=
set _SPLIT_NO_ERRORS=
set _SPLIT_NO_INFO=
exit /b 0
