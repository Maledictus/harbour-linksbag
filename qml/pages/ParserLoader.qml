import QtQuick 2.0


Loader {
    id: loader
    property bool isBusy: false
    property string entry: ""
    property string bookmarkImage: ""

    onBookmarkImageChanged: item.bookmarkImage = bookmarkImage
    function setArticle(url) { loader.item.setArticle(url) }

    Connections {
        target: loader.item
        onEntryChanged: loader.entry = loader.item.entry
    }

    onLoaded: loader.item.isBusy = loader.isBusy
    Component.onCompleted: loader.source = Qt.resolvedUrl("components/" + applicationSettings.value("parser", "Mercury") + ".qml")
}
