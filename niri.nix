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

  home.packages = [
    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    niri-switch.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

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
      "Alt+O".action.toggle-overview = { };

      "Mod+Up".action.focus-window-or-workspace-up = { };
      "Mod+Down".action.focus-window-or-workspace-down = { };
      "Mod+Left".action.focus-column-left = { };
      "Mod+Right".action.focus-column-right = { };

      "Mod+S".action.screenshot = { };

    };

  };
}
