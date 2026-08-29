# Загрузчик: GRUB (EFI) + тема.
{ pkgs, ... }:

let
  falloutGrubTheme = pkgs.fetchFromGitHub {
    owner = "shvchk";
    repo = "fallout-grub-theme";
    rev = "2c51d28701c03c389309e34585ca8ff2b68c23e9";
    sha256 = "sha256-iQU1Rv7Q0BFdsIX9c7mxDhhYaWemuaNRYs+sR1DF0Rc=";
  };
in

{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;

    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev"; # EFI-режим: GRUB не пишется в MBR
      configurationLimit = 5;
      useOSProber = true;
      theme = "${falloutGrubTheme}";
    };
  };
}
