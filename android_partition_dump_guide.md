# Android Partition Dump Commands

# Инструкция по созданию и копированию образов разделов Android c Geely Cityray (Boyue Cool)

Этот файл содержит команды для создания полных образов системных разделов Android-устройства и их копирования на компьютер для анализа, резервного копирования или модификации.

## ⚠️ Предупреждения о безопасности

- **Требуется root-доступ** на устройстве
- **Процесс необратим** при неправильном использовании образов
- **Сохраните оригинальную прошивку** перед началом работы
- **Убедитесь в достаточном объёме свободного места** (до 15+ ГБ на устройстве)
- **Не прерывайте процесс** создания образов во избежание повреждения данных

## Требования

### На компьютере:
- Android Debug Bridge (ADB)
- Свободное место на диске (15-20 ГБ)
- USB-драйверы для вашего устройства

### На устройстве:
- Root-доступ (Magisk, SuperSU или аналог)
- Включённая отладка по USB
- Свободное место в `/storage/emulated/0/Downloads/` (15-20 ГБ)

## Пошаговая инструкция

### Подготовка

1. **Подключите устройство к компьютеру** через USB
2. **Проверьте соединение ADB:**
   ```bash
   adb devices
   ```
   Устройство должно отображаться в списке
3. **Войдите в оболочку устройства:**
   ```bash
   adb shell
   ```
4. **Получите root-права:**
   ```bash
   su
   ```

### Создание образов разделов

Выполните следующие команды **в root-оболочке устройства**. Команда `dd` копирует данные побайтово:
- `if=` - входной файл (раздел)
- `of=` - выходной файл (образ)
- `bs=` - размер блока
- `status=progress` - отображение прогресса

# 1/11 - System partition
```bash
dd if=/dev/block/system of=/storage/emulated/0/Downloads/system.img bs=4M status=progress
```
# 2/11 - DM-0
```bash
dd if=/dev/block/dm-0 of=/storage/emulated/0/Downloads/dm-0.img bs=4M status=progress
```
# 3/11 - DM-1
```bash
dd if=/dev/block/dm-1 of=/storage/emulated/0/Downloads/dm-1.img bs=4M status=progress
```
# 4/11 - Persist partition
```bash
dd if=/dev/block/persist of=/storage/emulated/0/Downloads/persist.img bs=1M status=progress
```
# 5/11 - Modem firmware
```bash
dd if=/dev/block/modem of=/storage/emulated/0/Downloads/modem.img bs=1M status=progress
```
# 6/11 - Bluetooth firmware
```bash
dd if=/dev/block/bluetooth of=/storage/emulated/0/Downloads/bluetooth.img bs=512K status=progress
```
# 7/11 - VDL partition
```bash
dd if=/dev/block/vdl of=/storage/emulated/0/Downloads/vdl.img bs=1M status=progress
```
# 8/11 - VDK partition
```bash
dd if=/dev/block/vdk of=/storage/emulated/0/Downloads/vdk.img bs=1M status=progress
```
# 9/11 - VDI partition
```bash
dd if=/dev/block/vdi of=/storage/emulated/0/Downloads/vdi.img bs=1M status=progress
```
# 10/11 - VDJ partition
```bash
dd if=/dev/block/vdj of=/storage/emulated/0/Downloads/vdj.img bs=1M status=progress
```
# 11/11 - Vendor partition
```bash
dd if=/dev/block/vendor of=/storage/emulated/0/Downloads/vendor.img bs=4M status=progress
```

### Копирование образов на компьютер

Выполните команды **в терминале компьютера** (выйдите из adb shell):

```bash
adb pull /storage/emulated/0/Downloads/system.img ./
adb pull /storage/emulated/0/Downloads/dm-0.img ./
adb pull /storage/emulated/0/Downloads/dm-1.img ./
adb pull /storage/emulated/0/Downloads/persist.img ./
adb pull /storage/emulated/0/Downloads/modem.img ./
adb pull /storage/emulated/0/Downloads/bluetooth.img ./
adb pull /storage/emulated/0/Downloads/vdl.img ./
adb pull /storage/emulated/0/Downloads/vdk.img ./
adb pull /storage/emulated/0/Downloads/vdi.img ./
adb pull /storage/emulated/0/Downloads/vdj.img ./
adb pull /storage/emulated/0/Downloads/vendor.img ./
```

## Очистка временных файлов

После успешного копирования удалите образы с устройства:

```bash
adb shell "rm /storage/emulated/0/Downloads/*.img"
```
