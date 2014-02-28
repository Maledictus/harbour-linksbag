# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-linksbag

CONFIG += sailfishapp

QT += webkit

SOURCES += src/linksbag.cpp \
    src/networkaccessmanagerfactory.cpp \
    src/customnetworkaccessmanager.cpp \
    src/cachemanager.cpp

OTHER_FILES += qml/linksbag.qml \
	qml/CoverPage.qml \
	qml/BookmarksPage.qml \
    rpm/harbour-linksbag.spec \
    rpm/harbour-linksbag.yaml \
    harbour-linksbag.desktop \
    qml/LocalStorage.qml \
    qml/AuthManager.qml \
    qml/NetworkManager.qml \
    qml/BookmarkViewPage.qml \
    qml/RuntimeCache.qml

HEADERS += \
    src/networkaccessmanagerfactory.h \
    src/customnetworkaccessmanager.h \
    src/cachemanager.h

RESOURCES += \
    harbour-linksbag.qrc

