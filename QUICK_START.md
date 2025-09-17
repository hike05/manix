# 🚀 Quick Start Guide

Полное руководство по установке и использованию Nix Darwin на macOS.

## 📋 Предварительные требования

- **macOS 12.0+** (лучше 14.0+)
- **15GB свободного места** на диске
- **8GB RAM** (рекомендуется 16GB+)
- **Права администратора**
- **Интернет соединение**

## 🔍 Проверка совместимости

Перед установкой проверьте совместимость системы:

```bash
# Проверка всех требований
make check

# Быстрая проверка статуса
make status
```

## 🚀 Установка на чистую систему

### Вариант 1: Автоматическая установка

```bash
# Клонируйте репозиторий
git clone https://github.com/yourusername/nix-darwin-config.git
cd nix-darwin-config

# Запустите установку
make install
```

### Вариант 2: Пошаговая установка

```bash
# 1. Проверьте систему
./scripts/check-system.sh

# 2. Создайте backup (опционально)
./scripts/backup-restore.sh backup

# 3. Запустите установку
./scripts/install.sh

# 4. Перезапустите терминал
# Новый терминал будет иметь обновленное окружение
```

## 🎛️ Интерактивное управление

Запустите интерактивный менеджер для удобного управления:

```bash
make manager
```

Менеджер предоставляет:
- 📋 Проверку системы
- 🔧 Установку и обновление
- 💾 Backup и восстановление
- 🗑️ Обслуживание и удаление

## 📦 Повседневное использование

### Быстрые команды

```bash
# Обновить и пересобрать систему
make update

# Только пересобрать
make rebuild

# Создать backup
make backup

# Очистить старые данные
make clean

# Проверить статус
make status
```

### Традиционные команды

После установки доступны алиасы:

```bash
rebuild      # darwin-rebuild switch --flake ~/.config/nix
nix-update   # nix flake update && rebuild
nix-check    # nix flake check
```

## 🛠️ Кастомизация

### Редактирование конфигурации

```bash
# Откройте в редакторе
code ~/.config/nix

# Основные файлы для изменения:
# - darwin/homebrew.nix     (GUI приложения)
# - home/packages.nix       (CLI инструменты)
# - home/programs.nix       (настройки программ)
```

### Применение изменений

```bash
# После редактирования
make rebuild

# Или с обновлением зависимостей
make update
```

## 🔄 Среды разработки

### Использование шаблонов

```bash
# Node.js проект
mkdir my-project && cd my-project
nix flake init -t ~/.config/nix#nodejs
direnv allow

# Python проект
mkdir my-python-app && cd my-python-app
nix flake init -t ~/.config/nix#python
direnv allow
```

### Быстрые окружения

```bash
# Временное окружение с пакетами
nix shell nixpkgs#nodejs_20 nixpkgs#python3

# Постоянная установка
nix profile install nixpkgs#package-name
```

## 💾 Backup и восстановление

### Создание backup

```bash
# Быстрый backup
./scripts/backup-restore.sh backup

# Именованный backup
./scripts/backup-restore.sh backup --name "before-big-change"

# Полный backup (включая Nix store - очень большой)
./scripts/backup-restore.sh backup --full
```

### Восстановление

```bash
# Просмотр доступных backup'ов
./scripts/backup-restore.sh list

# Восстановление
./scripts/backup-restore.sh restore --backup "backup-name"

# Только конфигурация
./scripts/backup-restore.sh restore --backup "backup-name" --config-only

# Предварительный просмотр
./scripts/backup-restore.sh restore --backup "backup-name" --dry-run
```

## 🆘 Решение проблем

### Команды не найдены после установки

```bash
# Перезапустите терминал или обновите окружение
source /etc/zshrc

# Проверьте PATH
echo $PATH | grep nix
```

### Ошибки при сборке

```bash
# Очистите кэш и пересоберите
nix store gc
make rebuild
```

### Откат изменений

```bash
# Откат системы
sudo darwin-rebuild rollback

# Восстановление из backup
./scripts/backup-restore.sh restore --backup "last-known-good"
```

### Проблемы с правами

```bash
# Проверьте права на директории
ls -la ~/.config/nix
ls -la /nix

# Исправьте права (если нужно)
sudo chown -R $(whoami) ~/.config/nix
```

## 🗑️ Удаление

### Полное удаление системы

```bash
# Интерактивное удаление
./scripts/uninstall.sh

# Автоматическое удаление (осторожно!)
./scripts/uninstall.sh --force
```

### Частичное удаление

```bash
# Только очистка пакетов
nix-collect-garbage -d

# Удаление старых версий
nix-collect-garbage --delete-older-than 30d
```

## 📚 Дополнительные ресурсы

- 📖 [Полная документация](README.md)
- 🔧 [Руководство по установке](INSTALL.md)
- 🔄 [Обновление конфигурации](UPDATE_CONFIG.md)
- 🌐 [Официальная документация Nix](https://nixos.org/manual/nix/stable/)
- 🏠 [Home Manager Manual](https://nix-community.github.io/home-manager/)

## ⚡ Горячие клавиши и полезные команды

```bash
# Поиск пакетов
nix search nixpkgs python

# Информация о пакете
nix show-config

# Список установленных пакетов
nix profile list

# Обновление одного пакета
nix profile upgrade nixpkgs#package-name

# Просмотр зависимостей
nix-tree ~/.nix-profile

# Размер хранилища
du -sh /nix/store
```

---

💡 **Совет**: Начните с `make check`, затем `make install`, и используйте `make manager` для ежедневного управления!