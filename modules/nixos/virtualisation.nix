# Контейнеры (podman) и виртуалки (libvirt/QEMU + SPICE).
{ config, pkgs, ... }:

{
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true; # алиас `docker` -> podman
      defaultNetwork.settings.dns_enabled = true; # чтобы контейнеры podman-compose видели друг друга
      extraPackages = with pkgs; [
        runc
        podman-compose
      ];
    };

    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true; # требуется для Win11
        package = pkgs.qemu_kvm;
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

  # Движок podman наружу по TCP от root: тесты с testcontainers ходят сюда с другой машины,
  # а шасси стенда запускаются привилегированными (netns, sysfs, модуль openvswitch).
  systemd.sockets.podman-tcp = {
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "0.0.0.0:2375";
      Service = "podman-tcp.service";
    };
  };
  systemd.services.podman-tcp = {
    serviceConfig = {
      Type = "exec";
      ExecStart = "${config.virtualisation.podman.package}/bin/podman system service --time=0";
    };
  };

  environment.sessionVariables = {
    # rootless podman: lazydocker/oxker/docker-cli ходят в юзерский сокет
    DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    packer
    xorriso

    podman-tui
    lazydocker
    oxker

		cloud-hypervisor
		socat
  ];
}
