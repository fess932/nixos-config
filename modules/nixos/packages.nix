# Базовый набор CLI, который должен быть у root и до входа в графику.
# Всё «пользовательское» ставится через home-manager (modules/home).
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gnumake
    htop
    file
    bat
    gdu
    tmux
    openssl
    microfetch

    google-chrome

    pavucontrol
    alsa-utils
    sox
    ffmpeg

    uv
    xwayland-satellite
  ];
}
