{
  description = "ASCII NixOS Server Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    #sops-nix = {
      #url = "github:Mic92/sops-nix";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};

    #home-manager = {
      #url = "github:nix-community/home-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = { self, nixpkgs, ... }: 
  let
    hms-app-pkg = import ./hms-app/default.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };
  in 
  {
    packages.x86_64-linux.default = hms-app-pkg;
    nixosConfigurations.ascii = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit hms-app-pkg; 
      };
      modules = [
        ./configuration.nix
        #sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
