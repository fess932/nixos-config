{
  config,
  pkgs,
  niri,
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
    niri.nixosModules.niri
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

  # Use desktop kernel.
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
      useOSProber = true;
      theme = "${falloutGrubTheme}";
    };
  };

  # NETWORKING
  networking = {
    hostName = "nixos";
    dhcpcd.enable = false;
    defaultGateway = "192.168.0.1";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];

    bridges.br0 = {
      interfaces = [ "enp5s0" ];
    };
    interfaces.br0 = {
      # useDHCP = true;
      ipv4.addresses = [
        {
          address = "192.168.0.100";
          prefixLength = 24;
        }
      ];
    };
  };

  # networking.networkmanager.enable = true;
  services.openvpn.servers = {
    # workVPN = {
    #   config = ''config /home/fess932/.ssh/work.ovpn'';
    #   updateResolvConf = true;
    # };
  };

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
    dates = "weekly"; # run weekly
    options = "+10";
  };

  security.sudo = {
    enable = true;
    configFile = ''
      Defaults timestamp_timeout=30 # Set timeout to 15 minutes
    '';
  };
  users.users.fess932 = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "libvirtd"
      "kvm"
      "podman"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWnaMdiOE27i//UAmppq1rUuVOBS97CTpFOA8q2Jwm0 fess932"
    ];
  };
  services.getty.autologinUser = "fess932";

  # custom configs

  #nvidia
  # harware?
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = false; # если зависает попробовать переключить
    modesetting.enable = true; # Modesetting is required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      mesa
    ];
  };

  #enable services, apps
  nixpkgs.overlays = [ niri.overlays.niri ];
  programs.niri.enable = true; # enable niri
  programs.niri.package = pkgs.niri-unstable;

  programs.dconf.enable = true;
  programs.fish.enable = true;
  programs.firefox.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  services.openssh.enable = true;
  # install apps
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    google-chrome
    gnumake
    htop

    pavucontrol
    alsa-utils
    file
    microfetch
    openssl

    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    xwayland-satellite
    packer
    xorriso
    bat

    config.boot.kernelPackages.kernel.src
  ];

  systemd.tmpfiles.rules = [
    # L+  = "создать/обновить симлинк"
    # /usr/src/linux = путь, который ждут разные билд-системы
    # ${ksrc}/source = реальный путь до исходников ядра
    "L+ /usr/src/linux-source-${config.boot.kernelPackages.kernel.version} - - - - ${config.boot.kernelPackages.kernel.src}"
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
      extraPackages = with pkgs; [
        runc
        podman-compose
      ];
    };

    libvirtd = {
      enable = true;
      qemu = {
        # важное!
        swtpm.enable = true; # для Win11
        package = pkgs.qemu_kvm; # поддержка OpenGL
        vhostUserPackages = with pkgs; [ virtiofsd ];
        verbatimConfig = ''
          # включаем OpenGL backend
          display = "gtk,gl=on"
        '';
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 10; # % RAM при котором earlyoom начнёт действовать
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
  environment.sessionVariables = {
    GSK_RENDERER = "ngl";
    # Optional, hint Electron apps to use Wayland:
    NIXOS_OZONE_WL = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    JETBRAINS_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    GTK_USE_PORTAL = "1";
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # default system setting
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";
}
