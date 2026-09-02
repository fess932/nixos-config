# Пользователи, sudo, доступ по ssh.
{ pkgs, ... }:

{
  programs.fish.enable = true; # нужен на уровне системы, т.к. это login-shell юзера

  users.users.fess932 = {
    isNormalUser = true;
    linger = true; # user@1000 с загрузки: иначе podman-tcp.socket живёт только при сессии
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
  services.openssh.enable = true;

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout=30 # Set timeout to 15 minutes
    '';
  };
}
