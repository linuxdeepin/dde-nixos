{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, gsettings-qt
, gtest
, wrapQtAppsHook
, lshw
, dtkcommon
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.5.32+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "702a43dd09d8e4cdf951ada6655eca8b91e09650";
    sha256 = "sha256-bzOkOQhyWeTuy0xhyFKydaOX880Side4iab4g2b7Mok=";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    gsettings-qt
    gtest
    lshw
    dtkcommon
  ];

  # DEFINES += PREFIX=\\\"$$INSTALL_PREFIX\\\"  path of dsg
  postPatch = ''
    substituteInPlace src/filesystem/filesystem.pri \
      --replace '$$INSTALL_PREFIX' "'/run/current-system/sw'"

    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
      --replace 'lshw.start("lshw"' 'lshw.start("${lshw}/bin/lshw"'
  '';

  qmakeFlags = [
    "LIB_INSTALL_DIR=${placeholder "out"}/lib"
    "MKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs"
  ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
  };
}
