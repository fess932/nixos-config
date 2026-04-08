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

  hardware = {
    enableRedistributableFirmware = true;

    nvidia = {
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

    graphics = {
      enable = true;
      enable32Bit = true; # для 32-битных игр
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        mesa
        vulkan-loader
        vulkan-validation-layers
        vulkan-tools
      ];
    };

    bluetooth.enable = true;
  };

  services.blueman.enable = true;
  # hardware.firmware = [ pkgs.linux-firmware ];

  # Use desktop kernel.
  # boot.kernelPackages = pkgs.linuxPackages_zen;
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
    options = "--delete-older-than 7d";
  };

  security.sudo = {
    enable = true;
    extraConfig = ''
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

  #enable services, apps
  nixpkgs.overlays = [ niri.overlays.niri ];
  programs.niri.enable = true; # enable niri
  programs.niri.package = pkgs.niri-unstable;

  programs.nix-ld.enable = true;
  programs.dconf.enable = true;
  programs.fish.enable = true;
  programs.firefox.enable = true;
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
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

    uv
    cudatoolkit
    cudaPackages.cudnn

    pciutils
    vulkan-tools
    nvtopPackages.nvidia
    # config.boot.kernelPackages.kernel.src
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
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  environment.variables = {
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # default system setting

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://cuda-maintainers.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ]; # добавить своего юзера
    experimental-features = [
      "nix-command"
      "flakes"
    ]; # включаем экспериментальные функции
  };
  system.stateVersion = "25.11";
}
