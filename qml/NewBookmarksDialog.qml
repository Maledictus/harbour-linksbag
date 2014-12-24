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

Dialog {

    property variant selectedBookmarks: []

    function load () {
        var newBookmarks = cacheManager.GetNewBookmarks ()
        for (var i = 0; i < newBookmarks.length; ++i)
        {
            var bookmark = newBookmarks [i];
            newBookmarksModel.append ({ "title": bookmark.title,
                    "url": bookmark.url, "selected": false })
        }
    }

    function updateItem (index, value) {
        console.log (index, value)
        newBookmarksModel.get (index).selected = value
    }

    onDone: {
        var t = new Array (0)
        for (var i = 0; i < newBookmarksView.count; ++i) {
            if (newBookmarksModel.get (i).selected) {
                t.push (newBookmarksModel.get (i))
            }
        }
        selectedBookmarks = t
    }

    ListModel {
        id: newBookmarksModel
    }

    SilicaListView {
        id: newBookmarksView

        anchors.fill: parent

        header: Column {
            id: headerColumn
            width: newBookmarksView.width
            DialogHeader {
                acceptText: qsTr ("Add")
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                text: qsTr ("Select bookmarks which you want to put in pocket")
                wrapMode: Text.WordWrap
            }
        }

        spacing: Theme.paddingSmall

        ViewPlaceholder {
            enabled: newBookmarksModel.count == 0
            text: qsTr ("There are not new bookmarks")
        }

        model: newBookmarksModel
        delegate: ListItem {

            height: contentItem.childrenRect.height
            width: newBookmarksView.width

            Switch {
                id: switchIndicator

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Label {
                id: titleLabel

                width: newBookmarksView.width
                anchors.left: switchIndicator.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                elide: Text.ElideRight

                text: title
            }

            Label {

                width: newBookmarksView.width
                anchors.left: switchIndicator.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium

                anchors.top: titleLabel.bottom

                elide: Text.ElideRight
                font.pixelSize: Theme.fontSizeTiny

                text: url
            }

            onClicked: {
                switchIndicator.checked = switchIndicator.checked ?
                     false :
                     true
                updateItem (index, switchIndicator.checked)
            }
        }
    }
}
