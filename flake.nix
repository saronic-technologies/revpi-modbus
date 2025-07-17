{
  description = "revpi-modbus development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
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
