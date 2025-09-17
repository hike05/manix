# 🔧 Завершение установки nix-darwin

Система была собрана, но активация требует интерактивного sudo.

## Запустите эту команду в терминале:

```bash
cd ~/.config/nix
sudo ./result/sw/bin/darwin-rebuild switch --flake .
```

После успешной активации вы увидите:
- `/run/current-system` симлинк
- `darwin-rebuild` в PATH
- Обновленный `/etc/zshrc` с Nix настройками

## Проверка установки:

```bash
# Перезапустите терминал или выполните:
source /etc/zshrc

# Проверьте команды:
which darwin-rebuild
which home-manager

# Посмотрите системную информацию:
darwin-version
```

## После установки:

1. ✅ Перезапустите терминал
2. ✅ Запустите `darwin-rebuild switch --flake ~/.config/nix` для применения изменений  
3. ✅ Homebrew будет настроен автоматически
4. ✅ Home-manager активируется с пользовательскими настройками

## В случае проблем:

```bash
# Откат к предыдущей версии:
sudo darwin-rebuild rollback

# Проверка логов:
tail -f /var/log/system.log
```