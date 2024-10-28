@echo off
set "_TOOLS_DIR=%~dp0tools"
if not exist "%_TOOLS_DIR%\Emsdk" if not exist "%_TOOLS_DIR%\Choco" if not exist "%_TOOLS_DIR%\Qt" if not exist "%_TOOLS_DIR%\VESC" (
  echo nothing to clean
  goto :EOF
)
echo.
echo ...about to delete cloned sources and build outputs of:
if exist "%_TOOLS_DIR%\Emsdk" (
  echo.
  echo %_TOOLS_DIR%\Emsdk
  dir /b "%_TOOLS_DIR%\Emsdk"
)
if exist "%_TOOLS_DIR%\Choco" (
  echo.
  echo %_TOOLS_DIR%\Choco
  dir /b "%_TOOLS_DIR%\Choco"
)
if exist "%_TOOLS_DIR%\Qt" (
  echo.
  echo %_TOOLS_DIR%\Qt
  dir /b "%_TOOLS_DIR%\Qt"
)
if exist "%_TOOLS_DIR%\VESC" (
  echo.
  echo %_TOOLS_DIR%\VESC
  dir /b "%_TOOLS_DIR%\VESC"
)
echo.
if exist "%_TOOLS_DIR%\Emsdk" (
  echo.
  echo ...about to delete '%_TOOLS_DIR%\Emsdk'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%_TOOLS_DIR%\Emsdk"
)
if exist "%_TOOLS_DIR%\Choco" (
  echo.
  echo ...about to delete '%_TOOLS_DIR%\Choco'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%_TOOLS_DIR%\Choco"
)
if exist "%_TOOLS_DIR%\Qt" (
  echo.
  echo ...about to delete '%_TOOLS_DIR%\Qt'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%_TOOLS_DIR%\Qt"
)
if exist "%_TOOLS_DIR%\VESC" (
  echo.
  echo ...about to delete '%_TOOLS_DIR%\VESC'
  echo abort with Ctrl-C ^(any other key to continue^)
  pause
  echo.
  rmdir /s /q "%_TOOLS_DIR%\VESC"
)
