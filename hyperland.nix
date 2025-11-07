{ ... }:
{

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {

      general = {
        "$modifier" = "SUPER";
        gaps_in = 4;
        gaps_out = 9;
        border_size = 1;
        layout = "dwindle"; # dwindle or master
      };

      cursor = {
        no_hardware_cursors = true;
        # use_cpu_buffer = true; # This might also be helpful on some systems
      };

      exec-once = [
        "waybar"
      ];

      binds = {
        allow_workspace_cycles = true;
      };
      bind = [
        "$modifier,Return,exec,wezterm"
        "$modifier,K,exec,list-keybinds"
        "$modifier,Space,exec,rofi -show drun"
        # "Super,Tab,exec,rofi -show window"
        # "Alt,Tab,cyclenext"
        # "Alt,Tab,workspace,m+1"
        # "Alt,Tab,workspace,previous"
        # "Alt,Tab,bringactivetotop"
        "$modifier,1,workspace,1"
        "$modifier,2,workspace,2"
        "$modifier,3,workspace,3"
      ];

      animations = {
        enabled = true;
        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "fluent_decel, 0.1, 1, 0, 1"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
        ];
        animation = [
          "windows, 1, 3, md3_decel, popin 60%"
          "border, 1, 10, default"
          "fade, 1, 2.5, md3_decel"
          # "workspaces, 1, 3.5, md3_decel, slide"
          "workspaces, 1, 3.5, easeOutExpo, slide"
          # "workspaces, 1, 7, fluent_decel, slidefade 15%"
          # "specialWorkspace, 1, 3, md3_decel, slidefadevert 15%"
          "specialWorkspace, 1, 3, md3_decel, slidevert"
        ];
      };

    };

    extraConfig = ''
      input {
        kb_layout=us,ru
        kb_options=grp:caps_toggle
      }

      env = ELECTRON_OZONE_PLATFORM_HINT,auto
      env = LIBVA_DRIVER_NAME,nvidia
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = XDG_SESSION_TYPE,wayland
      env = GBM_BACKEND,nvidia-drm
      env = HYPRCURSOR_SIZE,26
    '';

  };
}
