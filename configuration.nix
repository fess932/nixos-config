{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Belgrade";

  system.autoUpgrade = {
    enable = true;
    flags = [
      "--print-build-logs"
    ];
    flake = "path:${config.users.users.fess932.home}/nixos-config#${config.networking.hostName}";
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly"; # Example: run weekly
    options = "+5";
  };

  security.sudo = {
    enable = true;
    configFile = ''
      Defaults timestamp_timeout=30 # Set timeout to 15 minutes
    '';
  };
  users.users.fess932 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWnaMdiOE27i//UAmppq1rUuVOBS97CTpFOA8q2Jwm0 fess932"
    ];
  };
  services.getty.autologinUser = "fess932";

  # custom configs

  #nvidia
  # harware?
  hardware.graphics.enable = true;
  hardware.nvidia.open = false; # если зависает попробовать переключить
  #wayland

  #enable services, apps
  programs.hyprland.enable = true; # enable Hyprland

  programs.firefox.enable = true;
  services.openssh.enable = true;
  # install apps
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    waybar
    google-chrome
    gnumake
    htop
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # default system setting
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";
}
