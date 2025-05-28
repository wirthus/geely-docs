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
- Свободное место в `/storage/emulated/0/Download/` (15-20 ГБ)

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
dd if=/dev/block/system of=/storage/emulated/0/Download/system.img bs=4M
```
# 2/11 - DM-0
```bash
dd if=/dev/block/dm-0 of=/storage/emulated/0/Download/dm-0.img bs=4M
```
# 3/11 - DM-1
```bash
dd if=/dev/block/dm-1 of=/storage/emulated/0/Download/dm-1.img bs=4M
```
# 4/11 - Persist partition
```bash
dd if=/dev/block/persist of=/storage/emulated/0/Download/persist.img bs=4M
```
# 5/11 - Modem partition
```bash
dd if=/dev/block/modem of=/storage/emulated/0/Download/modem.img bs=4M
```
# 6/11 - Bluetooth partition
```bash
dd if=/dev/block/bluetooth of=/storage/emulated/0/Download/bluetooth.img bs=4M
```
# 7/11 - VDL partition
```bash
dd if=/dev/block/vdl of=/storage/emulated/0/Download/vdl.img bs=4M
```
# 8/11 - VDK partition
```bash
dd if=/dev/block/vdk of=/storage/emulated/0/Download/vdk.img bs=4M
```
# 9/11 - VDI partition
```bash
dd if=/dev/block/vdi of=/storage/emulated/0/Download/vdi.img bs=4M
```
# 10/11 - VDJ partition
```bash
dd if=/dev/block/vdj of=/storage/emulated/0/Download/vdj.img bs=4M
```
# 11/11 - Vendor partition
```bash
dd if=/dev/block/vendor of=/storage/emulated/0/Download/vendor.img bs=4M
```

### Копирование образов на компьютер

Выполните команды **в терминале компьютера** (выйдите из adb shell или откройте новое окно):

```bash
adb pull /storage/emulated/0/Download/system.img ./
adb pull /storage/emulated/0/Download/dm-0.img ./
adb pull /storage/emulated/0/Download/dm-1.img ./
adb pull /storage/emulated/0/Download/persist.img ./
adb pull /storage/emulated/0/Download/modem.img ./
adb pull /storage/emulated/0/Download/bluetooth.img ./
adb pull /storage/emulated/0/Download/vdl.img ./
adb pull /storage/emulated/0/Download/vdk.img ./
adb pull /storage/emulated/0/Download/vdi.img ./
adb pull /storage/emulated/0/Download/vdj.img ./
adb pull /storage/emulated/0/Download/vendor.img ./
```

## Очистка временных файлов

После успешного копирования удалите образы с устройства:

```bash
adb shell "rm /storage/emulated/0/Download/*.img"
```
