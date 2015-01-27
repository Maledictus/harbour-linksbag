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

    property string bookmarkId
    property QtObject currentBookmark

    function load () {
        currentBookmark = manager.GetBookmark (bookmarkId)
    }

    onCurrentBookmarkChanged: {
        if (currentBookmark === 0 || currentBookmark === null) {
            return
        }

        webView.url = currentBookmark.url
    }

    SilicaWebView {
        id: webView

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                visible: currentBookmark !== 0 && currentBookmark !== null
                text: {
                    if (currentBookmark === 0 || currentBookmark === null) {
                        return "";
                    }

                    return currentBookmark.favorite ?
                        qsTr ("Mark as unfavorite") :
                        qsTr ("Mark as favorite")
                }

                onClicked: {
                    manager.markAsFavorite (currentBookmark.id, !currentBookmark.favorite)
                }
            }

            MenuItem {
                visible: currentBookmark !== 0 && currentBookmark !== null
                text: {
                    if (currentBookmark === 0 || currentBookmark === null) {
                        return "";
                    }

                    return currentBookmark.read ?
                        qsTr ("Mark as unread") :
                        qsTr ("Mark as read")

                }
                onClicked: {
                    manager.markAsRead (currentBookmark.id, !currentBookmark.read)
                }
            }
        }

        BusyIndicator {
            id: webviewBusyIndicator
            anchors.centerIn: parent
            anchors.bottom: parent.bottom
            visible: webView.loading;
            running: true;
        }
    }
}





