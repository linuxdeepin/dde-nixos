{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qtbase
, libmediainfo
, libsecret
, libisoburn
, libuuid
, udisks
}:

stdenv.mkDerivation rec {
  pname = "util-dfm";
  version = "1.2.13";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-AwRJ1ov7UaphcVw6Usl/H5FSpc3KEZ+HULao9my1wRM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qtbase
    libmediainfo
    libsecret
    libuuid
    libisoburn
    udisks
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DPROJECT_VERSION=${version}"
  ];

  meta = with lib; {
    description = "A Toolkits of libdfm-io,libdfm-mount and libdfm-burn";
    homepage = "https://github.com/linuxdeepin/util-dfm";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
