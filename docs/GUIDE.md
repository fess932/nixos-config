# Как правильно менять этот конфиг

Документ отвечает на один вопрос: **«я хочу что-то настроить — куда это писать?»**

---

## 1. Схема репозитория

```
flake.nix                    инпуты (nixpkgs, home-manager, niri, noctalia, claude-code)
                             оверлеи, сборка nixosConfigurations.nixos
│
├── hosts/nixos/
│   ├── default.nix          hostname, сеть, таймзона, stateVersion — только эта машина
│   └── hardware-configuration.nix   генерится nixos-generate-config, руками не трогать
│
├── modules/nixos/           СИСТЕМА (root): работает до входа пользователя
│   ├── default.nix          индекс: подключает всё остальное
│   ├── boot.nix             GRUB и тема
│   ├── nix.nix              кэши, GC, autoUpgrade, allowUnfree
│   ├── hardware.nix         звук (pipewire), bluetooth, earlyoom
│   ├── nvidia-cuda.nix      драйвер, Vulkan/VA-API, тулчейн CUDA
│   ├── desktop.nix          niri, thunar, портал/GTK-переменные, шрифты
│   ├── virtualisation.nix   podman, libvirt/QEMU, SPICE
│   ├── users.nix            пользователи, sudo, ssh
│   └── packages.nix         минимум CLI, нужный root и до графики
│
├── modules/home/            ПОЛЬЗОВАТЕЛЬ (home-manager)
│   ├── default.nix          индекс
│   ├── dotfiles.nix         мостик "config/<app>" -> ~/.config  (см. §4)
│   ├── shell.nix            fish, bash, atuin, git
│   ├── dev.nix              neovim, go, bun, vscode, dev-CLI
│   ├── desktop.nix          gtk, курсор, десктопные приложения
│   ├── niri.nix             niri settings + noctalia
│   └── claude-code.nix      claude-code (см. §6)
│
├── home/default.nix         username/homeDirectory/stateVersion + карта dotfiles
├── pkgs/                    собственные пакеты -> pkgs.local.*
├── config/                  СЫРЫЕ конфиги приложений, не Nix
└── docs/GUIDE.md            этот файл
```

Правило вложенности: `hosts/` подключает `modules/`, `modules/` не знает про `hosts/`.
Хост описывает «что уникально», модули — «как это делается».

---

## 2. Куда писать новую настройку

```
Это нужно ДО логина / всем пользователям / это демон, драйвер, ядро?
├── да  ──► modules/nixos/<тематический файл>.nix
└── нет ──► это про мой пользователь
           │
           ├── у home-manager есть нативная опция (programs.X / services.X)?
           │   └── да ──► modules/home/<файл>.nix   ← предпочтительный вариант
           │
           └── нет, или конфиг громоздкий и на своём языке (lua, rasi, ron)
               └──► config/<app>/  +  запись в dotfiles.apps  (§4)

Это уникально для ЭТОЙ машины (ip, hostname, диски)? ──► hosts/nixos/default.nix
Это свой пакет / патч? ──────────────────────────────► pkgs/  (§7)
```

Проверка «правильно ли положил»: если файл нельзя переиспользовать на второй
машине без правок — он должен лежать в `hosts/`, а не в `modules/`.

---

## 3. Как добавить пакет

**Системный** (нужен root'у, в single-user режиме, до графики) —
`modules/nixos/packages.nix` или тематический модуль рядом с тем, что его использует:

```nix
environment.systemPackages = with pkgs; [
  ripgrep
];
```

**Пользовательский** (обычный случай) — в подходящий файл `modules/home/`:

```nix
home.packages = with pkgs; [
  ripgrep
];
```

Если у пакета есть модуль home-manager — используй его вместо `home.packages`,
он заодно настроит конфиги, completions и сервисы:

```nix
programs.ripgrep.enable = true;   # вместо home.packages = [ pkgs.ripgrep ];
```

Найти опции: <https://home-manager-options.extranix.com> и <https://search.nixos.org/options>.

---

## 4. Конфиг приложения обычными файлами (`config/`)

Это то, ради чего есть `modules/home/dotfiles.nix`. Часть приложений неудобно
описывать в Nix: nvim с lazy.nvim, wezterm на lua, rofi на rasi. Такие конфиги
лежат в `config/<app>/` как есть и подключаются симлинком.

### Два режима

| | `mutable` (по умолчанию) | `immutable` |
|---|---|---|
| что происходит | `~/.config/app` → симлинк на `~/nixos-config/config/app` | конфиг копируется в `/nix/store`, подключается read-only |
| правки | видны сразу, rebuild не нужен | нужен `make switch` |
| приложение может писать в конфиг | да (`lazy-lock.json`, кэши) | нет |
| воспроизводимость | конфиг всё равно в git, но система не «замораживает» его | полная |
| когда брать | активно правишь; приложение пишет в свой конфиг | конфиг устоялся, хочешь гарантию |

Технически `mutable` — это `config.lib.file.mkOutOfStoreSymlink`: home-manager
кладёт в store симлинк, указывающий наружу, на живую репу.

### Добавить приложение

1. Положить конфиг: `config/foo/...`
2. Объявить в `home/default.nix`:

```nix
dotfiles.apps = {
  nvim = { };                   # ~/.config/nvim -> config/nvim
  foo = { };                    # ~/.config/foo  -> config/foo
};
```

3. `make switch`

### Полный набор опций записи

```nix
dotfiles.apps = {
  # минимум: имя = имя папки в config/ = имя папки в ~/.config
  wezterm = { };

  # заморозить в store
  rofi.mode = "immutable";

  # временно отключить, не удаляя папку
  old-app.enable = false;

  # папка называется иначе, чем цель
  foo = {
    source = "foo-config";      # config/foo-config
    target = "foo";             # ~/.config/foo
  };

  # положить не в ~/.config, а прямо в ~
  claude = {
    base = "home";
    target = ".claude";         # ~/.claude -> config/claude
  };
};
```

Глобальные настройки модуля — там же, в `home/default.nix`:

```nix
dotfiles = {
  src = ../config;                                            # путь в репе
  dir = "${config.home.homeDirectory}/nixos-config/config";   # он же в рантайме
  defaultMode = "mutable";
  ignore = [ ];   # папки в config/, про которые не надо предупреждать
};
```

### Страховка

Если в `config/` появилась папка, которую нигде не объявили, сборка выдаст
предупреждение:

```
dotfiles: в config/ лежат папки, которые никуда не подключены: foo.
Объяви их в `dotfiles.apps` или добавь в `dotfiles.ignore`.
```

Так конфиги не теряются молча. Если папку подключать не надо (приложение
уже настроено нативным модулем HM) — её имя добавляется в `dotfiles.ignore`.

### Чего НЕ делать

Не подключать через `dotfiles` то, чем уже управляет нативный модуль HM.
`programs.fish` пишет `~/.config/fish/config.fish`; если поверх положить
симлинк всей папки — будет конфликт файлов при активации. Выбирай что-то одно.

---

## 5. Как подключить пакет из чужого flake

Схема одна и та же, три шага. На примере `claude-code`:

**Шаг 1 — инпут** (`flake.nix`):

```nix
inputs.claude-code.url = "github:sadjow/claude-code-nix";
```

Если инпут собирает обычный софт — стоит прибить его nixpkgs к нашему,
чтобы не тащить второй набор зависимостей:

```nix
inputs.foo = {
  url = "github:owner/repo";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

**Шаг 2 — оверлей** (там же, список `overlays`). Оверлей кладёт пакет
в `pkgs`, и дальше по конфигу он выглядит как обычный пакет из nixpkgs:

```nix
overlays = [
  inputs.niri.overlays.niri
  inputs.claude-code.overlays.default
  (import ./pkgs)
];
```

Как узнать, что экспортирует чужой flake:

```sh
nix flake show github:sadjow/claude-code-nix
nix eval github:sadjow/claude-code-nix#overlays --apply builtins.attrNames
```

**Шаг 3 — использование**: `pkgs.claude-code` в `home.packages` /
`environment.systemPackages`, либо через модуль (см. §6).

Если оверлея у flake нет, пакет берётся напрямую:

```nix
home.packages = [ inputs.foo.packages.${pkgs.system}.default ];
```

Оверлей лучше: пакет попадает во все места сразу (включая `pkgs` внутри HM,
благодаря `useGlobalPkgs = true`), и его подхватывают модули,
объявляющие `package = mkPackageOption pkgs "foo"`.

Обновить один инпут:

```sh
make update-input INPUT=claude-code
make switch
```

---

## 6. Claude Code

Собран из двух частей:

- **пакет** — из flake-инпута `claude-code` (`github:sadjow/claude-code-nix`)
  через оверлей в `flake.nix`. Этот flake обновляется гораздо быстрее, чем
  nixpkgs;
- **конфигурация** — нативным модулем home-manager `programs.claude-code`
  в `modules/home/claude-code.nix`.

Модуль сам подхватывает `pkgs.claude-code` (оверлей уже подменил его),
кладёт `claude` в пользовательский профиль и управляет только теми файлами
в `~/.claude`, которые ты явно опишешь. Пока `settings = { }`, файл
`~/.claude/settings.json` не создаётся вовсе и Claude Code пишет туда сам.

Что можно описать декларативно:

```nix
programs.claude-code = {
  enable = true;

  # ~/.claude/settings.json (как только не пусто — файл становится read-only)
  settings = {
    includeCoAuthoredBy = false;
    permissions.allow = [ "Bash(git diff:*)" ];
  };

  context = ./claude/CLAUDE.md;              # глобальный ~/.claude/CLAUDE.md
  commands.review = ./claude/commands/review.md;
  agents.golang = ./claude/agents/golang.md;
  skills.xlsx = ./claude/skills/xlsx;
  mcpServers = { };
};
```

Проверить, какая версия соберётся:

```sh
nix eval .#nixosConfigurations.nixos.config.home-manager.users.fess932.programs.claude-code.package.name
```

Если хочется наоборот — не декларативно, а «папка в репе», Claude Code
отлично ложится на §4:

```nix
dotfiles.apps.claude = { base = "home"; target = ".claude"; };
```

Но так HM-модуль и `dotfiles` подерутся за одни и те же файлы — выбирай одно.

---

## 7. Свой пакет

`pkgs/<name>/default.nix` + строчка в `pkgs/default.nix`:

```nix
final: _prev: {
  local = {
    cuda-13 = import ./cuda-13 { pkgs = final; };
  };
}
```

Дальше — `pkgs.local.cuda-13` в любом месте конфига. Namespace `local`
нужен, чтобы свои пакеты не перепутались с nixpkgs и не сломались при
переименованиях вверху по течению.

---

## 8. Рабочий цикл

```sh
vim modules/home/dev.nix

make build      # собрать, не применяя — ловит ошибки eval
make diff       # какие пакеты реально изменятся
make switch     # применить

make rollback   # если стало хуже
```

Отдельно: правки в `config/*` для `mutable`-записей применяются сразу,
без `make switch` — просто перезапусти приложение.

Обновление:

```sh
make update                              # все инпуты + switch
make update-input INPUT=nixpkgs          # только один
```

Форматирование — `nixfmt` (RFC-style), `make fmt` / `make fmt-check`.

---

## 9. Грабли

**«file not found» на новый .nix.** Флейк видит только то, что в git-индексе.
`git add -A` (цели Makefile делают это сами).

**Конфликт файлов при активации HM.** Один и тот же путь описан дважды —
обычно нативным модулем и `dotfiles` одновременно. Смотри §4 «Чего не делать».
Существующий файл HM переименует в `*.backup` (`backupFileExtension`).

**Симлинк `mutable` ведёт в никуда.** `dotfiles.dir` — абсолютный путь к репе.
Если репозиторий переехал, поправь его в `home/default.nix`.

**`nixos-rebuild` ругается на unfree.** `nixpkgs.config.allowUnfree = true`
уже стоит в `modules/nixos/nix.nix`.

**Изменил stateVersion.** Не надо. `system.stateVersion` и `home.stateVersion`
фиксируют формат stateful-данных (базы, форматы конфигов сервисов), а не
версию NixOS. Меняются только осознанно, по release notes.
