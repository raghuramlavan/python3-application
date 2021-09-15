{
  description = "(insert short project description here)";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";
  inputs.python-application={url=github:AGProjects/python3-application; flake=false;};
  outputs = { self, nixpkgs,python-application}:
    let


      supportedSystems = [ "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

          python-application = with final; python38.pkgs.buildPythonPackage rec {
          pname = "python-application";
          version = "3.0.3";
        
          src = python-application;
        
          buildInputs = with  python38Packages; [
            zope_interface
            twisted
          ];
        
          meta = with lib; {
            description = "Basic building blocks for python applications";
            homepage = https://github.com/AGProjects/python-application;
            license = licenses.lgpl2Plus;
          };
        };
      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) python-application;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.python-application);



    };
}
