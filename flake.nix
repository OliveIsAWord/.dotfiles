{
  description = "My NixOS system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    wrapper-manager = {
      url = "github:viperML/wrapper-manager";
      # WM's nixpkgs is only used for tests, you can safely drop this if needed.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;
    mySystem = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${mySystem};
  in {
    nixosConfigurations = {
      vespera = lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          wrappers = self.packages.${mySystem};
        };
        system = mySystem;
        modules = [
          ./configuration.nix
        ];
      };
    };

    packages.${mySystem} = (import ./wrapped) {
      inherit inputs pkgs;
    };

    formatter.${mySystem} = pkgs.alejandra;
  };
}
