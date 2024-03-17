{
  description = "Lucas Denefle's blog";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        name = "blog-lunef-xyz";
        version = "0.0.0";

        pkgs = import nixpkgs {
          inherit system;
        };

        deps = with pkgs;
          [
            hugo
          ];

        shell = with pkgs; mkShell {
          name = name + "-env";
          buildInputs = deps ++ [
            (writeScriptBin "serve" ''
              hugo server --navigateToChanged --config ${(builtins.toString ./.) + "/hugo.toml"}
            '')
          ];
        };

        blog = pkgs.stdenv.mkDerivation {
          inherit name;
          inherit version;
          src = ./.;

          buildPhase = ''
              cp -r $src/* .
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

        defaultPackage = self.packages.${system}.${name};

        # Use with nix build . generates CI docker
        packages.default = blog;
      });
}
