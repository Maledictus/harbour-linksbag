QMAKE_CXXFLAGS += -std=c++0x
# The name of your app
TARGET = linksbag

QT += network

# C++ sources
SOURCES += main.cpp \
	src/getpocketmanager.cpp \
	src/pocketentriesmodel.cpp \
	src/filtermodel.cpp

# C++ headers
HEADERS += \
	src/getpocketmanager.h \
	src/pocketentriesmodel.h \
	src/filtermodel.h

# QML files and folders
qml.files = *.qml pages cover main.qml

# The .desktop file
desktop.files = linksbag.desktop

# Please do not modify the following line.
include(sailfishapplication/sailfishapplication.pri)

OTHER_FILES = rpm/linksbag.yaml \
		rpm/linksbag.spec

