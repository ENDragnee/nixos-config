{
  description = "ASCII NixOS Server Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.ascii = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  services.postgresql = {
    enable = true;
    initialScript = pkgs.writeText "init-db" ''
      CREATE ROLE hms_user WITH LOGIN PASSWORD '...';
      CREATE DATABASE hms_db WITH OWNER = hms_user;
    '';
    };
  services.nginx = {
    enable = true;
    virtualHosts."hms.local" = {
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://localhost:3000";
        };
      };
    };
  systemd.services.hms-app = {
    # This service will start after the network and database are ready
    after = [ "network-online.target" "postgresql.service" ];
    wants = [ "network-online.target" "postgresql.service" ];

    # The command to start your app
    # (Assumes you've built your Next.js app with Nix)
    script = ''
      # Set database credentials and other secrets here
      export DATABASE_URL="postgres://hms_user:password@localhost/hms_db"
      # Run the production server from the Nix build output of your app
      exec ${pkgs.my-hms-app}/bin/start-server
    '';

    # Run the service as a dedicated, unprivileged user for security
    serviceConfig = {
      User = "hms";
      Group = "hms";
      Restart = "always"; # Automatically restart if it crashes
      };
    };
  };
  users.users.hms = {
    isSystemUser = true;
    group = "hms";
  };
  users.groups.hms = {};
}
