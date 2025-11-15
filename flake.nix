{
  description = "NixOS from Scratch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      # inputs.nixpkgs.follows = "nixpkgs"; # чтобы Niri использовал те же пакеты
    };

    niri-switch = {
      url = "github:Kiki-Bouba-Team/niri-switch"; # когода будет nix обновление может выйти родной переключатель окон
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      noctalia,
      niri,
      niri-switch,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit system niri; };
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              inherit noctalia niri niri-switch;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.fess932 = import ./home.nix;
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
