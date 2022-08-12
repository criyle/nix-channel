{ 
  pkgs ? import <nixpkgs> { system = "x86_64-linux"; },
  version ? "5.0.6",
  type ? "server",
  mirror ? "https://repo.mongodb.org/"
}:

let
  sversion = pkgs.lib.splitString "." version;
  major = pkgs.lib.elemAt sversion 0;
  minor = pkgs.lib.elemAt sversion 1;
  sha256dict = {
    "server4.4.15" = "sha256-BtqsK0A+lL8GajRc2WDMUESVEsTDk4e3ULAhVTIkI8U=";
    "server5.0.10" = "sha256-NV+a1bBdY5z2559cJYgNYlTvoRfGHVWrvmyWcCLgxls=";
    "server6.0.0" = "sha256-AJUQ8Jo/T4PDnYtFg3njUZyoH9XXzleZ+nj/knCBKzg=";
    "shell4.4.15" = "sha256-kFNfKgYiK8RMD9ztD0yYvVcjbuW9031WaW2n5kRoHJI=";
    "shell5.0.10" = "sha256-tXcN0/Q4XZsQHGjpXSxT+wg52QlKKleJElwEb/CEMuQ=";
    # "shell6.0.0" = "sha256-ONTxTi7ezZi0BwPq+tjAuVS0HUw0sLW9u+883BfjNZo=";
  };
  namedict = {
    "server" = "mongodb";
    "shell" = "mongosh";
  };
  binaryName = {
    "server" = "mongod";
    "shell" = "mongo";
  };
  versionDetail = pkgs.lib.concatStrings [type version];
in pkgs.stdenv.mkDerivation {
  name = "${pkgs.lib.getAttr type namedict}-${version}";
  system = "x86_64-linux";
  src = pkgs.fetchurl {
    url = "${mirror}apt/ubuntu/dists/focal/mongodb-org/${major}.${minor}/multiverse/binary-amd64/mongodb-org-${type}_${version}_amd64.deb";
    sha256 = if pkgs.lib.hasAttr versionDetail sha256dict then pkgs.lib.getAttr versionDetail sha256dict else "";
  };
  nativeBuildInputs = [
    pkgs.autoPatchelfHook 
    pkgs.dpkg
  ];
  buildInputs = [
    pkgs.openssl # libcrypto.so.1.1 libssl.so.1.1
    pkgs.xz # liblzma.so.5
    pkgs.curl # libcurl.so.4
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    mkdir $out/bin
    mv $out/usr/bin/${pkgs.lib.getAttr type binaryName} $out/bin/${pkgs.lib.getAttr type binaryName}
  '';

  meta = {
    description = "MongoDB";
    homepage = https://www.mongodb.com/;
    maintainers = [ "undefined <i@undefined.moe>" ];
    platforms = [ "x86_64-linux" ];
  };
}