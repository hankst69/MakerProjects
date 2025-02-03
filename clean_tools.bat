@for /f "tokens=*" %%i in (%0) do @echo %%i
@goto :EOF

@echo off
call "%~dp0\maker_env.bat"

if not exist "%MAKER_TOOLS%\Emsdk" if not exist "%MAKER_TOOLS%\Choco" if not exist "%MAKER_TOOLS%\Qt" if not exist "%MAKER_TOOLS%\VESC" (
  echo nothing to clean
  goto :EOF
)
echo.
echo ...about to delete cloned sources and build outputs of:
if exist "%MAKER_TOOLS%\Emsdk" (
  echo.
  echo %MAKER_TOOLS%\Emsdk
  dir /b "%MAKER_TOOLS%\Emsdk"
)
if exist "%MAKER_TOOLS%\Choco" (
  echo.
  echo %MAKER_TOOLS%\Choco
  dir /b "%MAKER_TOOLS%\Choco"
)
if exist "%MAKER_TOOLS%\Qt" (
  echo.
  echo %MAKER_TOOLS%\Qt
  dir /b "%MAKER_TOOLS%\Qt"
)
if exist "%MAKER_TOOLS%\VESC" (
  echo.
  echo %MAKER_TOOLS%\VESC
  dir /b "%MAKER_TOOLS%\VESC"
)
echo.
if exist "%MAKER_TOOLS%\Emsdk" (
  echo.
  echo ...about to delete '%MAKER_TOOLS%\Emsdk'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_TOOLS%\Emsdk"
)
if exist "%MAKER_TOOLS%\Choco" (
  echo.
  echo ...about to delete '%MAKER_TOOLS%\Choco'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_TOOLS%\Choco"
)
if exist "%MAKER_TOOLS%\Qt" (
  echo.
  echo ...about to delete '%MAKER_TOOLS%\Qt'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_TOOLS%\Qt"
)
if exist "%MAKER_TOOLS%\VESC" (
  echo.
  echo ...about to delete '%MAKER_TOOLS%\VESC'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%MAKER_TOOLS%\VESC"
)
