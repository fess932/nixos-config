{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Standard .config/directory
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    rofi = "rofi";
    alacritty = "alacritty";
    picom = "picom";
    hyprshell = "hyprshell";
  };
in

{
  imports = [
    ./hyperland.nix
  ];

  home.stateVersion = "25.05";
  home.username = "fess932";
  home.homeDirectory = "/home/fess932";
  programs.git = {
    enable = true;
    settings.user = {
      name = "fess932";
      email = "fess932@gmail.com";
    };
  };

  programs.home-manager.enable = true;
  programs.wezterm.enable = true;
  programs.vscode.enable = true;
  services.hyprshell.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    };
    initExtra = ''
      export PS1="\[\e[38;5;75m\]\u@\h \[\e[38;5;113m\]\w \[\e[38;5;189m\]\$ \[\e[0m\]"
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        dbus-run-session Hyprland
      fi
    '';
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixfmt-rfc-style
    nodejs
    gcc
    hyprpaper
    waybar
    hyprshell
    telegram-desktop
    prismlauncher
    wiremix
  ];

  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland

  xdg.configFile = builtins.mapAttrs (name: subpath: {
    source = create_symlink "${dotfiles}/${subpath}";
    recursive = true;
  }) configs;

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 28;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
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
}
