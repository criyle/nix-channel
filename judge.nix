# Note: this file is used to construct HydroOJ judge rootfs.
{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { system = system; }
, minimal ? false
}:

let
  gcc = import ./gccWithCache.nix { inherit pkgs; inherit system; };
  php = pkgs.php.withExtensions ({ enabled, all }: [ ]);
  cyaron = import ./cyaron.nix { inherit pkgs; inherit system; };
  xeger = import ./xeger.nix { inherit pkgs; inherit system; };
  locales = (pkgs.glibcLocales.override { locales = [ "zh_CN.UTF-8" "en_US.UTF-8" ]; });
in
pkgs.buildEnv {
  name = "judge${if minimal then "-minimal" else ""}";
  paths = [
    pkgs.coreutils
    pkgs.bash
    pkgs.diffutils
    pkgs.nix
    pkgs.zip
    pkgs.unzip
    gcc
    pkgs.fpc
    pkgs.glibc
    locales
  ] ++ (if !minimal then
    ((with pkgs; [
      gdb
      ghc
      rustc
      sqlite
      kotlin
      go
      nodejs
      esbuild
      openjdk_headless
      ruby
      mono
      verilog
      gbenchmark
      python3Full
      pypy3
      ghostscript
      xvfb-run
      cimg
      qemu
    ]) ++ [
      php
    ] ++ (with pkgs.python3Packages; [
      pandas
      pytz
      dateutil
      six
      numpy
      tkinter
      pillow
      xeger
      cyaron
    ])) else [ ]) ++ (if system == "x86_64-linux" then [
    pkgs.julia-bin
    pkgs.R
  ] else [ ]);
  ignoreCollisions = true;
  pathsToLink = [ "/" ];
  postBuild = ''
    mkdir $out/buildInfo
    echo 'root:x:0:0:root:/root:/bin/bash' >$out/etc/passwd
    date >$out/buildInfo/timestamp
    ln -sf ${locales}/lib/locale/locale-archive $out/lib/locale
  '';
}
