{
  config,
  pkgs,
  niri-switch,
  noctalia,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/nixos-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Standard .config/directory
  configs = {
    nvim = "nvim";
    rofi = "rofi";
    wezterm = "wezterm";
  };
in

{
  imports = [
    ./niri.nix
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

  # shell history
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.home-manager.enable = true;
  programs.wezterm.enable = true;
  programs.vscode.enable = true;

  programs.fish = {
    enable = true;
    shellAliases = {
      # starth = "dbus-run-session Hyprland";
      startn = "dbus-run-session niri";
    };
    # 1️⃣ Выполняется только при входе (TTY1)
    loginShellInit = ''
      if test -z "$WAYLAND_DISPLAY"; and test "$XDG_VTNR" -eq 1
          dbus-run-session niri
      end
    '';

    interactiveShellInit = ''
      set fish_greeting ""
      if status --is-interactive; and type -q microfetch
        microfetch
      end

      function fish_prompt
              # Хост (голубой)
              set_color '#5f87d7'
              echo -n (hostname)"@"

              # Пользователь (зелёный)
              set_color '#87d787'
              echo -n (whoami)

              # Текущая директория
              set_color '#afafff'
              echo -n "/"(prompt_pwd)" "

              # Разделитель (фиолетовый)
              set_color '#d7afd7'
              echo -n "❯ "

              # Сброс цвета
              set_color normal
          end
    '';
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      # starth = "dbus-run-session Hyprland";
      startn = "dbus-run-session niri";
    };
    initExtra = ''
      export PS1="\[\e[38;5;75m\]\u@\h \[\e[38;5;113m\]\w \[\e[38;5;189m\]\$ \[\e[0m\]"
      if [ -z "''${WAYLAND_DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
        dbus-run-session niri
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
    telegram-desktop
    prismlauncher
    wiremix
    xq
    matugen

    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    niri-switch.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

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
