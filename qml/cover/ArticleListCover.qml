/*
The MIT License (MIT)

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

Item {
    anchors.fill: parent

    property alias model: listView.model
    property string filter: mainWindow.getStatusFilterString(mainWindow.settings.statusFilter)

    Label {
        id: coverHeaderCount
        text: listView.count
        x: Theme.paddingLarge
        y: Theme.paddingMedium
        font.pixelSize: Theme.fontSizeHuge
    }

    Label {
        id: unreadLabel

        text: qsTr("%1 bookmarks").arg(filter)
        font.pixelSize: Theme.fontSizeExtraSmall
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        lineHeight: 0.8
        height: implicitHeight/0.8
        verticalAlignment: Text.AlignVCenter
        anchors {
            right: parent.right
            rightMargin: Theme.paddingLarge
            left: coverHeaderCount.right
            leftMargin: Theme.paddingMedium
            baseline: coverHeaderCount.baseline
            baselineOffset: lineCount > 1 ? -implicitHeight/2 : -(height-implicitHeight)/2
        }
    }

    OpacityRampEffect {
        offset: 0.5
        sourceItem: unreadLabel
        enabled: unreadLabel.implicitWidth > Math.ceil(unreadLabel.width)
    }

    SilicaListView {
        id: listView

        anchors {
            top: unreadLabel.bottom;
            left: parent.left;
            right: parent.right;
            margins: Theme.paddingLarge;
            bottom: parent.bottom;
            bottomMargin: 0;
        }

        spacing: Theme.paddingSmall

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
                    width: parent.width

                    font.pixelSize:  Theme.fontSizeTiny
                    truncationMode: TruncationMode.Fade
                    color: Theme.secondaryColor

                    text: {
                        var matches = bookmarkUrl.toString()
                                .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                        return matches ? matches[1] : bookmarkUrl
                    }
                }
            }
        }
    }
}
