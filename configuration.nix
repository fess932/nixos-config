{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  users.users.fess932 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # custom configs

  #nvidia
  # harware?
  hardware.graphics.enable = true;
  hardware.nvidia.open = false; # если зависает попробовать переключить
  #wayland

  #enable services, apps
  programs.hyprland.enable = true; # enable Hyprland
  programs.firefox.enable = true;

  # install apps
  environment.systemPackages = with pkgs; [
    kitty
    vim
    wget
    git
    alacritty
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.picom.enable = true;
  services.displayManager.ly.enable = true;
  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    windowManager.qtile.enable = true;
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/nixos-dotfiles/walls/wall1.png
    '';
    extraConfig = ''
      	Section "Monitor"
      	  Identifier "Virtual-1"
      	  Option "PreferredMode" "1920x1080"
      	EndSection
    '';
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.05";
}
