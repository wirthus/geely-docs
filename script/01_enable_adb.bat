@echo off
setlocal enabledelayedexpansion

call config.bat

set ADB_COMMANDS_FILE=%COMMANDS_DIR%\adb_commands.txt

echo Включение службы ADB на %ANDROID_DEVICE%...

echo Подключение к %ANDROID_DEVICE% через plink и установка свойств...
%PLINK_BIN% -telnet %ANDROID_DEVICE% -batch -m %ADB_COMMANDS_FILE%

:: Ждем несколько секунд для применения настроек
echo Ожидание применения конфигурации ADB...
timeout /t 5 /nobreak > nul

echo Служба ADB включена.

pause
