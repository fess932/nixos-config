{ noctalia, niri, ... }:

{
  imports = [
    noctalia.homeModules.default
    niri.homeModules.niri
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = {
      # configure noctalia here; defaults will
      # be deep merged with these attributes.
      bar = {
        # density = "compact";
        position = "top";
        showCapsule = false;
        widgets = {
          left = [
            {
              id = "SidePanelToggle";
              useDistroLogo = true;
            }
            {
              id = "WiFi";
            }
            {
              id = "Bluetooth";
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
              alwaysShowPercentage = false;
              id = "Battery";
              warningThreshold = 30;
            }
            {
              formatHorizontal = "HH:mm";
              formatVertical = "HH mm";
              id = "Clock";
              useMonospacedFont = true;
              usePrimaryColor = true;
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
      };
    };
    # this may also be a string or a path to a JSON file,
    # but in this case must include *all* settings.
  };

  programs.niri = {
    enable = true;
    settings = {
      spawn-at-startup = [
        {
          command = [
            "noctalia-shell"
          ];
        }
      ];

      binds = {
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
      };

    };
  };
  # programs.niri.enable = true;
}
