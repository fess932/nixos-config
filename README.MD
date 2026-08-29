# nixos-config

Конфигурация NixOS + home-manager для хоста `nixos`.

```
flake.nix              входная точка: инпуты, оверлеи, сборка хоста
hosts/nixos/           всё, что уникально для этой машины
modules/nixos/         системные модули (переиспользуемые)
modules/home/          пользовательские модули (home-manager)
home/default.nix       точка входа home-manager
pkgs/                  собственные пакеты -> pkgs.local.*
config/                сырые конфиги приложений (nvim, rofi, wezterm, ...)
docs/GUIDE.md          как всё это правильно менять  <- начни отсюда
```

## Команды

```sh
make            # = make switch, применить конфиг
make build      # собрать, не применяя
make diff       # показать, что изменится относительно текущей системы
make update     # обновить все flake-инпуты и применить
make rollback   # откатиться на предыдущее поколение
make fmt        # отформатировать все .nix
make help       # список целей
```

> Nix читает только файлы, отслеживаемые git. Новый `.nix` без `git add`
> для флейка не существует — цели Makefile делают `git add -A` сами.

## Конфиги приложений

Настройки живут двумя способами:

1. **Нативные опции home-manager** — `programs.git`, `programs.fish`, `programs.niri`, ... — в `modules/home/`.
2. **Обычными файлами в `config/<app>/`** — если конфиг удобнее писать на родном языке приложения (lua, rasi, ...). Такие папки подключаются модулем `dotfiles` в `home/default.nix`, по умолчанию симлинком на живую репу: правки видны сразу, `nixos-rebuild` не нужен.

Подробности и пошаговые рецепты — в [docs/GUIDE.md](docs/GUIDE.md).
