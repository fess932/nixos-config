{
  config,
  pkgs,
  noctalia,
  ...
}:

let
  falloutGrubTheme = pkgs.fetchFromGitHub {
    owner = "shvchk";
    repo = "fallout-grub-theme";
    rev = "2c51d28701c03c389309e34585ca8ff2b68c23e9";
    sha256 = "sha256-iQU1Rv7Q0BFdsIX9c7mxDhhYaWemuaNRYs+sR1DF0Rc=";
  };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  services.pipewire = {
    enable = true;
    alsa.enable = true; # связь с драйверами ALSA в ядре
    alsa.support32Bit = true; # чтобы работали 32-битные игры (Steam и пр.)
    pulse.enable = true; # слой совместимости для программ, ожидающих PulseAudio
    # jack.enable = true; # (опционально) совместимость с JACK для аудио-приложений
    wireplumber.enable = true; # менеджер сессий — обязателен
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.firmware = [ pkgs.linux-firmware ];

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader = {
    efi.canTouchEfiVariables = true;

    # systemd-boot.configurationLimit = 5;
    systemd-boot.enable = false;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev"; # если используешь EFI
      # efiInstallAsRemovable = true;
      configurationLimit = 5;

      theme = "${falloutGrubTheme}";

      # theme = pkgs.stdenv.mkDerivation {
      #   pname = "distro-grub-themes";
      #   version = "3.1";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "AdisonCavani";
      #     repo = "distro-grub-themes";
      #     rev = "v3.1";
      #     hash = "sha256-ZcoGbbOMDDwjLhsvs77C7G7vINQnprdfI37a9ccrmPs=";
      #   };
      #   installPhase = "cp -r customize/nixos $out";
      # };
    };
  };

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
  programs.niri.enable = true; # enable niri

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

    pavucontrol
    alsa-utils

    noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
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
