{
  description = "msxrom2vhd";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages = rec {
          msxrom2vhd = with pkgs; stdenv.mkDerivation {
            name = "msxrom2vhd";
            version = "1.1";
            src = ./.;
            nativeBuildInputs = [ automake autoconf xxd ];
            buildInputs = [ libguestfs-with-appliance ];
            preConfigure = ''
              ./autoconf.sh
            '';
            meta = {
              mainProgram = "msxrom2vhd";
            };
          };
          webapp = pkgs.callPackage (import ./webapp) { inherit msxrom2vhd; };
          docker = pkgs.dockerTools.buildImage {
            name = "msxrom2vhd-web";
            config = {
              Cmd = [ "${webapp}/bin/start-server" ];
            };
          };
        };
        defaultPackage = packages.msxrom2vhd;
#        apps.msxrom2vhd = flake-utils.lib.mkApp { drv = packages.msxrom2vhd; };
#        apps.default = apps.msxrom2vhd;
      }
    );
}
