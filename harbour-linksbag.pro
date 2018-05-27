TARGET = harbour-linksbag

VERSION = 3.0

QT += webkit network

CONFIG += link_pkgconfig sailfishapp c++11 sailfishapp_i18n
PKGCONFIG += mlite5

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

RESOURCES += $${TARGET}.qrc

SOURCES += src/main.cpp \
    src/application.cpp \
    src/authserver.cpp \
    src/bookmark.cpp \
    src/bookmarksmodel.cpp \
    src/enumsproxy.cpp \
    src/debugmessagehandler.cpp \
    src/filterproxymodel.cpp \
    src/getpocketapi.cpp \
    src/linksbagmanager.cpp \
    src/settings/applicationsettings.cpp

HEADERS += src/application.h \
    src/authserver.h \
    src/bookmark.h \
    src/bookmarksmodel.h \
    src/enumsproxy.h \
    src/debugmessagehandler.h \
    src/filterproxymodel.h \
    src/getpocketapi.h \
    src/linksbagmanager.h \
    src/settings/applicationsettings.h

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

DISTFILES += qml/harbour-linksbag.qml \
    qml/cover/ArticleCover.qml \
    qml/cover/ArticleListCover.qml \
    qml/cover/CoverPage.qml \
    qml/pages/components/ArticleBookmarkView.qml \
    qml/pages/components/DefaultBookmarkView.qml \
    qml/pages/components/ImageBookmarkView.qml \
    qml/pages/components/Mercury.qml \
    qml/pages/components/Readability.qml \
    qml/pages/helpers/readability.js \
    qml/pages/helpers/MessageListener.js \
    qml/pages/helpers/ReaderModeHandler.js \
    qml/pages/AuthorizationPage.qml \
    qml/pages/BookmarkDownloadsPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/EditTagDialog.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/ParserLoader.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/WebAuthorizationPage.qml \
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
    translations/harbour-linksbag-pl.ts

lupdate_only{
SOURCES = qml/harbour-linksbag.qml \
    qml/cover/ArticleCover.qml \
    qml/cover/ArticleListCover.qml \
    qml/cover/CoverPage.qml \
    qml/pages/components/ArticleBookmarkView.qml \
    qml/pages/components/DefaultBookmarkView.qml \
    qml/pages/components/ImageBookmarkView.qml \
    qml/pages/components/Mercury.qml \
    qml/pages/components/Readability.qml \
    qml/pages/helpers/readability.js \
    qml/pages/helpers/MessageListener.js \
    qml/pages/helpers/ReaderModeHandler.js \
    qml/pages/AuthorizationPage.qml \
    qml/pages/BookmarkDownloadsPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/BookmarksFilter.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/EditTagDialog.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/LoginPage.qml \
    qml/pages/ParserLoader.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/WebAuthorizationPage.qml
}

TRANSLATIONS += translations/harbour-linksbag.ts \
    translations/harbour-linksbag-en.ts \
    translations/harbour-linksbag-ru.ts \
    translations/harbour-linksbag-es.ts \
    translations/harbour-linksbag-sv.ts \
    translations/harbour-linksbag-fr.ts \
    translations/harbour-linksbag-pl.ts \
    translations/harbour-linksbag-nl.ts
