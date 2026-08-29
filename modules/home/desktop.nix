# Внешний вид пользовательской сессии и десктопные приложения.
{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 28;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 13;
    };
  };

  programs.wezterm.enable = true; # конфиг — в ./config/wezterm

  home.packages = with pkgs; [
    telegram-desktop
    mattermost-desktop
    qbittorrent
    prismlauncher
    wiremix
    matugen
  ];
}
