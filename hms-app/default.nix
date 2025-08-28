# ~/nixos-config/hms-app/default.nix

# This function takes the Nix packages set (`pkgs`) as an argument
{ pkgs }:

# We use buildNpmPackage, a helper designed for Node.js projects
pkgs.buildNpmPackage {
  # The name and version of our package
  pname = "hms-app";
  version = "0.1.0";

  # The source code for the package is the current directory
  src = ./.;

  # This is the magic for reproducible Node.js builds.
  # It's a hash of your package-lock.json.
  # We will generate this hash in a moment.
  npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  # Nix runs a build in a clean, empty environment. We need to tell it
  # what tools are required during the build process.
  nativeBuildInputs = [ pkgs.makeWrapper ];

  # By default, buildNpmPackage runs `npm run build`.
  # This is exactly what Next.js needs, so we don't have to specify a buildPhase.

  # The installPhase is where we copy the finished build artifacts
  # into the final output directory ($out).
  installPhase = ''
    runHook preInstall

    # Copy the essential runtime files from our build directory to the final destination
    cp -R ./.next ./public ./package.json ./node_modules $out

    # Create a simple executable script to start the server.
    # This makes our systemd service much cleaner.
    makeWrapper ${pkgs.nodejs}/bin/node $out/bin/start-server \
      --add-flags "$out/node_modules/next/dist/bin/next" \
      --add-flags "start"

    runHook postInstall
  '';
}
