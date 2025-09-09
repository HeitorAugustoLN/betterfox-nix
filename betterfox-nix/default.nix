{
  lib,
  rustPlatform,
  openssl,
  pkg-config,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "betterfox-nix";
  version = "3.0.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.lock
      ./Cargo.toml
      ./src
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/betterfox-nix";

  meta = {
    changelog = "https://github.com/HeitorAugustoLN/betterfox-nix/releases/tag/v${finalAttrs.version}";
    description = "CLI for betterfox-nix";
    homepage = "https://github.com/HeitorAugustoLN/betterfox-nix";
    license = lib.licenses.mit;
    mainProgram = "betterfox-nix";
    maintainers = [ lib.maintainers.HeitorAugustoLN ];
    platforms = lib.platforms.unix;
  };
})
