# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = linksbag

CONFIG += sailfishapp

SOURCES += src/linksbag.cpp \
    src/networkaccessmanagerfactory.cpp \
    src/customnetworkaccessmanager.cpp

OTHER_FILES += qml/linksbag.qml \
	qml/CoverPage.qml \
	qml/BookmarksPage.qml \
	qml/SecondPage.qml \
    rpm/linksbag.spec \
    rpm/linksbag.yaml \
    linksbag.desktop \
    rpm/linksbag.spec \
    qml/LocalStorage.qml \
    qml/AuthManager.qml \
    qml/NetworkManager.qml

HEADERS += \
    src/networkaccessmanagerfactory.h \
    src/customnetworkaccessmanager.h

