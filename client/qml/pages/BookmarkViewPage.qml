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

Page {
    id: page

    property string bookmarkId
    property variant currentBookmark
    property bool readerMode: false

    onStatusChanged: {
        if (status == PageStatus.Active && linksbagManager.logged) {
            currentBookmark = linksbagManager.bookmarksModel.getBookmark(bookmarkId)
            webView.url = currentBookmark.bookmarkUrl
        }
    }

    function toggleReaderMode() {
        if (readerMode) {
            webView.reload();
        } else {
            // FIXME: dirty hack to load js from local file
            var xhr = new XMLHttpRequest;
            xhr.open("GET", "./helpers/readability.js");
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.DONE) {
                    var read = new Object({'type':'readability', 'content': xhr.responseText });
                    webView.experimental.postMessage( JSON.stringify(read) );
                }
            }
            xhr.send();
        }
        readerMode = !readerMode;
    }


    SilicaWebView {
        id: webView

        anchors.fill: parent

        header: PageHeader {
            title: qsTr("Reading")
        }

        PullDownMenu {
            MenuItem {
                text: currentBookmark && currentBookmark.bookmarkRead ?
                        qsTr("Mark as unread") :
                        qsTr("Mark as read")

                onClicked: {
                    toggleReaderMode()
//                    linksbagManager.markAsRead(currentBookmark.id,
//                            !currentBookmark.read)
                }
            }

            MenuItem {
                text: currentBookmark && currentBookmark.bookmarkFavorite ?
                        qsTr("Mark as unfavorite") :
                        qsTr("Mark as favorite")
               onClicked: {
                    linksbagManager.markAsFavorite(currentBookmark.id,
                            !currentBookmark.favorite)
                }
            }
        }

        experimental.userScripts: [ Qt.resolvedUrl("helpers/userscript.js") ]
        experimental.preferences.navigatorQtObjectEnabled: true

        experimental.onMessageReceived: {
            console.log('onMessageReceived: ' + message.data );
            var data = null
            try {
                data = JSON.parse(message.data)
            } catch (error) {
                console.log('onMessageReceived: ' + message.data );
                return
            }

            switch (data.type) {
            case 'inreadmode': {
                webView.experimental.evaluateJavaScript("document.documentElement.innerHTML",
                        function(result){
                            var page = pageStack.push(Qt.resolvedUrl("BookmarkViewPage2.qml"),
                                { text: result })
                            console.log(page)
                        })
            }
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            visible: webView.loading;
            running: true;
        }
    }
}





