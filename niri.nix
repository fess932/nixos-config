{
  noctalia,
  niri,
  ...
}:

{
  imports = [
    noctalia.homeModules.default
    niri.homeModules.niri
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
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      dock.enabled = false;
      bar = {
        # density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "SidePanelToggle";
              # useDistroLogo = true;
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
              formatHorizontal = "HH:mm";
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

  programs.niri = {
    enable = true;
    settings = {
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
        # "Alt+Tab".action.spawn = [ "niri-switch" ];

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
          "0.1+"
        ];
        "XF86AudioLowerVolume".action.spawn = [
          "wpctl"
          "set-volume"
          "@DEFAULT_AUDIO_SINK@"
          "0.1-"
        ];

        "Mod+Q".action.close-window = { };
        "Mod+Return".action.maximize-column = { };
        "Alt+Tab".action.focus-column-right-or-first = { };

        "Mod+Up".action.focus-window-or-workspace-up = { };
        "Mod+Down".action.focus-window-or-workspace-down = { };
        "Mod+Left".action.focus-column-left = { };
        "Mod+Right".action.focus-column-right = { };

        "Mod+S".action.screenshot = { };

      };

    };
  };
  # programs.niri.enable = true;
}
