{
  description = "revpi-modbus development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # We can only compile and run this on ARM Linux, as that
      # is what it is running on, so it expects specific headers and
      # such
      supported_systems = [ flake-utils.lib.system.aarch64-linux ];
    in 
    flake-utils.lib.eachSystem supported_systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation rec {
          pname = "revpi-modbus";
          version = "1.0.0";
          
          src = ./.;
            
          # !!! WHY DOESN'T NIX COPY SUBMODULE CODE IN BY DEFAULT?!?! 
          # !!! We have to fetch it ourselves and do a postUnpack step,
          # !!! which is really annoying
          piControlSrc = pkgs.fetchFromGitHub {
            owner = "RevolutionPi";
            repo = "piControl";
            # The source code demands this specific revision, as it has the piTest code in it as
            # well to read/write from the piControl kernel module.  Gross.
            rev = "2324c1f8ebfae7cc8e74ba389269d8ff0d9d3066";
            sha256 = "sha256-UODRNcAFp3TeQkWA0WMI74SwayaID3bxNpRm1fo42zw=";
          };
          
          postUnpack = ''
            cp -r ${piControlSrc} $sourceRoot/piControl
            chmod -R u+w $sourceRoot/piControl
          '';
          
          nativeBuildInputs = with pkgs; [
            cmake
            pkg-config
          ];
          
          buildInputs = with pkgs; [
            libmodbus
            json_c
          ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            gcc
            pkg-config
            libmodbus
            json_c
            bear
          ];

          shellHook = ''
            echo "revpi-modbus dev environment"
            echo "Generating compile_commands.json..."
            rm -rf .compile_commands_build
            bear -- cmake -B .compile_commands_build -S .
            bear -- cmake --build .compile_commands_build
            echo "compile_commands.json generated successfully!"
          '';
        };
      });
}
