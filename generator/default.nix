{
  stdenv,
  makeWrapper,
  writeScriptBin,
  python3,
  betterfox-extractor,
  ...
}:
let
  pythonEnv = python3.withPackages (pyPkgs: with pyPkgs; [ requests ]);
  script = writeScriptBin "betterfox-generator" ''
    #!${python3}/bin/python

    ${builtins.readFile ./generator.py}
  '';
in
stdenv.mkDerivation {
  pname = "betterfox-generator";
  version = "1.0";
  src = script;
  dontUnpack = true;
  buildInputs = [
    pythonEnv
    betterfox-extractor
    makeWrapper
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src/bin/betterfox-generator $out/bin
    wrapProgram $out/bin/betterfox-generator \
      --prefix PYTHONPATH : ${pythonEnv}/${python3.sitePackages} \
      --prefix PATH : ${betterfox-extractor}/bin
  '';
}
