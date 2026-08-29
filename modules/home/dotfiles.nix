# ─────────────────────────────────────────────────────────────────────────────
# dotfiles — мостик между "конфиг как обычный файл в репе" и home-manager.
#
# Зачем: часть приложений (nvim/lazy.nvim, rofi, wezterm) удобнее настраивать
# их родным языком и с мгновенным откликом, без `nixos-rebuild` на каждую
# запятую. Такие конфиги лежат в ./config/<app> и подключаются симлинком.
#
# Два режима:
#   mutable   — симлинк ~/.config/<app> -> ~/nixos-config/config/<app>
#               (mkOutOfStoreSymlink). Правки видны сразу, приложение может
#               писать в свой конфиг (lazy-lock.json и т.п.). Rebuild не нужен.
#   immutable — конфиг копируется в /nix/store и подключается read-only.
#               Воспроизводимо, но приложение не может туда писать,
#               и любая правка требует rebuild.
#
# Всё, что можно выразить нативными опциями home-manager (programs.git,
# programs.fish, programs.niri...), туда и надо писать — этот модуль для
# остального.
# ─────────────────────────────────────────────────────────────────────────────
{ config, lib, ... }:

let
  cfg = config.dotfiles;

  appType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Подключать этот конфиг.";
        };

        source = lib.mkOption {
          type = lib.types.str;
          default = name;
          example = "nvim";
          description = "Имя подпапки внутри `dotfiles.src`.";
        };

        target = lib.mkOption {
          type = lib.types.str;
          default = name;
          example = "nvim";
          description = "Путь назначения относительно `base`.";
        };

        base = lib.mkOption {
          type = lib.types.enum [
            "xdg"
            "home"
          ];
          default = "xdg";
          description = "Куда класть: `xdg` -> ~/.config/<target>, `home` -> ~/<target>.";
        };

        mode = lib.mkOption {
          type = lib.types.enum [
            "mutable"
            "immutable"
          ];
          default = cfg.defaultMode;
          description = "`mutable` — симлинк в репу, `immutable` — копия в /nix/store.";
        };
      };
    }
  );

  enabled = lib.filterAttrs (_: app: app.enable) cfg.apps;

  entryFor = app: {
    source =
      if app.mode == "mutable" then
        config.lib.file.mkOutOfStoreSymlink "${cfg.dir}/${app.source}"
      else
        cfg.src + "/${app.source}";
  };

  filesFor =
    base:
    lib.mapAttrs' (_: app: lib.nameValuePair app.target (entryFor app)) (
      lib.filterAttrs (_: app: app.base == base) enabled
    );

  # Папки, которые физически лежат в ./config, но нигде не объявлены.
  # Обычно это либо забыли подключить, либо приложение уже настроено
  # нативным модулем HM — тогда добавь его в `dotfiles.ignore`.
  present = lib.attrNames (lib.filterAttrs (_: t: t == "directory") (builtins.readDir cfg.src));
  declared = lib.mapAttrsToList (_: app: app.source) cfg.apps;
  orphans = lib.subtractLists (declared ++ cfg.ignore) present;
in

{
  options.dotfiles = {
    src = lib.mkOption {
      type = lib.types.path;
      description = ''
        Путь к папке с сырыми конфигами внутри репозитория (относительный путь Nix).
        Используется для режима `immutable` и для проверки "что лежит, но не подключено".
      '';
    };

    dir = lib.mkOption {
      type = lib.types.str;
      example = "/home/fess932/nixos-config/config";
      description = ''
        Тот же каталог, но абсолютным путём в рантайме.
        Нужен для `mutable`: симлинк должен указывать на живую репу, а не на /nix/store.
      '';
    };

    defaultMode = lib.mkOption {
      type = lib.types.enum [
        "mutable"
        "immutable"
      ];
      default = "mutable";
      description = "Режим по умолчанию для записей без явного `mode`.";
    };

    ignore = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "fish" ];
      description = "Папки в `src`, про которые не надо ругаться (настроены иначе или заброшены).";
    };

    apps = lib.mkOption {
      type = lib.types.attrsOf appType;
      default = { };
      example = lib.literalExpression ''
        {
          nvim = { };                        # ~/.config/nvim  -> config/nvim (симлинк)
          rofi.mode = "immutable";           # ~/.config/rofi   -> /nix/store/...
          claude = { target = ".claude"; base = "home"; };
        }
      '';
      description = "Какие каталоги из `src` подключать и как.";
    };
  };

  config = {
    xdg.configFile = filesFor "xdg";
    home.file = filesFor "home";

    warnings = lib.optional (orphans != [ ]) ''
      dotfiles: в config/ лежат папки, которые никуда не подключены: ${lib.concatStringsSep ", " orphans}.
      Объяви их в `dotfiles.apps` или добавь в `dotfiles.ignore`.
    '';
  };
}
