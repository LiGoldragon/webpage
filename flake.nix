{
  description = "Static site for Li Goldragon built with Hugo and PaperMod";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    papermod = {
      url = "github:adityatelange/hugo-PaperMod";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      papermod,
    }:
    let
      canonicalDomain = "https://ligoldragon.com";
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          theme = papermod;
        in
        {
          site = pkgs.stdenv.mkDerivation {
            pname = "ligoldragon-site";
            version = "1.0.0";
            src = self;
            nativeBuildInputs = [ pkgs.hugo ];
            buildPhase = ''
              mkdir -p themes
              ln -s ${theme} themes/PaperMod
              hugo --minify --destination $out --baseURL ${canonicalDomain}
            '';
            installPhase = "";
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          theme = papermod;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [ pkgs.hugo ];
            shellHook = ''
              mkdir -p themes
              ln -sfn ${theme} themes/PaperMod
              echo "PaperMod theme available at themes/PaperMod (from nix input)."
            '';
          };
        }
      );
    };
}
