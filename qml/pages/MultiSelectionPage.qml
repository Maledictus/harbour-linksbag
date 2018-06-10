/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>

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
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
import harbour.linksbag 1.0
import "./components"

Page {
    property int selectionCount
    property bool deletingInProgress
    property BookmarkRemorsePopup removeRemorse
    property var selectionModel

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            if (selectionCount && !deletingInProgress) {
                selectionModel.deselectAllBookmarks()
            }
        }
    }

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: linksbagManager.busy
        visible: running
        z: 2
    }

    function _deleteClicked() {
        deletingInProgress = true
        removeRemorse.deleteCount = selectionCount
        removeRemorse.selectionModel = selectionModel
        removeRemorse.deleteSelectedBookmarks()
        pageStack.pop()
    }

    SilicaListView {
        clip: dockedPanel.open

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: dockedPanel.top
        }

        header: PageHeader {
            title: selectionCount ?
                qsTr("Selected %1").arg(selectionCount) :
                qsTr("Selected")
        }

        model: selectionModel

        delegate: BookmarkItem {
            function _toggleSelection() {
                if (model.bookmarkSelected) {
                    selectionModel.deselectBookmark(model.index)
                    --selectionCount
                }
                else {
                     selectionModel.selectBookmark(model.index)
                    ++selectionCount
                }
            }

            menu: undefined // actions in docked panel
            selectMode: true

            onClicked: {
                _toggleSelection()
            }

            onPressAndHold: {
                _toggleSelection()
            }
        }

        VerticalScrollDecorator {}
    }

    DockedPanel {
        id: dockedPanel
        width: parent.width
        height: Theme.itemSizeLarge
        dock: Dock.Bottom
        open: selectionCount

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "image://theme/graphic-gradient-edge"
        }
        Row {
            Item {
                width: dockedPanel.width / 3
                height: Theme.itemSizeLarge
                IconButton {
                    anchors.centerIn: parent
                    icon.source: "image://theme/icon-m-delete"
                    onClicked: _deleteClicked()
                }
            }

            Item {
                width: dockedPanel.width / 3
                height: Theme.itemSizeLarge
                IconButton {
                    anchors.centerIn: parent
                    icon.source: "image://Theme/icon-m-favorite" +
                                 (selectionModel && selectionModel.unfavoriteBookmarksSelected ? "-selected" : "")
                    onClicked: {
                        if (selectionModel) {
                            linksbagManager.markAsFavorite(selectionModel.selectedBookmarks(),
                                    selectionModel.unfavoriteBookmarksSelected)
                            selectionModel.deselectAllBookmarks()
                        }
                        selectionCount = 0
                    }
                }
            }

            Item {
                width: dockedPanel.width / 3
                height: Theme.itemSizeLarge
                IconButton {
                    anchors.centerIn: parent
                    icon.source: selectionModel && selectionModel.unreadBookmarksSelected ?
                            "image://theme/icon-m-acknowledge" : "image://theme/icon-m-add"
                    onClicked: {
                        if (selectionModel) {
                            linksbagManager.markAsRead(selectionModel.selectedBookmarks(),
                                    selectionModel.unreadBookmarksSelected)
                            selectionModel.deselectAllBookmarks()
                        }
                        selectionCount = 0
                    }
                }
            }
        }
    }
}


