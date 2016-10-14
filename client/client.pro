TARGET = harbour-linksbag

VERSION = 2.0

QT += webkit network

CONFIG += link_pkgconfig sailfishapp c++11
PKGCONFIG += mlite5

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

RESOURCES += $${TARGET}.qrc

SOURCES += src/main.cpp \
    src/debugmessagehandler.cpp \
    src/application.cpp \
    src/getpocketapi.cpp \
    src/linksbagmanager.cpp \
    src/bookmarksmodel.cpp \
    src/filterproxymodel.cpp \
    src/bookmark.cpp \
    src/enumsproxy.cpp \
    src/settings/accountsettings.cpp \
    src/settings/applicationsettings.cpp \

HEADERS += src/debugmessagehandler.h \
    src/application.h \
    src/getpocketapi.h \
    src/linksbagmanager.h \
    src/bookmarksmodel.h \
    src/filterproxymodel.h \
    src/bookmark.h \
    src/enumsproxy.h \
    src/settings/accountsettings.h \
    src/settings/applicationsettings.h \

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

DISTFILES += qml/harbour-linksbag.qml \
    qml/cover/CoverPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/AuthorizationPage.qml \
    qml/pages/Popup.qml \
    harbour-linksbag.desktop \
    qml/pages/helpers/readability.js \
    qml/pages/helpers/userscript.js \
    qml/pages/BookmarkViewPage2.qml

lupdate_only{
SOURCES = qml/harbour-linksbag.qml \
    qml/cover/CoverPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/AuthorizationPage.qml \
    qml/pages/Popup.qml
}
