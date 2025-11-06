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
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    waybar
    google-chrome
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";
}
