{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, qttools
, doxygen
, wrapQtAppsHook
, qtbase
, dtkcore
, qtimageformats
, lxqt
, librsvg
, libraw
}:

stdenv.mkDerivation rec {
  pname = "dtkgui";
  version = "5.6.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-uMzJYtc2hp1+gcPAsQmMeCRaFzzntqHYuqjAkDjf2hc=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  nativeBuildInputs = [
    cmake
    qttools
    doxygen
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    lxqt.libqtxdg
    librsvg
    libraw
  ];

  propagatedBuildInputs = [
    dtkcore
    qtimageformats
  ];

  cmakeFlags = [
    "-DDTK_VERSION=${if lib.versionAtLeast qtbase.version "6" then "6.0.0" else "5.6.20"}"
    "-DBUILD_DOCS=ON"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DCMAKE_INSTALL_LIBEXECDIR=${placeholder "dev"}/libexec"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
  '';

  outputs = [ "out" "dev" "doc" ];

  meta = with lib; {
    description = "Deepin Toolkit, gui module for DDE look and feel";
    homepage = "https://github.com/linuxdeepin/dtkgui";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
