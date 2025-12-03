{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) {}
}:


let
  ocamlPackages = pkgs.ocamlPackages;

  goblint-cil = ocamlPackages.buildDunePackage (finalAttrs: {
    pname = "goblint-cil";
    version = "2.0.6";

    src = pkgs.fetchurl {
      url = "https://github.com/goblint/cil/releases/download/${finalAttrs.version}/goblint-cil-${finalAttrs.version}.tbz";
      hash = "sha256-VXcAe/rGPD8GCavbdBGf5nTJvIUp15DpDvc6hZZKoHo=";
    };

    nativeBuildInputs = with ocamlPackages; [
      cppo
      dune_3
      ocaml
      pkgs.perl
    ];

    propagatedBuildInputs = with ocamlPackages; [
      batteries
      dune-configurator
      findlib
      ppx_deriving_yojson
      zarith
    ];
  });

  frama-c-lannotate = ocamlPackages.buildDunePackage (finalAttrs: {
    pname = "frama-c-lannotate";
    version = "0.2.4";

    src = pkgs.fetchzip {
      url = "https://git.frama-c.com/pub/ltest/lannotate/-/archive/${finalAttrs.version}/lannotate-${finalAttrs.version}.tar.bz2";
      hash = "sha256-JoD2M3R3/DcUMt33QOvwqHg4eToCgjB8riKc09TWdyc=";
    };

    propagatedBuildInputs = [
      ocamlPackages.dune-site
      ((pkgs.framac.override { inherit ocamlPackages; }).overrideAttrs {
        postInstall = ''
          dune install --prefix $out --libdir $OCAMLFIND_DESTDIR frama-c
        '';
      })
    ];
  });

in

pkgs.mkShell {
  dontDetectOcamlConflicts = true;
  buildInputs = with pkgs.ocamlPackages; [
    cppo
    crunch
    dune_3
    dune-glob
    findlib
    menhir
    ocaml
    ppx_assert
    ppx_expect
    ppx_inline_test
    pkgs.llvmPackages.clang-unwrapped
  ];
  nativeBuildInputs = with pkgs.ocamlPackages; [
    cmdliner
    ctypes
    fmt
    goblint-cil
    frama-c-lannotate
    inotify
    json-data-encoding
    logs
    lwt
    terminal_size
    toml
    yojson
    pkgs.llvmPackages.clang-unwrapped
  ];
}
