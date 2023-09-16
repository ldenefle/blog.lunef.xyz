{
  description = "Lucas Denefle's blog";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        packageName = "blog-lunef-xyz";
        version = "0.0.0";

        pkgs = import nixpkgs {
          inherit system;
        };

        deps = with pkgs;
          [
            hugo
          ];

        shell = pkgs.mkShell {
          name = packageName + "-env";
          buildInputs = deps;
        };

        blog = pkgs.stdenv.mkDerivation {
          name = packageName;
          version = version;
          src = ./.;

          buildInputs = [pkgs.hugo];
          dontConfigure = true;

          # Copy source into working directory and 
          buildPhase = ''
              cp -r $src/* .
              # I need to specify the config because only more recent builds of hugo
              # look for a file named hugo.toml.
              ${pkgs.hugo}/bin/hugo version
              ${pkgs.hugo}/bin/hugo --config hugo.toml
          '';

          installPhase = ''
              mkdir -p $out
              cp -r public/* $out/
          '';
        };
      in {
        # Used with nix develop
        devShell = shell;

        defaultPackage = self.packages.${system}.${packageName};

        # Use with nix build . generates CI docker
        packages.default = blog;
      });
}
