{
  description = "fess932 — NixOS + home-manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs"; # чтобы Niri использовал те же пакеты
    };

    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Единственное место, где пакеты из flake-инпутов попадают в `pkgs`.
      # Дальше по конфигу они доступны просто как pkgs.<name>.
      overlays = [
        inputs.niri.overlays.niri
        inputs.claude-code.overlays.default # свежий claude-code вместо версии из nixpkgs
        (import ./pkgs) # собственные пакеты -> pkgs.local.*
      ];
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        # Инпуты прокидываем целиком — модули берут из них то, что им нужно.
        specialArgs = { inherit inputs system; };

        modules = [
          { nixpkgs.overlays = overlays; }

          ./hosts/nixos

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true; # HM берёт тот же pkgs (с оверлеями), что и система
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs; };
              users.fess932 = import ./home;
            };
          }
        ];
      };
    };
}
