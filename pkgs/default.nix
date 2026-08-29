# Оверлей с собственными пакетами.
# Всё, что тут объявлено, доступно в конфиге как pkgs.local.<name>.
final: _prev: {
  local = {
    # WIP: ручная сборка CUDA 13 из runfile-инсталлятора.
    cuda-13 = import ./cuda-13 { pkgs = final; };
  };
}
