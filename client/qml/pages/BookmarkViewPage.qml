/*
    Copyright (c) 2016 Oleg Linkin <MaledictusDeMagog@gmail.com>

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
import QtWebKit 3.0

import "./helpers/readability.js" as Readability

Page {
    id: page

    property string bookmarkId
    property variant currentBookmark
    property bool isBusy: true

    property bool bookmarkRead: false
    property bool bookmarkFavorite: false
    onStatusChanged: {
        if (status == PageStatus.Active && linksbagManager.logged) {
            currentBookmark = linksbagManager.bookmarksModel.getBookmark(bookmarkId)
            bookmarkRead = currentBookmark && currentBookmark.bookmarkRead
            bookmarkFavorite = currentBookmark && currentBookmark.bookmarkFavorite
            timer.running = true
            console.log(currentBookmark.bookmarkUrl)
        }
    }

    Timer {
        id: timer
        interval: 300;
        running: false;
        repeat: false
        onTriggered: webView.url = currentBookmark.bookmarkUrl
    }

    Connections {
        target: linksbagManager
        onBookmarkReadStateChanged: {
            if (bookmarkId !== id) {
                return
            }

            bookmarkRead = readState
            currentBookmark.bookmarkRead = readState
        }

        onBookmarkFavoriteStateChanged: {
            if (bookmarkId !== id) {
                return
            }

            bookmarkFavorite = favoriteState
            currentBookmark.bookmarkFavorite = favoriteState
        }
    }

    SilicaFlickable {
        id: pageView

        anchors.fill: parent

        contentWidth: width
        contentHeight: column.height + Theme.paddingSmall

        clip: true

        PullDownMenu {
            enabled: !busyIndicator.running
            MenuItem {
                text: bookmarkRead ?
                        qsTr("Mark as unread") :
                        qsTr("Mark as read")

                onClicked: {
                    linksbagManager.markAsRead(currentBookmark.bookmarkID,
                            !currentBookmark.bookmarkRead)
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

            MenuItem {
                text: qsTr("Open in browser")
                onClicked: {
                    Qt.openUrlExternally(encodeURI(currentBookmark.bookmarkUrl))
                }
            }
        }

        Column {
            id: column

            width: pageView.width

            anchors.top: parent.top
            anchors.topMargin: Theme.paddingSmall
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin

            Label {
                id: entryText

                width: parent.width

                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                horizontalAlignment: Qt.AlignJustify
            }
       }

       VerticalScrollDecorator {}
    }

    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: true
        running: linksbagManager.busy || isBusy;
    }

    SilicaWebView {
        id: webView

        visible: false
        z: -1

        experimental.preferences.webGLEnabled: true
        experimental.preferences.notificationsEnabled: true
        experimental.preferences.javascriptEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true

        experimental.userScripts: [
            Qt.resolvedUrl("helpers/readability.js") ,
            Qt.resolvedUrl("helpers/ReaderModeHandler.js"),
            Qt.resolvedUrl("helpers/MessageListener.js")
        ]

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                webView.postMessage("readermodehandler_enable");
                getSource()
            }
        }

        function postMessage(message, data) {
            experimental.postMessage(JSON.stringify({ "type": message, "data": data }));
        }
    }

    function getSource(){
        var js = "document.documentElement.outerHTML";
        webView.experimental.evaluateJavaScript(js, function(result){
            isBusy = false
            entryText.text = result
        })
    }
}





