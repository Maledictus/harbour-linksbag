TEMPLATE = lib

TARGET = $$qtLibraryTarget(linksbagshareplugin)

target.path = /usr/lib/nemo-transferengine/plugins

QT += network

CONFIG += plugin link_pkgconfig

PKGCONFIG += nemotransferengine-qt5

HEADERS += src/getpockettransferiface.h \
    src/getpocketplugininfo.h \
    src/getpocketmediatransfer.h

SOURCES += src/getpockettransferiface.cpp \
    src/getpocketplugininfo.cpp \
    src/getpocketmediatransfer.cpp

OTHER_FILES += qml/ShareUi.qml

qml.path = /usr/share/harbour-linksbag/qml
qml.files = qml/ShareUi.qml

icons.files = icons/linksbag.png
icons.path = /usr/share/harbour-linksbag/images

INSTALLS += target qml icons
