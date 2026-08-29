# Настройки самого Nix: кэши, GC, автообновление.
{ config, ... }:

{
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
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade = {
    enable = true;
    flags = [ "--print-build-logs" ];
    flake = "path:${config.users.users.fess932.home}/nixos-config#${config.networking.hostName}";
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  nixpkgs.config.allowUnfree = true;
}
