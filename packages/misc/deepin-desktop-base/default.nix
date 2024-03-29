{ stdenvNoCC
, lib
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation rec {
  pname = "deepin-desktop-base";
  version = "2022.03.07";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-joAduRI9jUtPA4lNsEhgOZlci8j/cvD8rJThqvj6a8A=";
  };

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  # distribution_logo_transparent.svg come form nixos-artwork/logo/nixos-white.svg under CC-BY license, used for dde-lock
  postInstall = ''
    rm -r $out/etc
    rm -r $out/usr/share/python-apt
    rm -r $out/usr/share/plymouth
    rm -r $out/usr/share/distro-info
    mv $out/usr/* $out/
    rm -r $out/usr
    install -D ${./distribution_logo_transparent.svg} $out/share/pixmaps/distribution_logo_transparent.svg
  '';

  meta = with lib; {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
