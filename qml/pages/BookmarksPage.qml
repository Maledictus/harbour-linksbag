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

    property BookmarksFilter bookmarksFilter

    onBookmarksFilterChanged: {
        manager.setFilter (bookmarksFilter.key)
    }

    property BookmarksFilter allBookmarksFilter: BookmarksFilter {
        key: "all"
        name: qsTr("All")
    }

    property BookmarksFilter readBookmarksFilter: BookmarksFilter {
        key: "read"
        name: qsTr("Read")
    }

    property BookmarksFilter unreadBookmarksFilter: BookmarksFilter {
        key: "unread"
        name: qsTr("Unread")
    }

    property BookmarksFilter favoriteBookmarksFilter: BookmarksFilter {
        key: "favorite"
        name: qsTr("Favorite")
    }

    property variant bookmarksFilters: [
        allBookmarksFilter,
        readBookmarksFilter,
        unreadBookmarksFilter,
        favoriteBookmarksFilter
    ]

    function setFilter (filter) {
        var found = false
        for (var i = 0; i < bookmarksFilters.length; ++i) {
            if (bookmarksFilters [i].key === filter) {
                bookmarksFilter = bookmarksFilters [i]
                found = true
                break;
            }
        }
        if (!found) {
            bookmarksFilter = allBookmarksFilter
        }
    }

    function load () {
        busyIndicator.visible = true
        setFilter (manager.filter)
        bookmarksView.model = manager.bookmarksModel
        manager.loadBookmarks ()
    }

    Connections {
        target: manager
        onRequestFinished: {
            busyIndicator.visible = false
        }

        onFilterChanged: {
            setFilter (manager.filter)
        }
    }

    BusyIndicator {
        id: busyIndicator
        visible: false
        running: visible
        anchors.centerIn: parent
    }

    SilicaListView {
        id: bookmarksView

        anchors.fill: parent

        ViewPlaceholder {
            enabled: !bookmarksView.count && !busyIndicator.visible
            text: qsTr ("There are no bookmarks. Try pull menu to refresh them.")
        }

        PullDownMenu {
            MenuItem {
                text: manager.searchFieldVisible ?
                        qsTr ("Hide search field") :
                        qsTr ("Show search field")

                onClicked: {
                     manager.searchFieldVisible = manager.searchFieldVisible ?
                         false :
                         true
                }
            }

            MenuItem {
                text: qsTr("View: %1").arg(bookmarksFilter.name)

                onClicked: {
                    pageStack.push (Qt.resolvedUrl ("FilterSelectorPage.qml"),
                        { bookmarksPage : page });
                }
            }

            MenuItem {
                text: qsTr ("Refresh")
                onClicked: {
                    busyIndicator.visible = true
                    manager.refreshBookmarks ()
                }
            }
        }

        header: Column {
            id: headerColumn
            width: bookmarksView.width
            PageHeader {
                title: qsTr ("Bookmarks: ") + bookmarksFilter.name
            }

            SearchField {
                id: search

                visible: manager.searchFieldVisible

                anchors.left: parent.left
                anchors.right: parent.right

                placeholderText: qsTr ("Search")

                onTextChanged: {
                    manager.filterBookmarks (text)
                    search.forceActiveFocus ()
                    bookmarksView.currentIndex = -1
                }
            }
        }

        currentIndex: -1

        property Item contextMenu

        delegate: BackgroundItem {
            id: delegate

            property string url : bookmarkUrl

            property bool menuOpen: bookmarksView.contextMenu != null &&
                    bookmarksView.contextMenu.parent === delegate
            height: contentItem.childrenRect.height +
                    (menuOpen ? bookmarksView.contextMenu.height : 0);

            Label {
                id: titleLabel

                anchors.left: parent.left
                anchors.right: favoriteImage.left
                anchors.margins: Theme.paddingMedium

                font.family: Theme.fontFamilyHeading
                font.pixelSize:  Theme.fontSizeMedium
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: bookmarkTitle
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
                    var matches = bookmarkUrl.toString().match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                    return matches ? matches[1] : bookmarkUrl;
                }
            }

            Image {
                id: tagsIcon

                anchors.left: urlLabel.left
                anchors.verticalCenter: tagsLabel.verticalCenter
                source: "qrc:/images/icon-s-tag.png"

                visible: bookmarkTags != ""
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
                font.italic: true
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: bookmarkTags
            }

            IconButton {
                id: favoriteImage
                anchors.right: readImage.left
                anchors.leftMargin: Theme.paddingMedium;
                anchors.rightMargin: Theme.paddingSmall
                icon.source: bookmarkFavorite ?
                    "image://Theme/icon-m-favorite-selected" :
                    "image://Theme/icon-m-favorite"
                onClicked: {
                    busyIndicator.visible = true
                    manager.markAsFavorite (bookmarkID, !bookmarkFavorite)
                }
            }

            IconButton {
                id: readImage
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                icon.source: bookmarkRead ?
                    "image://Theme/icon-m-certificates" :
                    "image://Theme/icon-m-mail"
                onClicked: {
                    busyIndicator.visible = true
                    manager.markAsRead (bookmarkID, !bookmarkRead)
                }
            }


            function remove () {
                var idx = index
                remorse.execute(delegate, qsTr ("Removing bookmark"),
                        function () {
                            busyIndicator.visible = true
                            manager.removeBookmark (bookmarkID)

                        }, 5000);
            }

            RemorseItem { id: remorse }

            onPressAndHold: {
                bookmarksView.currentIndex = index;
                if (!bookmarksView.contextMenu)
                    bookmarksView.contextMenu = bookmarkContextMenuComponent.createObject()
                bookmarksView.contextMenu.show(delegate)
            }

            onClicked: {
                var page = pageStack.push (Qt.resolvedUrl ("BookmarkViewPage.qml"),
                        { bookmarkId: bookmarkID })
                page.load ()
            }
        }

        Component {
            id: bookmarkContextMenuComponent
            ContextMenu {
                MenuItem {
                    text: qsTr ("Copy url to clipboard")
                    onClicked: {
                        Clipboard.text = bookmarksView.currentItem.url
                    }
                }

                MenuItem {
                    text: qsTr ("Open in external browser")
                    onClicked: {
                        Qt.openUrlExternally (bookmarksView.currentItem.url)
                    }
                }

                MenuItem {
                    text: qsTr ("Remove")
                    onClicked: {
                        bookmarksView.currentItem.remove ()
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
