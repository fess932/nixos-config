{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation {
  pname = "cuda-13";
  version = "13.2";

  #	src = pkgs.fetchurl {
  #		url = "https://developer.download.nvidia.com/compute/cuda/13.2.0/local_installers/cuda_13.2.0_595.45.04_linux.run";
  #    sha256 = "sha256-xZm2UVgsjzRevee88Im33PzYr9fT6n9QUlaYxWOiOdc=";
  #  };

  src = pkgs.fetchurl {
    url = "https://developer.download.nvidia.com/compute/cuda/13.0.0/local_installers/cuda_13.0.0_580.65.06_linux.run";
    sha256 = "sha256-xklp81rZm/P56Ky449IjVRUMbKB6zBaoU3eGAKm2W6Y=";
  };

  nativeBuildInputs = [
    pkgs.autoPatchelfHook
  ];
  buildInputs = [
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
    pkgs.libGL
    pkgs.libx11
    pkgs.libxml2
  ];

  autoPatchelfIgnoreMissingDeps = true;

  unpackPhase = ''
      	mkdir extracted
      	cd extracted
      	# извлекаем runfile как архив
     		sh $src --noexec --target .
      	cd ..
    	'';

  installPhase = ''
      mkdir -p $out
      cp -r extracted/* $out/
      rm -rf $out/builds/nsight_compute
      rm -rf $out/builds/nsight_systems
      rm -rf $out/builds/cuda_documentation
      rm -rf $out/builds/libcufile
      rm -rf $out/builds/libcuobjclient
      rm -rf $out/builds/cuda_gdb
      rm -rf $out/builds/bin/cuda-uninstaller
      rm -rf $out/builds/bin/ko-uninstaller
      rm -f $out/cuda-installerш
    	mkdir -p $out/bin
      ln -s $out/builds/cuda_nvcc/bin/nvcc $out/bin/nvcc

      # unified include/ and lib/ для компиляторов
      mkdir -p $out/include $out/lib
      for d in $out/builds/*/include; do
        cp -rn $d/. $out/include/ || true
      done
      for d in $out/builds/*/lib; do
        cp -rn $d/. $out/lib/ || true
      done
      for d in $out/builds/*/lib64; do
        cp -rn $d/. $out/lib/ || true
      done

      chmod -R +w $out
  '';

  setupHook = pkgs.writeText "setup-hook.sh" ''
    export CUDA_HOME=@out@
    export CUDA_PATH=@out@
    export C_INCLUDE_PATH=@out@/include:$C_INCLUDE_PATH
    export CPLUS_INCLUDE_PATH=@out@/include:$CPLUS_INCLUDE_PATH
    export LIBRARY_PATH=@out@/lib:$LIBRARY_PATH
    export LD_LIBRARY_PATH=@out@/lib:$LD_LIBRARY_PATH
  '';

  meta = {
    description = "CUDA 13 Toolkit";
    license = pkgs.lib.licenses.unfree;
  };
}
