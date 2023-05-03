{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, runtimeShell
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dde-calendar";
  version = "5.8.30";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-8/UXq9W3Gb1Lg/nOji6zcHJts6lgY2uDxvrBxQs3Zio=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-calendar/commit/b9d9555d90a36318eeee62ece49250b4bf8acd10.patch";
      sha256 = "sha256-pvgxZPczs/lkwNjysNuVu+1AY69VZlxOn7hR9A02/3M=";
    })
  ];

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(tests)" ""
  '';

  fixServicePath = ''
    substituteInPlace calendar-service/assets/data/com.dde.calendarserver.calendar.service \
      --replace "/bin/bash" "${runtimeShell}"
    substituteInPlace calendar-service/assets/dde-calendar-service.desktop \
      --replace "/bin/bash" "${runtimeShell}"

    substituteInPlace calendar-service/assets/data/com.deepin.dataserver.Calendar.service \
      --replace "/usr/lib/deepin-daemon/dde-calendar-service" "$out/lib/deepin-daemon/dde-calendar-service" 
    substituteInPlace calendar-client/assets/dbus/com.deepin.Calendar.service \
      --replace "/usr/bin/dde-calendar" "$out/bin/dde-calendar"
  '';

  fixCodePath = ''
    substituteInPlace calendar-service/src/dbmanager/huanglidatabase.cpp \
      --replace "/usr/share/dde-calendar/data/huangli.db" "$out/share/dde-calendar/data/huangli.db"
    substituteInPlace calendar-service/src/main.cpp \
      --replace "/usr/share/dde-calendar/translations" "$out/share/dde-calendar/translations"
    substituteInPlace calendar-service/src/csystemdtimercontrol.cpp \
      --replace "/bin/bash" "${runtimeShell}"
    substituteInPlace calendar-service/src/jobremindmanager.cpp \
      --replace "/bin/bash" "${runtimeShell}"
  '';

  postPatch = fixInstallPatch + fixServicePath + fixCodePath;

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    dde-qt-dbus-factory
    gtest
    qt5integration
    qt5platform-plugins
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  postFixup = ''
    wrapQtApp $out/lib/deepin-daemon/dde-calendar-service
  '';

  meta = with lib; {
    description = "Calendar for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-calendar";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
