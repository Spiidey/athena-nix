{ lib
, rustPlatform
, fetchFromGitHub
, stdenv
, darwin
, openssl
}:

rustPlatform.buildRustPackage {
  pname = "aegis-nix";
  version = "0-unstable-2024-02-05";

  src = fetchFromGitHub {
    owner = "Athena-OS";
    repo = "aegis-nix";
    rev = "63c85ebea16663324db45e26707e9dbc2a57fd00";
    hash = "sha256-6wYWtSDGnqWz5elbXq2GoxpJl4MDBq1r7S6KnmmsH+U=";
  };

  cargoHash = "sha256-G2nwWTyunjOXEn6LFu3cA3MfQl3i8+k0tgb+XIaiucQ=";

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  postPatch = ''
    substituteInPlace src/functions/users.rs \
      --replace "\"openssl\"" "\"${openssl}/bin/openssl\""

    # LOCAL TESTING ONLY — remove before upstreaming.
    # aegis-nix normally downloads Athena-OS/athena-nix from codeload.github.com at
    # install time. On the builder VM the fork lives at /mnt/hgfs/athena-nix via
    # VMware HGFS, so we patch the download out and copy from there instead.
    # The unzip step becomes a no-op; the subsequent cp from /tmp/athena-nix-main/
    # still works because our cp -r produces that exact path.
    substituteInPlace src/functions/base.rs \
      --replace \
      'exec(
            "curl",
            vec![
                String::from("-o"),
                String::from("/tmp/athena-nix.zip"),
                String::from("https://codeload.github.com/Athena-OS/athena-nix/zip/refs/heads/main"),
            ],
        ),
        "Getting latest Athena OS configuration.",' \
      'exec(
            "cp",
            vec![
                String::from("-r"),
                String::from("/mnt/hgfs/athena-nix"),
                String::from("/tmp/athena-nix-main"),
            ],
        ),
        "Copy local Athena OS configuration from HGFS share.",'

    substituteInPlace src/functions/base.rs \
      --replace \
      'exec(
            "unzip",
            vec![
                String::from("/tmp/athena-nix.zip"),
                String::from("-d"),
                String::from("/tmp/"),
            ],
        ),
        "Extract Athena OS configuration archive.",' \
      'exec(
            "echo",
            vec![
                String::from("Skipped: using local HGFS copy instead of zip."),
            ],
        ),
        "Skip unzip (local copy in use).",'
  '';

  meta = with lib; {
    description = "Aegis - secure, rust-based installer back-end for Athena OS";
    mainProgram = "athena-aegis";
    homepage = "https://github.com/Athena-OS/aegis-nix";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ d3vil0p3r ];
  };
}