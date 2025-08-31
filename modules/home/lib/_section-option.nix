{ lib, ... }:
name: section:
let
  sectionType = import ./_section-type.nix { inherit lib; };
in
lib.mkOption {
  default = { };
  description = "${name}: ${section.meta.title}";
  type = sectionType name section;
}
