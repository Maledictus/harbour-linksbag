/*
    Copyright (c) 2014 Oleg Linkin <MaledictusDeMagog@gmail.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property alias m: listModel
    property bool loading

    property BookmarksFilter bookmarksFilter: allBookmarksFilter

    signal login ()
    signal logout ()
    signal markAsRead (string uid, bool read)
    signal markAsFavorite (string uid, bool favorite)
    signal removeBookmark (string uid)
    signal selectBookmark (string uid, string url, string title, bool isRead, bool isFavorite)

    property bool inSearchMode: searchField.focus
    property string searchString

    onSearchStringChanged: listModel.update()

    onBookmarksFilterChanged: {
        reloadBookmarks(bookmarksFilter.name.toLowerCase())
    }


    property BookmarksFilter allBookmarksFilter: BookmarksFilter {
        name: qsTr("All")
    }

    property BookmarksFilter readBookmarksFilter: BookmarksFilter {
        name: qsTr("Read")
    }

    property BookmarksFilter unreadBookmarksFilter: BookmarksFilter {
        name: qsTr("Unread")
    }

    property BookmarksFilter favoriteBookmarksFilter: BookmarksFilter {
        name: qsTr("Favorite")
    }

    property variant bookmarksFilters: [
        allBookmarksFilter,
        readBookmarksFilter,
        unreadBookmarksFilter,
        favoriteBookmarksFilter
    ]

    ListModel {
        id: listModel

        function update () {
            listModel.clear ()
            var array = runtimeCache.getItems(bookmarksFilter.name.toLowerCase())
            for (var i = 0; i < array.length; ++i) {
                var item = array [i]
                if (searchString === "" ||
                        item.title.toLowerCase ().indexOf(searchString) >= 0 ||
                        item.tags.toLowerCase ().indexOf(searchString) >= 0) {
                    listModel.append (item)
                }
            }
        }

        Component.onCompleted: update ()
    }

    function bookmarksDownloaded (lastUpdate) {
        localStorage.setSettingsValue ("lastUpdate", lastUpdate)
        var array = runtimeCache.getItems(bookmarksFilter.name.toLowerCase())
        listModel.clear()
        for (var i = 0; i < array.length; ++i) {
            listModel.append (array[i])
        }

        cacheManager.SaveItems (array)
    }

    function reloadBookmarks (type) {
        var array = runtimeCache.getItems(type)
        listModel.clear()
        for (var i = 0; i < array.length; ++i) {
            listModel.append (array[i])
        }
    }

    function restoreBookmarks () {
        var array = cacheManager.GetSavedItems ()
        for (var i = 0; i < array.length; ++i) {
            runtimeCache.addItem (array[i])
        }

        array = runtimeCache.getItems(bookmarksFilter.name.toLowerCase())
        listModel.clear()
        for (var i = 0; i < array.length; ++i) {
            listModel.append (array[i])
        }

        loadBookmarks()
    }

    function loadBookmarks () {
        var lastUpdate = parseInt (localStorage.getSettingsValue ("lastUpdate", 0))
        networkManager.loadBookmarks (lastUpdate)
    }

    function markBookmarkAsRead (uid, setRead) {
        for (var i = 0; i < listModel.count; ++i) {
            if (listModel.get (i).uid === uid) {
                listModel.get (i).read = setRead
                return
            }
        }
    }

    function markBookmarkAsFavorite (uid, setFavorite) {
        for (var i = 0; i < listModel.count; ++i) {
            if (listModel.get (i).uid === uid) {
                listModel.get (i).favorite = setFavorite
                return
            }
        }
    }

    Column {
        id: headerContainer

        width: page.width

        SearchField {
            id: searchField
            width: parent.width

            placeholderText: qsTr ("Search")

            Binding {
                target: page
                property: "searchString"
                value: searchField.text.toLowerCase().trim()
            }
        }
    }

    SilicaListView {
        id: listView

        model: listModel
        anchors.fill: parent

        property alias searchFieldText: searchField.text

        PullDownMenu {
            MenuItem {
                text: qsTr ("Check new bookmarks")
                onClicked: {
                    var page = pageStack.push (Qt.resolvedUrl ("NewBookmarksDialog.qml"))
                    page.load ()
                    page.accepted.connect (function () {
                        networkManager.addBookmarks (page.selectedBookmarks)
                    })
                }
            }

            MenuItem {
                text: authManager.userName === "" ? qsTr("Login") : qsTr ("Logout")
                onClicked: authManager.userName === "" ? login () : logout ()
            }

            MenuItem {
                text: qsTr("View: %1").arg(bookmarksFilter.name)

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FilterSelectorPage.qml"));
                }
            }

            MenuItem {
                text: qsTr ("Refresh")
                onClicked: page.loadBookmarks()
            }
        }

        header: Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        currentIndex: -1

        spacing: 5

        property Item contextMenu

        delegate: BackgroundItem {
            id: delegate

            property string bookmarkId : uid
            property url bookmarkUrl : url
            property string bookmarkTitle: title
            property string bookmarkTags: tags
            property bool bookmarkIsFavorite : favorite
            property bool bookmarkIsRead : read

            property bool menuOpen: listView.contextMenu != null &&
                    listView.contextMenu.parent === delegate
            height: titleLabel.height + urlLabel.height + tagsLabel.height +
                    (menuOpen ? listView.contextMenu.height : 0);


            Label {
                id: titleLabel

                anchors.left: parent.left
                anchors.right: favoriteImage.visible ?
                    favoriteImage.left :
                    parent.right
                anchors.margins: Theme.paddingMedium

                font.family: Theme.fontFamilyHeading
                font.pixelSize:  Theme.fontSizeMedium
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: delegate.bookmarkTitle
            }

            IconButton {
                id: favoriteImage
                anchors.right: readImage.left
                anchors.leftMargin: Theme.paddingMedium;
                anchors.rightMargin: Theme.paddingSmall
                icon.source: delegate.bookmarkIsFavorite ?
                    "image://Theme/icon-m-favorite-selected" :
                    "image://Theme/icon-m-favorite"
                onClicked: {
                    markAsFavorite(delegate.bookmarkId, !delegate.bookmarkIsFavorite)
                }
            }

            IconButton {
                id: readImage
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                icon.source: delegate.bookmarkIsRead ?
                    "image://Theme/icon-m-certificates" :
                    "image://Theme/icon-m-mail"
                onClicked: {
                    markAsRead(delegate.bookmarkId, !delegate.bookmarkIsRead)
                }
            }

            Label {
                id: urlLabel

                anchors.left: parent.left
                anchors.right: titleLabel.right
                anchors.top: titleLabel.bottom
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.topMargin: 0

                font.pixelSize:  Theme.fontSizeTiny
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: {
                    var matches = delegate.bookmarkUrl.toString().match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                    return matches ? matches[1] : delegate.bookmarkUrl;
                }
            }

            Image {
                id: tagsIcon

                anchors.left: urlLabel.left
                anchors.verticalCenter: tagsLabel.verticalCenter
                source: "qrc:/images/icon-s-tag.png"

                visible: delegate.bookmarkTags != ""
            }

            Label {
                id: tagsLabel

                anchors.left: tagsIcon.right
                anchors.right: titleLabel.right
                anchors.top: urlLabel.bottom
                anchors.leftMargin: Theme.paddingSmall
                anchors.rightMargin: Theme.paddingMedium
                anchors.topMargin: 0

                font.pixelSize:  Theme.fontSizeTiny
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: delegate.bookmarkTags
            }

            function remove () {
                var idx = index
                remorse.execute(delegate, qsTr ("Removing bookmark"),
                        function () {
                            removeBookmark (bookmarkId)
                            listModel.remove (idx)
                        }, 3000);
            }

            RemorseItem { id: remorse }

            onPressAndHold: {
                listView.currentIndex = index;
                if (!listView.contextMenu)
                    listView.contextMenu = bookmarkContextMenuComponent.createObject()
                listView.contextMenu.show(delegate)
            }

            onClicked: selectBookmark(uid, url, title, read, favorite)
        }

        Component {
            id: bookmarkContextMenuComponent
            ContextMenu {
                MenuItem {
                    text: qsTr ("Share")
                    onClicked: pageStack.push(Qt.resolvedUrl("ShareLinkPage.qml"),
                            { "link" : listView.currentItem.bookmarkUrl, "linkTitle": listView.currentItem.bookmarkTitle })
                }
                MenuItem {
                    text: qsTr ("Copy url to clipboard")
                    onClicked: Clipboard.text = listView.currentItem.bookmarkUrl
                }

                MenuItem {
                    text: qsTr ("Open in external browser")
                    onClicked: Qt.openUrlExternally(listView.currentItem.bookmarkUrl)
                }

                MenuItem {
                    text: qsTr ("Remove")
                    onClicked: listView.currentItem.remove ()
                }
            }
        }

        VerticalScrollDecorator{}
    }

    BusyIndicator {
        visible: loading && !listModel.count
        running: visible
        anchors.centerIn: parent
    }

    Label {
        anchors.centerIn: parent
        visible: !loading && !listModel.count && !inSearchMode
        text: qsTr ("Offline")
    }
}


