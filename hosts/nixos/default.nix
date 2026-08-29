# Хост `nixos` — всё, что уникально для этой машины:
# железо, имя, сеть, таймзона, stateVersion.
# Всё переиспользуемое живёт в ../../modules/nixos.
{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    inputs.niri.nixosModules.niri

    ../../modules/nixos
  ];

  networking = {
    hostName = "nixos";

    dhcpcd.enable = false;
    defaultGateway = "192.168.0.1";
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];

    firewall.enable = false;

    # Бридж нужен, чтобы виртуалки были видны в локальной сети как отдельные хосты.
    bridges.br0.interfaces = [ "enp5s0" ];
    interfaces.br0.ipv4.addresses = [
      {
        address = "192.168.0.100";
        prefixLength = 24;
      }
    ];
  };

  time.timeZone = "Europe/Belgrade";

  # НЕ трогать: фиксирует совместимость stateful-данных, а не версию NixOS.
  system.stateVersion = "25.11";
}
