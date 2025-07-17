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
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "revpi-modbus";
          version = "1.0.0";
          
          src = ./.;
          
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
            echo "revpi-modbus development environment"
            echo "Generating compile_commands.json..."
            rm -rf .compile_commands_build
            bear -- cmake -B .compile_commands_build -S .
            bear -- cmake --build .compile_commands_build
            echo "compile_commands.json generated successfully!"
          '';
        };
      });
}
