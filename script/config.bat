@echo off
@chcp 65001 > nul

set SCRIPT_DIR=%~dp0
for %%i in ("%SCRIPT_DIR%..") do set PROJECT_ROOT=%%~fi

set ANDROID_DEVICE=android.local
set COMMANDS_DIR=%PROJECT_ROOT%\script\commands
set BIN_DIR=%PROJECT_ROOT%\bin
set APKS_DIR=%PROJECT_ROOT%\apks

set PLINK_BIN=%BIN_DIR%\plink.exe
