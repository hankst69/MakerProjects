@rem https://doc.qt.io/qt-6/getting-sources-from-git.html
@rem https://doc.qt.io/qt-6/configure-options.html
@rem https://doc.qt.io/qt-6/build-sources.html
@rem https://doc.qt.io/qt-6/windows-building.html
@rem https://code.qt.io/cgit
@echo off
call "%~dp0\maker_env.bat"
set "_BQT_START_DIR=%cd%"

set _QT_VERSION=6.6.3
set _REBUILD=
:param_loop
if /I "%~1" equ "--rebuild" (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"        (set "_REBUILD=true" &shift &goto :param_loop)
if "%~1" neq ""             (set "_QT_VERSION=%~1" &shift &goto :param_loop)


rem (1) *** cloning QT sources ***
call "%MAKER_ROOT%\clone_qt.bat" %_QT_VERSION%
rem defines: _QT_DIR
rem defines: _QT_SOURCES_DIR
if "%_QT_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if "%_QT_SOURCES_DIR%" EQU "" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)
if not exist "%_QT_SOURCES_DIR%" (echo cloning Qt %_QT_VERSION% failed &goto :Exit)

set "_QT_BUILD_DIR=%_QT_DIR%\qt_build_%_QT_VERSION%"
set "_QT_BIN_DIR=%_QT_DIR%\qt%_QT_VERSION%"


rem (2) *** cleaning QT build if demanded ***
if "%_REBUILD%" equ "true" (
  echo preparing rebuild...
  rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul
  rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
)


rem (3) *** testing for existing QT build ***
if not exist "%_QT_BIN_DIR%\bin\Qt6WebSockets.dll" goto :build_qt
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
set "PATH=%PATH%;%_QT_BIN_DIR%\bin"
call which Qt6WebSockets.dll 1>nul 2>nul
if %ERRORLEVEL% EQU 0 echo QT %_QT_VERSION% already available&goto :qt_install_done
echo error: QT %_QT_VERSION% seems to be prebuild but is not working
echo try rebuilding via '%~n0 --rebuild %_QT_VERSION%'
goto :Exit
:build_qt


rem (4) *** ensuring prerequisites ***

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

rem ensure msvs version and amd64 target architecture
call "%MAKER_SCRIPTS%\ensure_msvs.bat" GEQ2019 amd64
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate cmake
call "%MAKER_SCRIPTS%\validate_cmake.bat" GEQ3.16
if %ERRORLEVEL% NEQ 0 (
  goto :Exit
)
rem validate ninja
call "%MAKER_SCRIPTS%\validate_ninja.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NINJA is not available
  rem goto :Exit
)
rem validate llvm (set LLVM_INSTALL_DIR + need to set the FEATURE_clang and FEATURE_clangcpp CMake variable to ON to re-evaluate this checks)
call "%MAKER_SCRIPTS%\validate_llvm.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: LLVM CLANG is not available
  call "%MAKER_ROOT%\build_llvm.bat"
  call "%MAKER_SCRIPTS%\validate_llvm.bat"
  if %ERRORLEVEL% NEQ 0 (
    goto :Exit
  )
)
rem validate node.js 
call "%MAKER_SCRIPTS%\validate_nodejs.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: NODE.JS is not available
  rem goto :Exit
)
rem validate perl (for opus optimization) (also see QNX/gperf see https://github.com/gperftools/gperftools/issues/1429)
call "%MAKER_SCRIPTS%\validate_perl.bat" --no_errors
if %ERRORLEVEL% NEQ 0 (
  echo warning: PERL is not available
  rem goto :Exit
)
rem validate python
call "%MAKER_SCRIPTS%\validate_python.bat" 3 "%MSVS_TARGET_ARCHITECTURE%"
if %ERRORLEVEL% NEQ 0 goto :Exit
if /I "%PYTHON_ARCHITECTURE%" neq "%MSVS_TARGET_ARCHITECTURE%" (
  echo warning: python architecture '%PYTHON_ARCHITECTURE%' does not match msvs target architecture '%MSVS_TARGET_ARCHITECTURE%'
)


rem (5) *** setup QT dependencies ***

rem setup gRPC
rem call "%MAKER_ROOT%\build_grpc.bat" x64-windows
  rem pushd "%_QT_DIR%"
  rem call vcpkg install grpc:x64-windows
  rem popd
rem setup Protobuf
rem call "%MAKER_ROOT%\build_protobuf.bat" x64-windows
  rem pushd "%_QT_DIR%"
  rem call vcpkg install protobuf protobuf:x64-windows
  rem popd
rem setup Python packages
rem       clarify: created a dedicated  python venv for configuring/building ?
call python -m pip install html5lib
rem call python -m pip wheel html5lib


rem (6) *** configure QT build ***
:qt_configure
if exist "%_QT_BUILD_DIR%\qtbase\bin\qt-cmake.bat" echo QT-CONFIGURE %_QT_VERSION% already done &goto :qt_configure_done
echo QT-CONFIGURE %_QT_VERSION%
rmdir /s /q "%_QT_BUILD_DIR%" 1>nul 2>nul
rmdir /s /q "%_QT_BIN_DIR%" 1>nul 2>nul 
mkdir "%_QT_BIN_DIR%"
mkdir "%_QT_BUILD_DIR%"
pushd "%_QT_BUILD_DIR%"
call "%_QT_SOURCES_DIR%\configure.bat" -prefix "%_QT_BIN_DIR%" -release -force-debug-info -separate-debug-info >"%_QT_DIR%\qt_build_%_QT_VERSION%_configure.log"
popd
:qt_configure_done

rem (7) *** perform QT build ***
:qt_build
if exist "%_QT_BIN_DIR%\bin\designer.exe" echo QT-BUILD %_QT_VERSION% already done &goto :qt_build_done
echo QT-BUILD %_QT_VERSION%
pushd "%_QT_BUILD_DIR%"
call cmake --build . --parallel
popd
:qt_build_done

rem (8) *** perform QT install ***
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
goto :Exit
:qt_install_done
rem -- create shortcuts
echo @start /D "%_QT_BIN_DIR%\bin" /MAX /B %_QT_BIN_DIR%\bin\designer.exe %%*>"%MAKER_BIN%\qtdesigner.bat"


rem (9) post configure QT
rem call "_QT_BIN_DIR%/bin/qt-configure-module.bat"

:Exit
cd /d "%_QT_DIR%"
cd /d "%_BQT_START_DIR%"
set _BQT_START_DIR=
set _REBUILD=
rem set _QT_VERSION=
rem set _QT_DIR=
rem set _QT_SOURCES_DIR=
rem set _QT_BUILD_DIR=
rem set _QT_BIN_DIR=
