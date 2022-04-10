{ stdenv
, lib
, fetchFromGitHub
, dtkcommon
, dtkcore
, dtkgui
, dtkwidget
, qt5integration
, qt5platform-plugins
, gio-qt
, udisks2-qt5
, image-editor
, cmake
, pkgconfig
, qttools
, qtsvg
, qtx11extras
, wrapQtAppsHook
, libraw
, libexif
}:

stdenv.mkDerivation rec {
  pname = "deepin-image-viewer";
  version = "5.8.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-nOyprwUPg5XWrfQhBjLsUlkqkL6Vgd9PhTwQb3JNgog=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
    gio-qt
    udisks2-qt5
    image-editor

    qtsvg

    libraw
    libexif
  ];

  cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  patches = [ ./0001-fix-fhs-path-for-nix.patch ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "set(PREFIX  /usr)" "set(PREFIX  $out)" \
      --replace "/usr/share/applications" "$out/share/applications" \
      --replace "/usr/share/deepin-image-viewer/icons" "$out/share/deepin-image-viewer/icons" \
      --replace "/usr/share/deepin-manual/manual-assets/application/" "$out/share/deepin-manual/manual-assets/application/" \
      --replace "/usr/share/icons/hicolor/scalable/apps" "$out/share/icons/hicolor/scalable/apps" \
      --replace "/usr/share/dbus-1/services" "$out/share/dbus-1/services"

    # fix code  
    substituteInPlace src/src/module/view/homepagewidget.cpp \
      --replace "\"../libimageviewer/image-viewer_global.h\"" "\"libimageviewer/image-viewer_global.h\"" \
      --replace "\"../libimageviewer/imageviewer.h\"" "\"libimageviewer/imageviewer.h\""
    
    substituteInPlace src/src/mainwindow/mainwindow.cpp \
      --replace "\"../libimageviewer/imageviewer.h\"" "\"libimageviewer/imageviewer.h\"" \
      --replace "\"../libimageviewer/imageengine.h\"" "\"libimageviewer/imageengine.h\""
  '';

  meta = with lib; {
    description = "An image viewing tool with fashion interface and smooth performance";
    homepage = "https://github.com/linuxdeepin/deepin-image-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}