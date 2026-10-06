# Оконный менеджер niri и шелл noctalia.
{
  inputs,
  options,
  pkgs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.packages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.wl-clipboard # wl-copy/wl-paste; через него Claude Code читает картинки из буфера
  ];

  home.sessionVariables = {
    GTK_USE_PORTAL = "1"; # важное
    GDK_BACKEND = "wayland,x11";
    JETBRAINS_ENABLE_WAYLAND = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    XDG_SESSION_TYPE = "wayland";

    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    NVD_BACKEND = "direct";
  };

  programs.noctalia = {
    enable = true;
    # Схема noctalia v5: https://docs.noctalia.dev/noctalia/configuration/
    # То, что накликано в GUI, лежит в ~/.local/state/noctalia/settings.toml
    # и перекрывает значения отсюда.
    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      wallpaper = {
        enabled = true;
        default.path = "~/Downloads/0f6oxa9y9jlb1.png";
      };

      # Координаты для погоды, ночного света и авто-темы.
      location.address = "Belgrade, Serbia";

      osd.position = "bottom_center";

      # Полупрозрачные панели (лаунчер, control center и т.д.); блюр под ними даёт niri.
      shell.panel.transparency_mode = "glass";

      bar.main = {
        position = "top";
        background_opacity = 0.75;
        capsule = false;
        margin_ends = 28;
        radius = 8;

        start = [
          "control-center"
          "cpu"
          "cpu-temp"
          "ram"
          "media"
          "audio_visualizer"
        ];
        center = [ "workspaces" ];
        end = [
          "tray"
          "clock"
          "notifications"
        ];
      };

      # Имя виджета в списках бара -> его тип и настройки.
      widget = {
        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
        };
        cpu-temp = {
          type = "sysmon";
          stat = "cpu_temp";
        };
        ram = {
          type = "sysmon";
          stat = "ram_used";
        };

        media = {
          max_length = 200;
          hide_album_art = true;
          hide_when_no_media = true;
        };

        workspaces.show_labels = false;

        clock = {
          format = "{:%H:%M    [%d %A]}";
          font_family = "monospace";
          color = "primary";
        };
      };
    };
    # settings целиком можно заменить строкой или путём до .toml —
    # но тогда в нём должны быть ВСЕ настройки.
  };

  programs.niri.settings = {
    prefer-no-csd = true;
    input.keyboard.xkb = {
      layout = "us,ru";
      options = "grp:caps_toggle";
    };
    input.focus-follows-mouse = {
      max-scroll-amount = "0%";
    };

    spawn-at-startup = [
      {
        command = [
          "noctalia"
        ];
      }
    ];

    layout = {
      gaps = 10;

      focus-ring = {
        width = 2;
      };
      border = {
        enable = false;
        width = 2;
      };

      shadow = {
        enable = false;
      };
    };

    binds = {
      "Mod+Space".action.spawn = [
        "noctalia"
        "msg"
        "panel-toggle"
        "launcher"
      ];
      "Mod+S".action.spawn = [
        "noctalia"
        "msg"
        "panel-toggle"
        "control-center"
      ];

      "Alt+Shift+S".action.spawn = [
        "noctalia"
        "msg"
        "screenshot-region"
      ];

      "Mod+Q".action.close-window = { };
      "Mod+Return".action.maximize-column = { };
      "Alt+O".action.toggle-overview = { };
      "Mod+Up".action.focus-window-or-workspace-up = { };
      "Mod+Down".action.focus-window-or-workspace-down = { };
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };

      "XF86AudioRaiseVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.05+"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "0.05-"
      ];
    };

    window-rules = [
      {
        matches = [
          {
            app-id = "wezterm";
          }
          {
            app-id = "firefox";
          }
          {
            app-id = "google-chrome";
          }
          {
            app-id = "code";
          }
          {
            app-id = "zed";
          }
          {
            app-id = "spicy";
          }
        ];
        open-maximized = true;
      }
    ];

  };

  # Блюр под баром/панелями noctalia и под полупрозрачными окнами (niri >= 26.04).
  # В programs.niri.settings этих опций пока нет, поэтому дописываем сырой KDL
  # к тому, что сгенерировано из settings.
  programs.niri.config =
    inputs.niri.lib.kdl.serialize.nodes options.programs.niri.config.default
    + ''

      window-rule {
          background-effect {
              blur true
              xray false
          }
      }

      // xray false — размывать то, что реально под панелью, а не обои.
      layer-rule {
          match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"
          background-effect {
              xray false
          }
      }

      layer-rule {
          match namespace="noctalia-window-switcher"
          background-effect {
              blur true
              xray false
          }
      }
    '';

  # Действия сессии как «приложения»: лаунчер ранжирует приложения намного выше
  # встроенных действий /session, так что `reboot` + Enter попадает сюда первым.
  xdg.desktopEntries = {
    noctalia-reboot = {
      name = "Reboot";
      comment = "Перезагрузить компьютер";
      icon = "system-reboot";
      exec = "noctalia msg session reboot";
      categories = [ "System" ];
    };
    noctalia-shutdown = {
      name = "Shutdown";
      comment = "Выключить компьютер";
      icon = "system-shutdown";
      exec = "noctalia msg session shutdown";
      categories = [ "System" ];
    };
  };
}
