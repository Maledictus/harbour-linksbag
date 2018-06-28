/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>

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
import QtWebKit 3.0
import Sailfish.Silica 1.0
import harbour.linksbag 1.0

Item {
    property bool bookmarkRead: bookmark ? bookmark.read : false
    property bool bookmarkFavorite: bookmark ? bookmark.favorite : false
    property string publishedDate

    Component.onCompleted: {
        webView.url = bookmark.url
    }

    SilicaWebView {
        id: webView

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Reload")
                onClicked: {
                    webView.reload()
                }
            }

            MenuItem {
                text: bookmarkRead ?
                        qsTr("Mark as unread") :
                        qsTr("Mark as read")

                onClicked: {
                    linksbagManager.markAsRead(bookmark.id, !bookmarkRead)
                }
            }

            MenuItem {
                text: bookmarkFavorite ?
                        qsTr("Mark as unfavorite") :
                        qsTr("Mark as favorite")
                onClicked: {
                    linksbagManager.markAsFavorite(bookmark.id, !bookmarkFavorite)
                }
            }

            MenuItem {
                text: qsTr("Open in browser")
                onClicked: {
                    Qt.openUrlExternally(encodeURI(bookmark.url))
                }
            }
        }

        PushUpMenu {
            enabled: !busyIndicator.running
            MenuItem {
                text: bookmarkRead ?
                        qsTr("Mark as unread") :
                        qsTr("Mark as read")

                onClicked: {
                    linksbagManager.markAsRead(bookmark.id, !bookmarkRead)
                    if (!bookmarkRead)
                        mainWindow.pageStack.pop()
                }
            }

            MenuItem {
                text: bookmarkFavorite ?
                        qsTr("Mark as unfavorite") :
                        qsTr("Mark as favorite")
                onClicked: {
                    linksbagManager.markAsFavorite(currentBookmark.bookmarkID,
                            !currentBookmark.bookmarkFavorite)
                }
            }
        }

        experimental.preferences.webGLEnabled: true
        experimental.preferences.notificationsEnabled: true
        experimental.preferences.javascriptEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.userAgent: mainWindow.settings.mobileBrowser ?
            "Mozilla/5.0 (Maemo; Linux; U; Sailfish; Mobile; rv:38.0) Gecko/38.0 Firefox/38.0" :
            ""
    }

    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: webView.loading || linksbagManager.busy
        visible: running
    }
}
