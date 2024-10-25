@echo off
set "_MAKER_ROOT=%~dp0"
rem https://doc.qt.io/qt-6/getting-sources-from-git.html
rem https://doc.qt.io/qt-6/configure-options.html
rem https://doc.qt.io/qt-6/build-sources.html
rem https://doc.qt.io/qt-6/windows-building.html
rem https://code.qt.io/cgit

set _QT_VERSION=6.6.3
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (set "_QT_VERSION=%~1" &shift &goto :param_loop)

rem (1) *** cloning QT sources ***
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
call "%_MAKER_ROOT%\clone_qt.bat" %_QT_VERSION%
if "%_QT_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if "%_QT_SOURCES_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)
if not exist "%_QT_SOURCES_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :EOF)

set "_QT_BUILD_DIR=%_QT_DIR%\qt_build_%_QT_VERSION%"
set "_QT_BIN_DIR=%_QT_DIR%\qt%_QT_VERSION%"

if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
)


rem (2) *** testing for existing build ***
rem if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
rem if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" goto :build_qt
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
echo error: QT %_QT_VERSION% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %_QT_VERSION%'
goto :EOF
:build_qt


rem (3) *** ensuring prerequisites ***

rem https://doc.qt.io/qt-6/windows-building.html
rem building Qt (libs and tools) requires:
rem
rem * mandatory: CMake 3.16 or newer
rem * mandatory: Python 3
rem * mandatory: MSVC2019 or MSVC2022 or Mingw-w64 13.1
rem              whatever compiler is used it has to be set up to create "amd64" targets
rem              for Mingw this means to add "...\mingw..._64\bin" to the PATH environment
rem * optional:  Ninja
rem * optional:  LLVM/Clang (for QDoc)  
rem              https://doc.qt.io/qt-6/qdoc-guide-clang.html
rem              https://github.com/qt-creator/qt-creator/blob/master/README.md#getting-llvmclang-for-the-clang-code-model
rem * optional:  Perl (for opus optimization)
rem * optional:  node.js 14 or newer (for QtWebEngine, QtPdf)  see: ...
rem * optional:  gRPC and Protobuf packages (for QtGRPC and QtProtobuf) 
rem              -> install gRPC and Protobuf via vcpkg: https://doc.qt.io/qt-6/qtprotobuf-installation-windows-vcpkg.html
rem                 ".\vcpkg.exe install grpc:x64-windows"
rem                 ".\vcpkg.exe install protobuf protobuf:x64-windows"
rem              -> build gRPC from source:     https://github.com/grpc/grpc/blob/v1.60.0/BUILDING.md#windows
rem              -> build Protobuf from source: https://github.com/protocolbuffers/protobuf/blob/main/cmake/README.md#windows-builds
rem 
rem -- Configuration summary shown below. It has also been written to D:/GIT/han/MakerProjects/Qt/qt_build_6.6.3/config.summary
rem -- Configure with --log-level=STATUS or higher to increase CMake's message verbosity. The log level does not persist across reconfigurations.
rem Note: Hunspell in Qt Virtual Keyboard is not enabled. Spelling correction will not be available.
rem WARNING: QDoc will not be compiled, probably because clang's C and C++ libraries could not be located. This means that you cannot build the Qt documentation.
rem You may need to set CMAKE_PREFIX_PATH or LLVM_INSTALL_DIR to the location of your llvm installation.
rem Other than clang's libraries, you may need to install another package, such as clang itself, to provide the ClangConfig.cmake file needed to detect your libraries. Once this
rem file is in place, the configure script may be able to detect your system-installed libraries without further environment variables.
rem On macOS, you can use Homebrew's llvm package.
rem You will also need to set the FEATURE_clang CMake variable to ON to re-evaluate this check.
rem WARNING: Clang-based lupdate parser will not be available. LLVM and Clang C++ libraries have not been found.
rem You will need to set the FEATURE_clangcpp CMake variable to ON to re-evaluate this check.
rem WARNING: QtWebEngine won't be built. node.js version 14 or later is required.
rem WARNING: QtPdf won't be built. node.js version 14 or later is required.
rem WARNING: No perl found, compiling opus without some optimizations.

echo.
echo rebuilding Qt %_QT_VERSION% from sources
echo see https://doc.qt.io/qt-6/windows-building.html
echo.
echo *** THIS REQUIRES VisualStudio 2019 or 2022 or Mingw-w64
echo *** THIS REQUIRES Python 3
echo *** THIS REQUIRES Cmake 3.16 or newer
echo *** OTPIONAL: Ninja
echo *** OTPIONAL: Perl
echo *** OTPIONAL: LLVM/Clang
echo *** OTPIONAL: Node.js
echo *** OTPIONAL: gRPC
echo *** OTPIONAL: Protobuf
echo.

rem validate msvs
set _MSVS_VER=
if "%VSCMD_VER:~0,2%" equ "16" (set "_MSVS_VER=2019" &goto :test_msvs_version_ok)
if "%VSCMD_VER:~0,2%" equ "17" (set "_MSVS_VER=2022" &goto :test_msvs_version_ok)
echo error: MSVS not available
goto :EOF
:test_msvs_version_ok
set _MSVS_TGT=x86
if /I "%VSCMD_ARG_TGT_ARCH%" equ "x64" (set "_MSVS_TGT=amd64" &goto :test_msvs_success)
echo warning: MSVS uses wrong target architecture %_MSVS_TGT% - switching to 'amd64'
call vsdevcmd -arch=amd64
if /I "%VSCMD_ARG_TGT_ARCH%" equ "x64" (set "_MSVS_TGT=amd64" &goto :test_msvs_success)
echo error: MSVS uses wrong target architecture %_MSVS_TGT%
:test_msvs_success
echo using: msvs %_MSVS_VER% (VS%VSCMD_VER:~0,2%) for %_MSVS_TGT%
set _MSVS_VER=
set _MSVS_TGT=

rem validate cmake
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: CMAKE is not available
goto :EOF
:test_cmake_success
set _VERSION_NR=
for /f "tokens=1-3 delims= " %%i in ('call cmake --version') do if /I "%%j" EQU "version" set "_VERSION_NR=%%k"
echo using: cmake %_VERSION_NR%
set _VERSION_NR=

rem validate ninja
call which ninja.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_ninja_success
echo warning: NINJA is not available
rem goto :EOF
:test_ninja_success
set _VERSION_NR=
for /f "tokens=1,* delims= " %%i in ('call ninja --version') do set "_VERSION_NR=%%i"
echo using: ninja %_VERSION_NR%
set _VERSION_NR=

rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
rem ...tbd
:test_llvm_success

rem validate node.js 
rem ...tbd
:test_nodejs_success

rem validate perl (for opus optimization) (also see QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call which perl.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_perl_success
echo warning: perl is not available
rem goto :EOF
:test_perl_success
set _VERSION_NR=
for /f "tokens=1,2 delims=^(" %%i in ('call perl --version') do for /f "tokens=1,* delims=)" %%k in ("%%j") do set "_VERSION_NR=%%k"
echo using: perl %_VERSION_NR%
set _VERSION_NR=

rem validate python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_available
echo error: python is not available
goto :EOF
:test_python_available
set _PYTHON_ARCH=x86
for /f %%i in ('call python -c "import sys;print(f""{sys.maxsize > 2**32}"")"') do if /I "%%~i" equ "True" set _PYTHON_ARCH=x64
if /I "%VSCMD_ARG_TGT_ARCH%" equ "%_PYTHON_ARCH%" goto :test_python_success
echo warning: python architecture '%_PYTHON_ARCH%' does not match msvs target architecture '%VSCMD_ARG_TGT_ARCH%'
rem goto :EOF
:test_python_success
set _VERSION_NR=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "_VERSION_NR=%%j"
echo using: python %_VERSION_NR% %_PYTHON_ARCH%
set _VERSION_NR=
set _PYTHON_ARCH=


rem (4) *** setup QT dependencies ***

rem setup gRPC
rem call "%_MAKER_ROOT%\build_grpc.bat x64-windows"
pushd "%_QT_DIR%"
call vcpkg install grpc:x64-windows
popd
rem setup Protobuf
rem call "%_MAKER_ROOT%\build_protobuf.bat x64-windows"
pushd "%_QT_DIR%"
call vcpkg install protobuf protobuf:x64-windows
popd
rem setup Python packages
rem       clarify: created a dedicated  python venv for configuring/building ?
call python -m pip install html5lib
rem call python -m pip wheel html5lib

rem (5) *** configure QT build ***
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE %_QT_VERSION%
rmdir /s /q "%_QT_BUILD_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
call "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info >"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
popd
:qt_configure_done

rem (6) *** perform QT build ***
:qt_build
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD %_QT_VERSION%
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel
popd
:qt_build_done

rem (7) *** perform QT install ***
:qt_install
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" (
  echo QT-INSTALL %_QT_VERSION%
  pushd "%_QT_BUILD_DIR%"
  call cmake --install .
  popd
  if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" echo error: QT-INSTALL %_QT_VERSION% FAILED&goto :qt_install_done
)
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT-INSTALL %_QT_VERSION% available &goto :qt_install_done
echo error: QT-INSTALL %_QT_VERSION% failed
goto :EOF
:qt_install_done


rem 5) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

cd "%_QT_DIR%"
