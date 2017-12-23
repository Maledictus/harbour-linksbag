/*
The MIT License (MIT)

Copyright (c) 2014-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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

Cover {
    id: coverPage

    property alias model: listView.model

    anchors.fill: parent
    transparent: true

    BackgroundItem {
        anchors.fill: parent
        Image {
            id: coverBgImage
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
            source: "qrc:/images/linksbag-cover"
            opacity: 0.1
        }
    }

    Row {
        id: coverHeader
        height: Theme.itemSizeSmall
        anchors {
            top: parent.top;
            left: parent.left;
            right: parent.right;
            topMargin: Theme.paddingMedium
            leftMargin: Theme.paddingLarge;
            rightMargin: Theme.paddingLarge;
        }
        Label {
            anchors { top: parent.top; left: parent.left; }
            id: coverHeaderCount
            font.pixelSize: Theme.fontSizeHuge
            color: Theme.primaryColor
            text: listView.count
        }
        Label  {
            id: coverHeaderTitle
            anchors {
                top: parent.top;
                topMargin: Theme.paddingMedium;
                right: parent.right;
                rightMargin: Theme.paddingLarge;
                leftMargin: Theme.paddingMedium;
                left: coverHeaderCount.right;
            }
            font.pixelSize: Theme.fontSizeExtraSmall
            text: qsTr("Unread \narticles")
        }
    }

    SilicaListView {
        id: listView

        anchors {
            top: coverHeader.bottom;
            left: parent.left;
            right: parent.right;
            margins: Theme.paddingLarge;
            bottom: parent.bottom;
        }

        spacing: 10

        width: parent.width
        clip: true

        delegate: BackgroundItem {
            id: delegate
            height: Theme.itemSizeExtraSmall

            Column {
                width: parent.width;
                Label {
                    id: itemLabel
                    width: parent.width
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    text: bookmarkTitle
                }
                Label {
                    id: sourceLabel
                    width: parent.width

                    font.pixelSize:  Theme.fontSizeTiny
                    elide: Text.ElideRight
                    color: Theme.secondaryHighlightColor

                    text: {
                        var matches = bookmarkUrl.toString()
                                .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                        return matches ? matches[1] : bookmarkUrl
                    }
                }
            }
        }
    }

    CoverActionList {
        id: actionsList
        CoverAction {
            id: refreshAction
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                linksbagManager.refreshBookmarks()
            }
        }
    }
}
