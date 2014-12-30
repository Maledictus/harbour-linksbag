# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
QMAKE_CXXFLAGS += -std=c++0x

TARGET = harbour-linksbag

CONFIG += sailfishapp

QT += webkit network

SOURCES += src/linksbag.cpp \
    src/cachemanager.cpp \
    src/getpocketapi.cpp \
    src/linksbagmanager.cpp \
    src/bookmarksmodel.cpp \
    src/filterproxymodel.cpp \
    src/bookmark.cpp

OTHER_FILES += qml/harbour-linksbag.qml \
    qml/cover/CoverPage.qml \
    qml/pages/BookmarksPage.qml \
    qml/pages/BookmarkViewPage.qml \
    qml/pages/FilterSelectorPage.qml \
    qml/pages/BookmarksFilter.qml \
    rpm/harbour-linksbag.spec \
    rpm/harbour-linksbag.yaml \
    harbour-linksbag.desktop \
    qml/pages/AuthorizationPage.qml

HEADERS += src/cachemanager.h \
    src/getpocketapi.h \
    src/linksbagmanager.h \
    src/bookmarksmodel.h \
    src/filterproxymodel.h \
    src/bookmark.h

RESOURCES += src/harbour-linksbag.qrc

