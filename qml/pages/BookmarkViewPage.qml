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
            readability.item.isBusy = false;
        }
        onDateChanged: {
            dateLabel.text = new Date(date).toLocaleString(Qt.locale(), Locale.ShortFormat)
            currentBookmark.publishedDate = date
        }
    }

    property string bookmarkId
    property variant currentBookmark

    property bool bookmarkRead: currentBookmark && currentBookmark.read
    property bool bookmarkFavorite: currentBookmark && currentBookmark.favorite
    property bool hasContent: currentBookmark && currentBookmark.hasContent

    function generateCustomCss() {
        return  "<style>
            a:link { color: " + Theme.highlightColor + "; }
            img { margin: initial -" + Theme.horizontalPageMargin + "px; }
            h1, h2, h3, h4, h5 { text-align: left; }
        </style>";
    }

    onStatusChanged: {
        if (status === PageStatus.Active && linksbagManager.logged) {
            cover.title = currentBookmark !== null ? currentBookmark.title : ""
            cover.image = currentBookmark.coverImage
            if (!hasContent) {
                readability.bookmarkImage = currentBookmark.imageUrl
                readability.setArticle(currentBookmark.url)
            } else {
                entryText.text = generateCustomCss() + linksbagManager.getContent(bookmarkId)
                readability.item.isBusy = false;
            }
        }
    }

    Component.onCompleted: cover.articleLayout = true
    Component.onDestruction: cover.articleLayout = false

    Connections {
        target: linksbagManager
        onBookmarkReadStateChanged: {
            if (bookmarkId === id) {
                bookmarkRead = readState
            }
        }

        onBookmarkFavoriteStateChanged: {
            if (bookmarkId === id) {
                bookmarkFavorite = favoriteState
            }
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
                    linksbagManager.markAsRead(currentBookmark.id,
                            !bookmarkRead)
                    if (!bookmarkRead) {
                        pageStack.pop();
                    }
                }
            }

            MenuItem {
                text: bookmarkFavorite ?
                        qsTr("Mark as unfavorite") :
                        qsTr("Mark as favorite")
                onClicked: {
                    linksbagManager.markAsFavorite(currentBookmark.id,
                            !bookmarkFavorite)
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
                    linksbagManager.markAsRead(currentBookmark.id,
                            !bookmarkRead)
                }
            }

            MenuItem {
                text: bookmarkFavorite ?
                        qsTr("Mark as unfavorite") :
                        qsTr("Mark as favorite")
                onClicked: {
                    linksbagManager.markAsFavorite(currentBookmark.id,
                            !bookmarkFavorite)
                }
            }

            MenuItem {
                text: qsTr("Open in browser")
                onClicked: {
                    Qt.openUrlExternally(encodeURI(currentBookmark.url))
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
                            height: currentBookmark && currentBookmark.imageUrl.length > 0 ?
                                    mainWindow.height*0.4 :
                                    entryHeaderWrapper.height + Theme.paddingMedium
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
                            currentBookmark.imageUrl :
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
                                  currentBookmark.title :
                                  ""
                        anchors {
                            margins: Theme.paddingLarge;
                            left: parent.left;
                            leftMargin: Theme.horizontalPageMargin;
                            right: parent.right;
                            rightMargin: Theme.horizontalPageMargin;
                        }
                    }

                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: Theme.paddingLarge
                        }
                        Item {
                            id: sourceLabel
                            width: sourceText.paintedWidth
                            height: sourceText.paintedHeight + Theme.paddingSmall*6
                            visible: sourceText.text !== ""
                            Layout.alignment: dateLabel.visible ? Qt.AlignLeft : Qt.AlignHCenter
                            Text {
                                id: sourceText
                                color: Theme.highlightColor
                                horizontalAlignment: dateLabel.visible ? Qt.AlignLeft : Qt.AlignHCenter
                                text: {
                                    if (currentBookmark) {
                                        var matches = currentBookmark.url.toString()
                                                .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                                        return matches ? matches[1] : currentBookmark.url
                                    }
                                    else {
                                        return ""
                                    }
                                }
                            }
                        }

                        Item {
                            id: dateLabel
                            property alias text: dateText.text
                            width: dateText.paintedWidth
                            height: dateText.paintedHeight + Theme.paddingSmall*6
                            visible: dateText.text !== ""
                            Layout.alignment: Qt.AlignRight
                            Text {
                                id: dateText
                                color: Theme.highlightColor
                                text: new Date(currentBookmark.publishedDate)
                                        .toLocaleString(Qt.locale(), Locale.ShortFormat)
                                horizontalAlignment: Qt.AlignRight
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
        z: 2
        running: linksbagManager.busy || readability.item.isBusy;
    }
}





