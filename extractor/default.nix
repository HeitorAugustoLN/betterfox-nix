{ writeScriptBin, python3, ... }:
writeScriptBin "betterfox-extractor" ''
  #!${python3}/bin/python

  ${builtins.readFile ./extractor.py}
''
