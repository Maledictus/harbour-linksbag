/*
The MIT License (MIT)

Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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
import harbour.linksbag 1.0
import "."

Page {
    property var bookmarksPage
    property var currentBookmarkId
    property var bookmarksToSync

    ParserLoader {
        id: readability
        onEntryChanged: linksbagManager.updateContent(currentBookmarkId, entry);
    }

    SilicaListView {
        id: listview

        anchors.fill: parent
        model: linksbagManager.downloadingModel

        header: PageHeader {
            title: qsTr("Downloading")
            description: qsTr("%1 remaining").arg(listview.count)
        }

        delegate: ListItem {
            id: listitem
            width: listview.width

            Component.onCompleted: if (index == 0) {
               currentBookmarkId = bookmarkID;
               readability.setArticle(bookmarkUrl)
           }

            Label {
                 id: label
                 anchors {
                     left: parent.left
                     leftMargin: Theme.horizontalPageMargin
                     right: parent.right
                     rightMargin: Theme.horizontalPageMargin
                 }
                 text: bookmarkTitle
                 truncationMode: TruncationMode.Fade
                 color: listitem.highlighted ? Theme.highlightColor : Theme.primaryColor
             }
             Label {
                 anchors {
                     top: label.bottom
                     left: parent.left
                     leftMargin: Theme.horizontalPageMargin
                     right: parent.right
                     rightMargin: Theme.horizontalPageMargin
                 }
                 text: currentBookmarkId == bookmarkID ? qsTr("Downloading") : qsTr("Queued")
                 font.pixelSize: Theme.fontSizeSmall
                 color: listitem.highlighted ? Theme.highlightColor : Theme.secondaryColor
             }
        }
    }
}
