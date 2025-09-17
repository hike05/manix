# 🔄 Обновление конфигурации

## Перемещение в правильное место

Конфигурация была создана в `~/.config/nix`, но теперь находится в этом репозитории.

### Шаги для активации:

1. **Создать симлинк для удобства:**
   ```bash
   ln -sf $(pwd) ~/.config/nix-repo
   ```

2. **Обновить конфигурацию nix-darwin:**
   ```bash
   # Если уже была активация из ~/.config/nix:
   sudo darwin-rebuild switch --flake $(pwd)
   
   # Если первая установка:
   sudo ./result/sw/bin/darwin-rebuild switch --flake $(pwd)
   ```

3. **Обновить алиас rebuild в shell:**
   ```bash
   # Добавить в ~/.zshrc:
   alias rebuild="darwin-rebuild switch --flake /Users/maxime/Projects/manix"
   ```

### Альтернативный вариант - переместить в ~/.config/nix:

```bash
# Удалить старую конфигурацию
rm -rf ~/.config/nix

# Переместить репозиторий
mv /Users/maxime/Projects/manix ~/.config/nix

# Создать симлинк в Projects для удобства разработки
ln -s ~/.config/nix /Users/maxime/Projects/nix-darwin-config
```

## Рекомендация

Для production использования лучше переместить в `~/.config/nix`, так как это стандартное место для конфигураций Nix Darwin.