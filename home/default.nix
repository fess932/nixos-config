# Точка входа home-manager для пользователя fess932.
# Здесь — только «кто я и где», остальное разложено по ../modules/home.
{ config, ... }:

{
  imports = [ ../modules/home ];

  home.username = "fess932";
  home.homeDirectory = "/home/fess932";

  # НЕ трогать: как и system.stateVersion, фиксирует совместимость данных.
  home.stateVersion = "26.05";

  # ── Конфиги, которые живут обычными файлами в ./config ────────────────────
  # Полное описание опций — в modules/home/dotfiles.nix, инструкция — в docs/.
  dotfiles = {
    src = ../config; # путь в репе (для immutable и для проверок)
    dir = "${config.home.homeDirectory}/nixos-config/config"; # он же в рантайме (для симлинков)

    defaultMode = "mutable"; # правки видны сразу, без nixos-rebuild

    apps = {
      nvim = { }; # ~/.config/nvim    -> config/nvim
      rofi = { }; # ~/.config/rofi    -> config/rofi
      wezterm = { }; # ~/.config/wezterm -> config/wezterm
    };

    # Папки в config/, про которые модуль не должен ругаться:
    # те, что настраиваются нативными опциями home-manager.
    ignore = [ ];
  };
}
