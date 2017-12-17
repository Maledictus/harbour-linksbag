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

Cover {
    id: coverPage

    property alias model: listView.model

    anchors.fill: parent
    transparent: true

    BackgroundItem {
        anchors.centerIn: parent
        width: coverBgImage.width
        height: coverBgImage.height
        Image {
            id: coverBgImage
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            source: "qrc:/images/harbour-linksbag.png"
            opacity: 0.5
            width: 128
            height: 128
        }
    }

    SilicaListView {
        id: listView

        anchors.bottom: actionsList.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.paddingMedium
        height: 240

        spacing: 10

        width: parent.width
        clip: true

        delegate: BackgroundItem {
            id: delegate
            height: 30

            Label {
                id: titleLabel

                anchors.fill: parent

                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeTiny

                text: bookmarkTitle
            }
        }
    }

    CoverActionList {
        id: actionsList
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                linksbagManager.refreshBookmarks()
            }
        }
    }
}