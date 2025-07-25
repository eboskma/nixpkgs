{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "openscad-lsp";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "Leathong";
    repo = "openscad-LSP";
    rev = "dc1283df080b981f8da620744b0fb53b22f2eb84";
    hash = "sha256-IPTBWX0kKmusijg4xAvS1Ysi9WydFaUWx/BkZbMvgJk=";
  };

  cargoHash = "sha256-qHwtLZUM9FrzDmg9prVtSf19KtEp8cZO/7XoXtZb5IQ=";

  # no tests exist
  doCheck = false;

  meta = with lib; {
    description = "LSP (Language Server Protocol) server for OpenSCAD";
    mainProgram = "openscad-lsp";
    homepage = "https://github.com/Leathong/openscad-LSP";
    license = licenses.asl20;
    maintainers = with maintainers; [ c-h-johnson ];
  };
}
