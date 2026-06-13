{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, efivar
, tpm2-tss
}:

rustPlatform.buildRustPackage {
  pname = "dory";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Athena-OS";
    repo = "dory";
    rev = "8f074da596baaf0cee7d6291ea8c7e02e9521bd6";
    hash = "sha256-3jFf4xKc4T2gxHYMp0a6v5LouZ55OhUA5oO6otRcB5M=";
  };

  cargoHash = "sha256-YIQdDnKSfK42uORIQweuALNmdeVL7mRz1iF11Rb1foA=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ efivar tpm2-tss ];

  meta = with lib; {
    description = "Secure, Rust-based TUI installer for Athena OS";
    homepage = "https://github.com/Athena-OS/dory";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
