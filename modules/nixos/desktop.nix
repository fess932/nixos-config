# Графическая сессия: niri, портал/GTK-окружение, файловый менеджер, шрифты.
{ pkgs, ... }:

{
  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  programs.dconf.enable = true;
  programs.firefox.enable = true;
  programs.xfconf.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.gvfs.enable = true; # монтирование, корзина и пр.
  services.tumbler.enable = true; # превью картинок

  # nix-ld — чтобы бинарники не из nixpkgs (например, вендорные CLI) находили libc.
  programs.nix-ld.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
    NIXOS_OZONE_WL = "1"; # Electron-приложения в Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JETBRAINS_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    GTK_USE_PORTAL = "1";
  };
}
