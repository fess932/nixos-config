# Настройки самого Nix: кэши, GC, автообновление.
{ config, ... }:

{
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];

    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Если кэш недоступен или в нём нет пути — собрать локально, а не упасть.
    fallback = true;

    # Дефолт 15 с: недоступная подстановочная кэш-точка вешает старт сборки.
    connect-timeout = 5;

    # Машина используется как один большой devShell: не давать GC уносить
    # выходы деривации, из которых собран текущий шелл/проект.
    # keep-derivations уже true по умолчанию.
    keep-outputs = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Дедупликация store хардлинками. Отдельным заданием, а не auto-optimise-store,
  # чтобы не замедлять каждую сборку.
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
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
