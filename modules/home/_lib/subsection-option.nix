{ lib, ... }:
name: subsection:
let
  subsectionType = import ./subsection-type.nix { inherit lib; };
in
lib.mkOption {
  type = subsectionType name subsection;
  default = { };
  description = "${name}: ${subsection.meta.title}.";
}
