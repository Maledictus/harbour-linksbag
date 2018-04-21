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
import "."

Page {
    id: page

    Connections {
        target: Theme
        onHighlightColorChanged: entryText.text = generateCustomCss() + readability.entry;
    }

    ParserLoader {
        id: readability
        onEntryChanged: {
            linksbagManager.updateContent(bookmarkId, entry);
            entryText.text = generateCustomCss() + entry;
            hasContent = true;
        }
    }

    property string bookmarkId
    property variant currentBookmark

    property bool bookmarkRead: false
    property bool bookmarkFavorite: false
    property bool hasContent: false

    function generateCustomCss() {
        return  "<style>
            a:link { color: " + Theme.highlightColor + "; }
            img { margin: initial -" + Theme.horizontalPageMargin + "px; }
            h1, h2, h3, h4, h5 { text-align: left; }
        </style>";
    }

    onStatusChanged: {
        if (status == PageStatus.Active && linksbagManager.logged) {
            currentBookmark = linksbagManager.bookmarksModel.getBookmark(bookmarkId)
            hasContent = currentBookmark.bookmarkHasContent
            cover.title = currentBookmark.bookmarkTitle
            bookmarkRead = currentBookmark && currentBookmark.bookmarkRead
            bookmarkFavorite = currentBookmark && currentBookmark.bookmarkFavorite

            if (!hasContent) {
                readability.bookmarkImage = currentBookmark.bookmarkImageUrl
                readability.setArticle(currentBookmark.bookmarkUrl)
            } else {
                entryText.text = generateCustomCss() + linksbagManager.getContent(bookmarkId)
            }

            cover.image = currentBookmark.bookmarkCoverImage
        }
    }

    Component.onCompleted: cover.articleLayout = true
    Component.onDestruction: cover.articleLayout = false

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

        PushUpMenu {
            enabled: !busyIndicator.running
            MenuItem {
                text: bookmarkRead ?
                        qsTr("Mark as unread") :
                        qsTr("Mark as read")

                onClicked: {
                    linksbagManager.markAsRead(currentBookmark.bookmarkID,
                            !currentBookmark.bookmarkRead)
                    if (!bookmarkRead)
                        pageStack.pop();
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

        PullDownMenu {
            enabled: !busyIndicator.running
            MenuItem {
                text: qsTr("Reload")
                onClicked: {
                    hasContent = false;
                    readability.setArticle(currentBookmark.bookmarkUrl);
                }
            }

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
            anchors.right: parent.right

            Item {
                id: header
                state: !hasContent ? "loading" : "loaded"
                anchors {
                    left: parent.left;
                    right: parent.right;
                }

                states: [
                    State {
                        name: "loading"
                        PropertyChanges {
                            target: header;
                            height: mainWindow.height
                        }
                    },
                    State {
                        name: "loaded"
                        PropertyChanges {
                            target: header;
                            height: currentBookmark && currentBookmark.bookmarkImageUrl.length > 0 ?
                                    mainWindow.height*0.4 :
                                    entryHeaderWrapper.childrenRect.height+Theme.paddingMedium
                        }
                    }
                ]

                transitions: Transition {
                    PropertyAnimation {
                        properties: "height";
                        easing.type: Easing.InOutQuad;
                        duration: hasContent ? 0 : 300 }
                }

                Image {
                    asynchronous: true
                    smooth: false
                    id: thumbnailImage
                    source: currentBookmark ?
                            currentBookmark.bookmarkImageUrl :
                            ""
                    anchors.fill: parent;
                    fillMode: Image.PreserveAspectCrop
                }
                OpacityRampEffect {
                    slope: 1.0
                    offset: 0
                    sourceItem: thumbnailImage
                    direction: OpacityRamp.TopToBottom
                }

                Column {
                    id: entryHeaderWrapper
                    anchors {
                        bottom: parent.bottom;
                        left: parent.left;
                        right: parent.right;
                    }
                    Label {
                        id: entryHeader
                        width: parent.width
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Qt.AlignCenter
                        font.pixelSize: Theme.fontSizeExtraLarge
                        text: currentBookmark ?
                                  currentBookmark.bookmarkTitle :
                                  ""
                        anchors {
                            margins: Theme.paddingLarge;
                            left: parent.left;
                            leftMargin: Theme.horizontalPageMargin;
                            right: parent.right;
                            rightMargin: Theme.horizontalPageMargin;
                        }
                    }

                    Item {
                        id: sourceLabel
                        anchors {
                            horizontalCenter: parent.horizontalCenter;
                            margins: Theme.paddingLarge
                        }
                        width: sourceText.paintedWidth
                        height: sourceText.paintedHeight + Theme.paddingSmall*6
                        visible: sourceText.text !== ""
                        Text {
                            id: sourceText
                            anchors.centerIn: parent
                            color: Theme.highlightColor
                            text: {
                                if (currentBookmark) {
                                    var matches = currentBookmark.bookmarkUrl.toString()
                                            .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                                    return matches ? matches[1] : currentBookmark.bookmarkUrl
                                }
                                else {
                                    return ""
                                }
                            }
                        }
                    }
                }
            }

            Item {
                height: Theme.paddingMedium
                width: parent.width
            }

            Label {
                id: entryText
                width: parent.width

                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                horizontalAlignment: Qt.AlignJustify

                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin

            }
            Item {
                // additional padding at the bottom
                height: Theme.paddingLarge*4
                width: parent.width
            }
       }

       VerticalScrollDecorator {}
    }

    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: true
        running: linksbagManager.busy || readability.isBusy;
    }
}





