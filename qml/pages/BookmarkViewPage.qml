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
import QtQuick.Layouts 1.1
import harbour.linksbag 1.0
import "."

Page {
    id: page

    property string bookmarkId
    property var currentBookmark

    property bool bookmarkRead: currentBookmark && currentBookmark.read
    property bool bookmarkFavorite: currentBookmark && currentBookmark.favorite
    property bool hasContent: currentBookmark && currentBookmark.hasContent

    onStatusChanged: {
        if (status === PageStatus.Active && linksbagManager.logged) {
            cover.title = currentBookmark !== null ? currentBookmark.title : ""
            cover.image = currentBookmark.coverImage
            var source
            if (mainWindow.settings.useReaderModeOnly) {
                source = "./components/ArticleBookmarkView.qml"
            }
            else {
                switch (currentBookmark.contentType) {
                case Bookmark.CTArticle:
                    source = "./components/ArticleBookmarkView.qml"
                    break
                case Bookmark.CTImage:
                    source = "./components/ImageBookmarkView.qml"
                    break
                case Bookmark.CTVideo:
                case Bookmark.CTNoType:
                default:
                    source = "./components/DefaultBookmarkView.qml"
                    break
                }
            }

            viewLoader.source = source
        }
    }

    Component.onCompleted: cover.articleLayout = true
    Component.onDestruction: cover.articleLayout = false

    Connections {
        target: linksbagManager
        onBookmarkReadStateChanged: {
            if (bookmarkId === id) {
                viewLoader.item.bookmarkRead = readState
            }
        }
        onBookmarkFavoriteStateChanged: {
            if (bookmarkId === id) {
                viewLoader.item.bookmarkFavorite = favoriteState
            }
        }
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        active: bookmark && source !== ""
        asynchronous: true
        visible: status == Loader.Ready

        property var bookmark: currentBookmark

        Connections {
            target: viewLoader.item
            onPublishedDateChanged: currentBookmark.publishedDate = viewLoader.item.publishedDate
        }
    }
}





