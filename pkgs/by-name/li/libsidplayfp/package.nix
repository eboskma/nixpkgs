{
  stdenv,
  lib,
  fetchFromGitHub,
  makeFontsConf,
  nix-update-script,
  testers,
  autoreconfHook,
  docSupport ? true,
  doxygen,
  graphviz,
  libexsid,
  libgcrypt,
  perl,
  pkg-config,
  unittest-cpp,
  xa,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsidplayfp";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "libsidplayfp";
    repo = "libsidplayfp";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-rK7Il8WE4AJbn7GKn21fXr1o+DDdyOjfJ0saeqcZ5Pg=";
  };

  outputs = [ "out" ] ++ lib.optionals docSupport [ "doc" ];

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    perl
    pkg-config
    xa
  ]
  ++ lib.optionals docSupport [
    doxygen
    graphviz
  ];

  buildInputs = [
    libexsid
    libgcrypt
  ];

  checkInputs = [ unittest-cpp ];

  enableParallelBuilding = true;

  configureFlags = [
    (lib.strings.enableFeature true "hardsid")
    (lib.strings.withFeature true "gcrypt")
    (lib.strings.withFeature true "exsid")
    (lib.strings.enableFeature finalAttrs.finalPackage.doCheck "tests")
  ];

  # Make Doxygen happy with the setup, reduce log noise
  env.FONTCONFIG_FILE = lib.optionalString docSupport (makeFontsConf {
    fontDirectories = [ ];
  });

  preBuild = ''
    # Reduce noise from fontconfig during doc building
    export XDG_CACHE_HOME=$TMPDIR
  '';

  buildFlags = [ "all" ] ++ lib.optionals docSupport [ "doc" ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = lib.optionalString docSupport ''
    mkdir -p $doc/share/doc/libsidplayfp
    mv docs/html $doc/share/doc/libsidplayfp/
  '';

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Library to play Commodore 64 music derived from libsidplay2";
    longDescription = ''
      libsidplayfp is a C64 music player library which integrates
      the reSID SID chip emulation into a cycle-based emulator
      environment, constantly aiming to improve emulation of the
      C64 system and the SID chips.
    '';
    homepage = "https://github.com/libsidplayfp/libsidplayfp";
    changelog = "https://github.com/libsidplayfp/libsidplayfp/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [
      ramkromberg
      OPNA2608
    ];
    platforms = lib.platforms.all;
    pkgConfigModules = [
      "libsidplayfp"
      "libstilview"
    ];
  };
})
