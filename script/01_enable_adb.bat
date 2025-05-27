@echo off
setlocal enabledelayedexpansion

call config.bat

set ADB_COMMANDS_FILE=%COMMANDS_DIR%\adb_commands.txt

set MAX_PLINK_ATTEMPTS=5
set PLINK_ATTEMPT_DELAY_SEC=3
set "PLINK_SUCCESS=false"

echo Включение службы ADB на %ANDROID_DEVICE%...

for /l %%i in (1,1,%MAX_PLINK_ATTEMPTS%) do (
    echo Попытка %%i из %MAX_PLINK_ATTEMPTS%: Подключение к %ANDROID_DEVICE% через plink и установка свойств...
    %PLINK_BIN% -telnet %ANDROID_DEVICE% -batch -m %ADB_COMMANDS_FILE%

    if !errorlevel! equ 0 (
        echo Успешное подключение plink.
        set "PLINK_SUCCESS=true"
        goto end_plink_loop
    ) else (
        echo.
        echo Не удалось подключиться через plink
        if %%i equ %MAX_PLINK_ATTEMPTS% (
            echo Ошибка: Не удалось подключиться через plink после %MAX_PLINK_ATTEMPTS% попыток.
            exit /b 1
        ) else (
            echo Ожидание %PLINK_ATTEMPT_DELAY_SEC% секунд перед повторной попыткой...
            timeout /t %PLINK_ATTEMPT_DELAY_SEC% /nobreak > nul
        )
    )
)

:end_plink_loop

if "%PLINK_SUCCESS%" == "false" (
    echo Ошибка: Не удалось подключиться через plink после %MAX_PLINK_ATTEMPTS% попыток.
    exit /b 1
)

:: Ждем несколько секунд для применения настроек
echo Ожидание применения конфигурации ADB...
timeout /t 5 /nobreak > nul

echo Служба ADB включена.

pause
