/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

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
import harbour.linksbag 1.0

Page {
    id: bookmarksPage

    property BookmarksFilter bookmarksFilter : getFilterByKey(mainWindow.settings.bookmarksFilter)

    function getFilterByKey(key) {
        for (var i = 0; i < bookmarksFilters.length; ++i) {
            if (bookmarksFilters[i].key === key) {
                return bookmarksFilters[i]
            }
        }

        return allBookmarksFilter;
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

    property BookmarksFilter unsyncedBookmarksFilter: BookmarksFilter {
        key: "unsynced"
        name: qsTr("Not downloaded")
    }

    property variant bookmarksFilters: [
        allBookmarksFilter,
        readBookmarksFilter,
        unreadBookmarksFilter,
        favoriteBookmarksFilter
    ]

    onBookmarksFilterChanged: {
        if (bookmarksFilter.key == "all")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.All)
        }
        else if (bookmarksFilter.key == "read")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Read)
        }
        else if (bookmarksFilter.key == "unread")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Unread)
        }
        else if (bookmarksFilter.key == "favorite")
        {
            linksbagManager.filterModel.filterBookmarks(LinksBag.Favorite)
        }

        cover.currentFilter = bookmarksFilter.name
        mainWindow.settings.bookmarksFilter = bookmarksFilter.key
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: linksbagManager.busy
        visible: running
        z: 2
    }

    SilicaListView {
        id: bookmarksView

        anchors.fill: parent

        property bool showSearchField: mainWindow.settings.showSearchField === true

        header: Column {
            id: headerColumn
            width: bookmarksView.width
            PageHeader {
                title: qsTr("Bookmarks")
                description: qsTr(bookmarksFilter.name)
            }

            SearchField {
                id: search

                visible: bookmarksView.showSearchField

                anchors.left: parent.left
                anchors.right: parent.right

                placeholderText: qsTr("Search")

                onTextChanged: {
                    linksbagManager.filterBookmarks(text)
                    search.forceActiveFocus()
                    bookmarksView.currentIndex = -1
                }
            }
        }

        ViewPlaceholder {
            enabled: !bookmarksView.count && !linksbagManager.busy
            text: qsTr("There are no bookmarks. Pull down to refresh.")
        }

        PullDownMenu {
            visible: !linksbagManager.busy

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            }

            MenuItem {
                text: qsTr("Downloads")
                onClicked: pageStack.push(Qt.resolvedUrl("BookmarkDownloadsPage.qml"),
                                { bookmarksPage : bookmarksPage });
            }

            MenuItem {
                text: bookmarksView.showSearchField ?
                        qsTr("Hide search field") :
                        qsTr("Show search field")

                onClicked: {
                    bookmarksView.showSearchField = !bookmarksView.showSearchField
                    mainWindow.settings.showSearchField = bookmarksView.showSearchField
                }
            }

            MenuItem {
                text: qsTr("View: %1").arg(bookmarksFilter.name)

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("FilterSelectorPage.qml"),
                        { bookmarksPage : bookmarksPage });
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: linksbagManager.refreshBookmarks()
            }
        }

        currentIndex: -1

        model: linksbagManager.filterModel

        delegate: ListItem {
            id: rootDelegateItem
            width: bookmarksView.width
            contentHeight: Math.max(textColumn.height, favoriteIcon.height)

            menu: ContextMenu {
                MenuItem {
                    text: qsTr("Copy url to clipboard")
                    onClicked: {
                        Clipboard.text = bookmarkUrl
                        linksbagManager.notify(qsTr("Url copied into clipboard"))
                    }
                }

                MenuItem {
                    text: qsTr("Open in browser")
                    onClicked: {
                        Qt.openUrlExternally(encodeURI(bookmarkUrl))
                    }
                }

                MenuItem {
                    text: qsTr ("Edit tags")
                    onClicked: {
                        var dialog = pageStack.push("EditTagDialog.qml", { tags: bookmarkTags })
                        dialog.accepted.connect(function () {
                            linksbagManager.updateTags(bookmarkID, dialog.tags)
                        })
                    }
                }

                MenuItem {
                    text: bookmarkRead ? qsTr("Mark as unread") : qsTr("Mark as read")
                    onClicked: linksbagManager.markAsRead(bookmarkID, !bookmarkRead)
                }

                MenuItem {
                    text: qsTr ("Remove")
                    onClicked: remorse.execute(rootDelegateItem, qsTr("Remove"), function() {
                       linksbagManager.removeBookmark(bookmarkID)
                    })
                }
            }

            Image {
                visible: false
                id: thumbnail
                cache: true
                smooth: false
                asynchronous: true
                source: bookmarkThumbnail
                onSourceChanged: {
                    wallpaperEffect.wallpaperTexture = null
                    wallpaperEffect.wallpaperTexture = thumbnail
                }
            }

            Item {
                id: glassTextureItem
                visible: false
                width: glassTextureImage.width
                height: glassTextureImage.height
                Image {
                    id: glassTextureImage
                    opacity: 0.1
                    source: "image://theme/graphic-shader-texture"
                }
            }

            ShaderEffect {
                // shamelessly borrowed from Jolla, sorry guys :(
                id: wallpaperEffect
                anchors.fill: parent
                z: -1

                visible: thumbnail.source != ""
                property real dimmedOpacity: 0.4

                // wallpaper orientation
                readonly property size normalizedSize: Qt.size(1, rootDelegateItem.contentHeight/wallpaperTexture.sourceSize.height)
                readonly property point offset: Qt.point((1 - normalizedSize.width) / 2, (1 - normalizedSize.height) / 2);
                readonly property size dimensions: Qt.size(1, rootDelegateItem.contentHeight/wallpaperTexture.sourceSize.height)
                // glass texture size
                property size glassTextureSizeInv: Qt.size(1.0/(glassTextureImage.sourceSize.width),
                                                           -1.0/(glassTextureImage.sourceSize.height))

                property Image wallpaperTexture: thumbnail
                property variant glassTexture: ShaderEffectSource {
                    hideSource: true
                    sourceItem: glassTextureItem
                    wrapMode: ShaderEffectSource.Repeat
                }

                vertexShader: "
                   uniform highp vec2 dimensions;
                   uniform highp vec2 offset;
                   uniform highp mat4 qt_Matrix;
                   attribute highp vec4 qt_Vertex;
                   attribute highp vec2 qt_MultiTexCoord0;
                   varying highp vec2 qt_TexCoord0;

                   void main() {
                      qt_TexCoord0 = qt_MultiTexCoord0 * dimensions + offset;
                      gl_Position = qt_Matrix * qt_Vertex;
                   }
                "

                fragmentShader: "
                   uniform sampler2D wallpaperTexture;
                   uniform sampler2D glassTexture;
                   uniform highp vec2 glassTextureSizeInv;
                   uniform lowp float dimmedOpacity;
                   uniform lowp float qt_Opacity;
                   varying highp vec2 qt_TexCoord0;

                   void main() {
                      lowp vec4 wp = texture2D(wallpaperTexture, qt_TexCoord0);
                      lowp vec4 tx = texture2D(glassTexture, gl_FragCoord.xy * glassTextureSizeInv);
                      gl_FragColor = gl_FragColor = vec4(dimmedOpacity*wp.rgb + tx.rgb, 1.0);
                   }
                "
            }

            GlassItem {
                id: unreadIndicator
                width: Theme.itemSizeExtraSmall
                height: width
                anchors.horizontalCenter: parent.left
                y: titleLabel.y + Theme.paddingLarge - height/2
                color: Theme.highlightColor
                visible: !bookmarkRead
                radius: 0.14
                falloffRadius: 0.13
            }

            Column {
                Item {
                    width: parent.width
                    height: mainWindow.settings.bookmarksViewItemSize
                }

                id: textColumn
                property real margin: Theme.paddingMedium
                anchors {
                    left: !bookmarkRead ? unreadIndicator.right : parent.left
                    leftMargin:!bookmarkRead ? Theme.paddingMedium : Theme.horizontalPageMargin
                    right: favoriteIcon.left
                    rightMargin: Theme.paddingMedium
                }

                Label {
                    id: titleLabel
                    color: Theme.primaryColor
                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    text: bookmarkTitle
                }

                Item {
                    width: Math.min(parent.width - 2 * textColumn.margin,
                            sourceLabel.paintedWidth + 2 * Theme.paddingSmall)
                    height: sourceLabel.paintedHeight
                    Rectangle {
                        y: 1
                        opacity: 0.7
                        width: parent.width
                        height: parent.height - y
                        radius: Theme.paddingSmall / 2
                        color: 'black'
                    }
                    Label {
                        id: sourceLabel
                        x: Theme.paddingSmall
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: 'white'
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        text: {
                            var matches = bookmarkUrl.toString()
                                    .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                            return matches ? matches[1] : bookmarkUrl
                        }
                    }
                    Image {
                        visible: bookmarkHasContent
                        anchors {
                            left: sourceLabel.right
                            leftMargin: Theme.paddingLarge
                            verticalCenter: sourceLabel.verticalCenter
                        }
                        source: "image://Theme/icon-s-cloud-download"
                    }
                }
                Item {
                    width: Math.min(parent.width - 2 * textColumn.margin,
                            tagsRow.childrenRect.width + 2 * Theme.paddingSmall)
                    height: tagsRow.childrenRect.height
                    visible: bookmarkTags != ""
                    Rectangle {
                        y: 1
                        radius: Theme.paddingSmall / 2
                        width: parent.width
                        height: parent.height - y
                        opacity: 0.5
                        color: 'black'
                    }
                    Row {
                        id: tagsRow
                        x: Theme.paddingSmall
                        spacing: Theme.paddingSmall
                        width: parent.width
                        clip: true

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            source: "qrc:/images/icon-s-tag.png"
                            visible: bookmarkTags != ""
                        }

                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize:  Theme.fontSizeTiny
                            font.italic: true
                            elide: Text.ElideRight
                            text: bookmarkTags
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: mainWindow.settings.bookmarksViewItemSize
                }
            }

            IconButton {
                id: favoriteIcon
                anchors {
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                height: Theme.iconSizeMedium
                width: Theme.iconSizeMedium
                icon.source: "image://Theme/icon-m-favorite" + (bookmarkFavorite ? "-selected": "")
                onClicked: linksbagManager.markAsFavorite(bookmarkID, !bookmarkFavorite)
            }

            RemorseItem { id: remorse }

            onClicked: {
                var page = pageStack.push(Qt.resolvedUrl("BookmarkViewPage.qml"),
                        { bookmarkId: bookmarkID })
            }
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        // Sync on startup
        if (mainWindow.settings.syncOnStartup) {
            linksbagManager.refreshBookmarks();
        }
    }
}
