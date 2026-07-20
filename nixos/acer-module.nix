{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  lld,
}:
stdenv.mkDerivation rec {
  name = "acer-predator-turbo-and-rgb-keyboard-linux-module-${version}-${kernel.modDirVersion}";
  version = "main";
  src = fetchFromGitHub {
    owner = "JafarAkhondali";
    repo = "acer-predator-turbo-and-rgb-keyboard-linux-module";
    rev = "${version}";
    sha256 = "sha256-TGBo9GxVJ74mOnqpkjZRFk0e7XiT6iZbVyMeDmRXLyk=";
  };
  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [lld];
  makeFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
    "CC=clang"
    "LD=ld.lld"
  ];
  NIX_CFLAGS_COMPILE = "-Wno-unused-command-line-argument";
  buildFlags = ["modules"];
  installFlags = ["INSTALL_MOD_PATH=$(out)"];
  installTargets = ["modules_install"];
  meta = with lib; {
    description = "Improved Linux driver for Acer RGB Keyboards";
    homepage = "https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };
}
