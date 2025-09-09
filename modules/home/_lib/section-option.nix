{ lib, ... }:
name: section:
let
  sectionType = import ./section-type.nix { inherit lib; };
in
lib.mkOption {
  type = sectionType name section;
  default = { };
  description = "${name}: ${section.meta.title}.";
}
