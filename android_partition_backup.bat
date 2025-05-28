@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Режим отладки
:: Установите в 1 для отображения выполняемых команд
:: Установите в 0 для скрытия команд
set "DEBUG_MODE=0"

:: Цвета для вывода (отключены)
set "RED="
set "GREEN="
set "YELLOW="
set "BLUE="
set "MAGENTA="
set "CYAN="
set "WHITE="
set "RESET="

:: Конфигурация
set "DEVICE_PATH=/storage/emulated/0/Download"
set "LOG_FILE=partition_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

:: Массивы для разделов
set "PARTITIONS=system dm-0 dm-1 persist modem bluetooth vdl vdk vdi vdj vendor"

:: Статистика
set "TOTAL_PARTITIONS=0"
set "SUCCESS_COUNT=0"
set "FAILED_COUNT=0"
set "SKIPPED_COUNT=0"

:: Подсчёт общего количества разделов
for %%i in (%PARTITIONS%) do set /a TOTAL_PARTITIONS+=1

echo %CYAN%===============================================%RESET%
echo %CYAN%    Android Partition Backup Script v1.0    %RESET%
echo %CYAN%===============================================%RESET%
echo.

:: Создание лог-файла
echo [%date% %time%] Starting Android Partition Backup > "%LOG_FILE%"

:MAIN_MENU
echo Выберите режим работы:
echo 1. Автоматическое копирование всех разделов
echo 2. Интерактивный выбор разделов
echo 3. Проверка соединения с устройством
echo 4. Очистка временных файлов на устройстве
echo 5. Выход
echo.
set /p "choice=Введите номер опции: "

if "%choice%"=="1" goto AUTO_MODE
if "%choice%"=="2" goto INTERACTIVE_MODE
if "%choice%"=="3" goto CHECK_DEVICE
if "%choice%"=="4" goto CLEANUP_DEVICE
if "%choice%"=="5" goto END
echo %RED%Неверный выбор!%RESET%
pause
cls
goto MAIN_MENU

:CHECK_DEVICE
echo %BLUE%Проверка подключения устройства...%RESET%
if "%DEBUG_MODE%"=="1" echo adb devices
adb devices 2>nul | findstr /r "device$" >nul
if errorlevel 1 (
    echo %RED%❌ Устройство не найдено или ADB не установлен!%RESET%
    echo [%date% %time%] Device check failed >> "%LOG_FILE%"
) else (
    echo %GREEN%✅ Устройство подключено%RESET%
    echo [%date% %time%] Device connected successfully >> "%LOG_FILE%"
)
pause
cls
goto MAIN_MENU

:AUTO_MODE
echo %BLUE%Запуск автоматического режима...%RESET%
echo [%date% %time%] Starting automatic mode >> "%LOG_FILE%"

@REM call :CHECK_ROOT_ACCESS
@REM if errorlevel 1 goto MAIN_MENU

set "partition_index=0"
for %%p in (%PARTITIONS%) do (
    set /a partition_index+=1
    call :PROCESS_PARTITION "%%p" !partition_index!
)

call :SHOW_STATISTICS
pause
cls
goto MAIN_MENU

:INTERACTIVE_MODE
echo %BLUE%Интерактивный режим выбора разделов%RESET%
echo [%date% %time%] Starting interactive mode >> "%LOG_FILE%"

@REM call :CHECK_ROOT_ACCESS
@REM if errorlevel 1 goto MAIN_MENU

echo Доступные разделы:
set "partition_index=0"
for %%p in (%PARTITIONS%) do (
    set /a partition_index+=1
    echo %WHITE%!partition_index!.%RESET% %%p
)
echo.
echo Введите номера разделов через пробел (например: 1 3 5) или 'all' для всех:
set /p "selected_partitions=Ваш выбор: "

if /i "%selected_partitions%"=="all" (
    set "partition_index=0"
    for %%p in (%PARTITIONS%) do (
        set /a partition_index+=1
        call :PROCESS_PARTITION "%%p" !partition_index!
    )
) else (
    for %%i in (%selected_partitions%) do (
        call :GET_PARTITION_BY_INDEX %%i
    )
)

call :SHOW_STATISTICS
pause
cls
goto MAIN_MENU

:GET_PARTITION_BY_INDEX
set "target_index=%1"
set "current_index=0"
for %%p in (%PARTITIONS%) do (
    set /a current_index+=1
    if !current_index!==!target_index! (
        call :PROCESS_PARTITION "%%p" !current_index!
        goto :eof
    )
)
echo %RED%❌ Неверный номер раздела: %target_index%%RESET%
goto :eof

:PROCESS_PARTITION
set "partition_name=%~1"
set "partition_index=%2"

echo.
echo %MAGENTA%[%partition_index%/%TOTAL_PARTITIONS%] Обработка раздела: %partition_name%%RESET%
echo [%date% %time%] Processing partition: %partition_name% >> "%LOG_FILE%"

call :GET_PARTITION_INFO "%partition_name%" "%partition_index%"

echo %CYAN%  → Создание образа на устройстве...%RESET%
call :CREATE_IMAGE "%partition_name%"
if errorlevel 1 (
    echo %RED%  ❌ Ошибка создания образа%RESET%
    echo [%date% %time%] Failed to create image for %partition_name% >> "%LOG_FILE%"
    set /a FAILED_COUNT+=1
    goto :eof
)

echo %CYAN%  → Копирование на компьютер...%RESET%
call :PULL_IMAGE "%partition_name%"
if errorlevel 1 (
    echo %RED%  ❌ Ошибка копирования%RESET%
    echo [%date% %time%] Failed to pull %partition_name% >> "%LOG_FILE%"
    set /a FAILED_COUNT+=1
) else (
    echo %GREEN%  ✅ Успешно скопирован%RESET%
    echo [%date% %time%] Successfully processed %partition_name% >> "%LOG_FILE%"
    set /a SUCCESS_COUNT+=1
)

echo %CYAN%  → Удаление временного файла...%RESET%
call :CLEANUP_TEMP_FILE "%partition_name%"

goto :eof

:GET_PARTITION_INFO
set "target_partition=%~1"
set "target_index=%2"
set "partition_path=/dev/block/%target_partition%"
goto :eof

:CREATE_IMAGE
set "partition_name=%~1"
set "source_path=/dev/block/%partition_name%"
set "target_file=%DEVICE_PATH%/%partition_name%.img"
set "block_size=4M"

if "%DEBUG_MODE%"=="1" echo adb shell "su -c 'dd if=%source_path% of=%target_file% bs=%block_size%'"
adb shell "su -c 'dd if=%source_path% of=%target_file% bs=%block_size%'" 2>nul
if errorlevel 1 exit /b 1
exit /b 0

:PULL_IMAGE
set "partition_name=%~1"
set "source_file=%DEVICE_PATH%/%partition_name%.img"

if "%DEBUG_MODE%"=="1" echo adb pull "%source_file%" "./"
adb pull "%source_file%" "./" 2>nul
if errorlevel 1 exit /b 1
exit /b 0

:CLEANUP_TEMP_FILE
set "partition_name=%~1"
set "temp_file=%DEVICE_PATH%/%partition_name%.img"

adb shell "rm %temp_file%" 2>nul
goto :eof

:CHECK_ROOT_ACCESS
echo %BLUE%Проверка root-доступа...%RESET%
if "%DEBUG_MODE%"=="1" echo adb shell "su -c 'id'"
adb shell "su -c 'id'" 2>nul | findstr "uid=0" >nul
if errorlevel 1 (
    echo %RED%❌ Нет root-доступа или устройство не подключено!%RESET%
    echo [%date% %time%] Root access check failed >> "%LOG_FILE%"
    pause
    exit /b 1
)
echo %GREEN%✅ Root-доступ подтверждён%RESET%
echo [%date% %time%] Root access confirmed >> "%LOG_FILE%"
exit /b 0

:CLEANUP_DEVICE
echo %BLUE%Очистка временных файлов на устройстве...%RESET%
if "%DEBUG_MODE%"=="1" echo adb shell "rm %DEVICE_PATH%/*.img"
adb shell "rm %DEVICE_PATH%/*.img" 2>nul
if errorlevel 1 (
    echo %YELLOW%⚠️ Возможно, файлы уже удалены или отсутствуют%RESET%
) else (
    echo %GREEN%✅ Временные файлы удалены%RESET%
)
echo [%date% %time%] Device cleanup completed >> "%LOG_FILE%"
pause
cls
goto MAIN_MENU

:SHOW_STATISTICS
echo.
echo %CYAN%================= СТАТИСТИКА =================%RESET%
echo %WHITE%Всего разделов:%RESET% %TOTAL_PARTITIONS%
echo %GREEN%Успешно обработано:%RESET% %SUCCESS_COUNT%
echo %RED%Ошибок:%RESET% %FAILED_COUNT%
echo %YELLOW%Пропущено:%RESET% %SKIPPED_COUNT%
if %SUCCESS_COUNT% gtr 0 (
    echo %GREEN%✅ Созданные образы сохранены в текущей папке%RESET%
)
if %FAILED_COUNT% gtr 0 (
    echo %RED%❌ Проверьте лог-файл для деталей: %LOG_FILE%%RESET%
)
echo %CYAN%=============================================%RESET%
echo [%date% %time%] Statistics - Total: %TOTAL_PARTITIONS%, Success: %SUCCESS_COUNT%, Failed: %FAILED_COUNT% >> "%LOG_FILE%"
goto :eof

:END
echo %GREEN%Работа завершена. Лог сохранён в: %LOG_FILE%%RESET%
echo [%date% %time%] Script finished >> "%LOG_FILE%"
pause
exit /b 0
