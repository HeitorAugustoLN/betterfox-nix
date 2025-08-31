{ lib, ... }:
name: subsection:
let
  subsectionType = import ./_subsection-type.nix { inherit lib; };
in
lib.mkOption {
  default = { };
  description = "${name}: ${subsection.meta.title}";
  type = subsectionType name subsection;
}
