{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, qttools
, doxygen
, wrapQtAppsHook
, qtbase
, gsettings-qt
, lshw
, libuchardet
, spdlog
, dtkcommon
, systemd
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd
}:

stdenv.mkDerivation rec {
  pname = "dtkcore";
  version = "5.6.20";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-4gSGoQFycZPFwj+Kb5fDpzYF2zEEdMM8ZI2U3cYXsmU=";
  };

  patches = [
    ./fix-pkgconfig-path.patch
    ./fix-pri-path.patch
  ];

  postPatch = ''
    substituteInPlace src/dsysinfo.cpp \
      --replace "/usr/share/deepin/distribution.info" "/etc/distribution.info" \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    doxygen
    wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  buildInputs = [
    qtbase
    gsettings-qt
    lshw
    libuchardet
    spdlog
  ]
  ++ lib.optional withSystemd systemd;

  propagatedBuildInputs = [ dtkcommon ];

  cmakeFlags = [
    "-DDTK_VERSION=${if lib.versionAtLeast qtbase.version "6" then "6.0.0" else "5.6.20"}"
    "-DBUILD_DOCS=ON"
    "-DBUILD_EXAMPLES=OFF"
    "-DQCH_INSTALL_DESTINATION=${placeholder "doc"}/share/doc"
    "-DDSG_PREFIX_PATH='/run/current-system/sw'"
    "-DMKSPECS_INSTALL_DIR=${placeholder "out"}/mkspecs/modules"
    "-DCMAKE_INSTALL_LIBEXECDIR=${placeholder "dev"}/libexec"
    "-DD_DSG_APP_DATA_FALLBACK=/var/dsg/appdata"
    "-DBUILD_WITH_SYSTEMD=${if withSystemd then "ON" else "OFF"}"
  ];

  preConfigure = ''
    # qt.qpa.plugin: Could not find the Qt platform plugin "minimal"
    # A workaround is to set QT_PLUGIN_PATH explicitly
    export QT_PLUGIN_PATH=${lib.getBin qtbase}/${qtbase.qtPluginPrefix}
  '';

  outputs = [ "out" "dev" "doc" ];

  meta = with lib; {
    description = "Deepin tool kit core library";
    homepage = "https://github.com/linuxdeepin/dtkcore";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
