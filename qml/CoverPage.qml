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

CoverBackground {
    id: coverPage

    signal refresh()
    BackgroundItem {
        anchors.fill: parent

        Image {
            id: coverBgImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter:  parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/linksbag.png"
            opacity: 0.2
            horizontalAlignment: Image.AlignHCenter
            verticalAlignment: Image.AlignVCenter
            width: 128
            height: 128
        }
    }

    SilicaListView {
        anchors.bottom: actionsList.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.paddingLarge
        height: 240

        spacing: 10

        model: bookmarksPage.m
        width: parent.width
        clip: true

        delegate: BackgroundItem {
            id: delegate
            height: 30

            property string bookmarkTitle: title
            property bool bookmarkIsRead : read

            Label {
                id: titleLabel

                anchors.fill: parent

                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeTiny

                text: delegate.bookmarkTitle
            }
        }
    }

    CoverActionList {
        id: actionsList
        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: refresh()
        }
    }
}
