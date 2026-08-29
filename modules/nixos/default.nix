# Точка сборки системных модулей. Хост подключает только этот файл.
{
  imports = [
    ./boot.nix
    ./nix.nix
    ./hardware.nix
    ./nvidia-cuda.nix
    ./desktop.nix
    ./virtualisation.nix
    ./users.nix
    ./packages.nix
  ];
}
