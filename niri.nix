{
  noctalia,
  niri-switch,
  pkgs,
  ...
}:

{
  imports = [
    noctalia.homeModules.default
  ];

  home.packages = [
    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    niri-switch.packages.${pkgs.stdenv.hostPlatform.system}.default
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

  programs.noctalia-shell = {
    enable = true;
    settings = {
      dock.enabled = false;
      bar = {
        # density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              "colorizeDistroLogo" = false;
              "customIconPath" = "";
              "icon" = "noctalia";
              "id" = "ControlCenter";
              "useDistroLogo" = false;
            }
            {
              "id" = "SystemMonitor";
              "showCpuTemp" = true;
              "showCpuUsage" = true;
              "showDiskUsage" = false;
              "showMemoryAsPercent" = false;
              "showMemoryUsage" = true;
              "showNetworkStats" = false;
              "usePrimaryColor" = false;
            }

            {
              id = "MediaMini";
              maxWidth = 200;
              useFixedWidth = false;
              showAlbumArt = false;
              showVisualizer = true;
              visualizerType = "linear";
            }

          ];
          center = [
            {
              hideUnoccupied = false;
              id = "Workspace";
              labelMode = "none";
            }

          ];
          right = [

            {
              id = "Bluetooth";
            }
            {
              formatHorizontal = "HH:mm    [dd dddd]";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
            }
            {
              id = "NotificationHistory";
            }
          ];
        };
      };
      colorSchemes.predefinedScheme = "Catppuccin";
      # general = {
      #   avatarImage = "/home/fess932/.face";
      #   radiusRatio = 0.2;
      # };
      location = {
        monthBeforeDay = false;
        name = "Belgrade, Serbia";
      };

      wallpaper = {
        enabled = true;
        defaultWallpaper = "~/Downloads/0f6oxa9y9jlb1.png";
        directory = "~/Downloads/";
        randomEnabled = true;
      };

      osd.location = "bottom_center";
    };
    # this may also be a string or a path to a JSON file,
    # but in this case must include *all* settings.
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
          "noctalia-shell"
        ];
      }
      {
        command = [
          "niri-switch-daemon"
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
      "Alt+Tab".action.spawn = [ "niri-switch" ];

      # "Mod+P".action.spawn = [
      #   "niri"
      #   "msg"
      #   "pick-window"
      # ];

      "Mod+Space".action.spawn = [
        "noctalia-shell"
        "ipc"
        "call"
        "launcher"
        "toggle" # ✅
      ];
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

      "Mod+Q".action.close-window = { };
      "Mod+Return".action.maximize-column = { };
      # "Alt+Tab".action.focus-column-right-or-first = { };
      "Alt+O".action.toggle-overview = { };

      "Mod+Up".action.focus-window-or-workspace-up = { };
      "Mod+Down".action.focus-window-or-workspace-down = { };
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };

      "Mod+S".action.screenshot = { };
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
}
