# Железо, не связанное с видеокартой: звук, bluetooth, OOM-killer.
{ ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true; # связь с драйверами ALSA в ядре
    alsa.support32Bit = true; # чтобы работали 32-битные игры (Steam и пр.)
    pulse.enable = true; # слой совместимости для программ, ожидающих PulseAudio
    wireplumber.enable = true; # менеджер сессий — обязателен
  };

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 10; # % RAM, при котором earlyoom начнёт действовать
  };

  # Кор-дампы не храним: символов контейнерных бинарей на хосте всё равно нет,
  # а образ падающего процесса пишется ровно в нехватку памяти. Строка
  # "dumped core" в журнале остаётся.
  systemd.coredump.settings.Coredump = {
    Storage = "none";
    ProcessSizeMax = 0;
  };
}
