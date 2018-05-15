TARGET = harbour-linksbag

VERSION = 3.0

QT += webkit network

CONFIG += link_pkgconfig sailfishapp c++11 sailfishapp_i18n
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
    qml/cover/ArticleCover.qml \
    qml/cover/ArticleListCover.qml \
    qml/pages/AuthorizationPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/BookmarkDownloadsPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/EditTagDialog.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/WebAuthorizationPage.qml \
    qml/pages/components/Mercury.qml \
    qml/pages/components/Readability.qml \
    qml/pages/helpers/MessageListener.js \
    qml/pages/helpers/ReaderModeHandler.js \
    qml/pages/helpers/readability.js \
    harbour-linksbag.desktop \
    rpm/harbour-linksbag.changes \
    rpm/harbour-linksbag.changes.run.in \
    rpm/harbour-linksbag.spec \
    translations/harbour-linksbag.ts \
    translations/harbour-linksbag-en.ts \
    translations/harbour-linksbag-ru.ts \
    translations/harbour-linksbag-es.ts \
    translations/harbour-linksbag-sv.ts \
    translations/harbour-linksbag-fr.ts \
    translations/harbour-linksbag-pl.ts \
    qml/pages/SettingsPage.qml \
    qml/pages/ParserLoader.qml


lupdate_only{
SOURCES = qml/harbour-linksbag.qml \
    qml/cover/CoverPage.qml \
    qml/cover/ArticleCover.qml \
    qml/cover/ArticleListCover.qml \
    qml/pages/AuthorizationPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/BookmarkDownloadsPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/EditTagDialog.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/WebAuthorizationPage.qml \
    qml/pages/components/Mercury.qml \
    qml/pages/components/Readability.qml \
    qml/pages/helpers/MessageListener.js \
    qml/pages/helpers/ReaderModeHandler.js \
    qml/pages/helpers/readability.js
}

TRANSLATIONS += translations/harbour-linksbag.ts \
    translations/harbour-linksbag-en.ts \
    translations/harbour-linksbag-ru.ts \
    translations/harbour-linksbag-es.ts \
    translations/harbour-linksbag-sv.ts \
    translations/harbour-linksbag-fr.ts \
    translations/harbour-linksbag-pl.ts \
    translations/harbour-linksbag-nl.ts
