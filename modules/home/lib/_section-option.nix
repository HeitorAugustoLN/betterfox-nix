{ lib, ... }:
name: section:
let
  sectionType = import ./_section-type.nix { inherit lib; };
in
lib.mkOption {
  type = sectionType name section;
  default = { };
  description = "${name}: ${section.meta.title}.";
}
