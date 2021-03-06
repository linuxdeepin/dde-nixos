{ stdenv
, lib
, fetchFromGitHub
, buildGoPackage
, pkgconfig
, deepin-gettext-tools
, go
, go-dbus-factory
, go-gir-generator
, go-lib
, gtk3
, glib
, gettext
, iniparser
, cracklib
, linux-pam
}:

buildGoPackage rec {
  pname = "deepin-pw-check";
  version = "5.1.11";

  goPackagePath = "github.com/linuxdeepin/deepin-pw-check";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-h+zW7uyTWep+nCbc4RvIgWddsqpO5ZbXvXDPiZ6z6gY=";
  };

  goDeps = ./deps.nix;

  nativeBuildInputs = [
    pkgconfig
    gettext
    deepin-gettext-tools
  ];

  buildInputs = [
    go-dbus-factory
    go-gir-generator
    go-lib
    glib
    gtk3
    iniparser
    cracklib
    linux-pam
  ];

  hardeningDisable = [ "all" ]; ## FIXME

  postPatch = ''
    sed -i 's|iniparser/||' */*.c
    substituteInPlace misc/pkgconfig/libdeepin_pw_check.pc \
      --replace "/usr" "$out" \
      --replace "Version: 0.0.0.1" "Version: ${version}"
    
    substituteInPlace misc/system-services/com.deepin.daemon.PasswdConf.service \
      --replace "/usr/lib/deepin-pw-check/deepin-pw-check" "$out/lib/deepin-pw-check/deepin-pw-check"
  '';

  buildPhase = ''
    runHook preBuild
    GOPATH="$GOPATH:${go-dbus-factory}/share/gocode"
    GOPATH="$GOPATH:${go-gir-generator}/share/gocode"
    GOPATH="$GOPATH:${go-lib}/share/gocode"
    make -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" PKG_FILE_DIR="/lib/pkgconfig" -C go/src/${goPackagePath}
    ln -s $out/lib/libdeepin_pw_check.so $out/lib/libdeepin_pw_check.so.1
  '';

  meta = with lib; {
    description = "a tool to verify the validity of the password";
    homepage = "https://github.com/linuxdeepin/deepin-pw-check";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
