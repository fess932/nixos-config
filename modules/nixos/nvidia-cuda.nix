# NVIDIA-драйвер, Vulkan/VA-API и тулчейн для сборки CUDA-кода.
{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false; # если зависает — попробовать переключить
    modesetting.enable = true; # обязателен для Wayland

    # Экспериментально и ломает suspend. Включать, только если после
    # пробуждения артефакты или падают приложения.
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    nvidiaSettings = true;
  };

  hardware.graphics = {
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

  environment.systemPackages = with pkgs; [
    cudaPackages_12_8.cudatoolkit
    cudaPackages_12_8.cudnn
    pciutils
    vulkan-tools
    nvtopPackages.nvidia

    # nvcc из 12.8 не дружит с современным gcc — держим 13-й рядом
    # и под именами, которые ждут cmake-скрипты.
    gcc13
    (runCommand "gcc13-compat" { } ''
      mkdir -p $out/bin
      ln -s ${gcc13}/bin/gcc $out/bin/gcc-13
      ln -s ${gcc13}/bin/g++ $out/bin/g++-13
      ln -s ${gcc13}/bin/cpp $out/bin/cpp-13
    '')
    ninja
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  environment.variables = {
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
    CUDA_HOME = "${pkgs.cudaPackages_12_8.cudatoolkit}";
    CUDA_PATH = "${pkgs.cudaPackages_12_8.cudatoolkit}";
    CUDAHOSTCXX = "${pkgs.gcc13}/bin/g++";
  };

  systemd.tmpfiles.rules = [
    # L+  = "создать/обновить симлинк"
    # /usr/src/linux-source-* — путь, который ждут внешние build-системы модулей ядра
    "L+ /usr/src/linux-source-${config.boot.kernelPackages.kernel.version} - - - - ${config.boot.kernelPackages.kernel.src}"
  ];
}
