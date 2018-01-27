TARGET = harbour-linksbag

VERSION = 2.2

QT += webkit network

CONFIG += link_pkgconfig sailfishapp c++11 sailfishapp_i18n

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
    src/settings/applicationsettings.cpp \
    src/authserver.cpp

HEADERS += src/debugmessagehandler.h \
    src/application.h \
    src/getpocketapi.h \
    src/linksbagmanager.h \
    src/bookmarksmodel.h \
    src/filterproxymodel.h \
    src/bookmark.h \
    src/enumsproxy.h \
    src/settings/applicationsettings.h \
    src/authserver.h

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

DISTFILES += qml/harbour-linksbag.qml \
    qml/cover/CoverPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/BookmarksFilter.qml \
    harbour-linksbag.desktop \
    qml/pages/helpers/readability.js \
    qml/pages/helpers/userscript.js \
    qml/pages/helpers/ReaderModeHandler.js \
    qml/pages/helpers/MessageListener.js \
    qml/pages/EditTagDialog.qml \
    rpm/harbour-linksbag.changes \
    rpm/harbour-linksbag.changes.run.in \
    rpm/harbour-linksbag.yaml \
    qml/pages/WebAuthorizationPage.qml

lupdate_only{
SOURCES = qml/* \
    qml/cover/* \
    qml/pages/*
}

TRANSLATIONS += translations/harbour-linksbag.ts \
    translations/harbour-linksbag-en.ts \
    translations/harbour-linksbag-ru.ts
