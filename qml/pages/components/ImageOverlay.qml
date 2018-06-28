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
import Sailfish.Silica 1.0

Item {
    id: overlay

    property string bookmarkId: sourceBookmark ? sourceBookmark.id : ""
    property bool bookmarkRead: sourceBookmark ? sourceBookmark.read : false
    property bool bookmarkFavorite: sourceBookmark ? sourceBookmark.favorite : false

    property bool active: true
    property bool viewerOnlyMode

    property alias toolbar: toolbar
    readonly property bool allowed: true
    property real fadeOpacity: 0.6

    property var sourceBookmark

    property string itemId
    property bool error

    enabled: active && allowed && sourceBookmark != null && !(_remorsePopup && _remorsePopup.active)
    Behavior on opacity { FadeAnimator {}}
    opacity: enabled ? 1.0 : 0.0

    signal remove()

    property Item _remorsePopup
    function remorseAction(text, action) {
        if (!_remorsePopup) {
           _remorsePopup = remorsePopupComponent.createObject(overlay)
        }
        if (!_remorsePopup.active) {
           _remorsePopup.execute(text, action)
        }
    }

    onSourceBookmarkChanged: {
        if (_remorsePopup && _remorsePopup.active) {
            _remorsePopup.trigger()
        }
    }

    Rectangle {
        id: bottomFade
        width: parent.width
        height: toolbar.height + 2* toolbar.anchors.bottomMargin
        anchors.bottom: parent.bottom
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.8; color: Qt.rgba(0, 0, 0, fadeOpacity) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, fadeOpacity) }
        }
    }

    Row {
        id: toolbar

        x: parent.width/2 - width/2
        anchors  {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge

        IconButton {
            id: deleteButton
            icon.source: "image://theme/icon-m-delete"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                overlay.remove()
            }
        }

        IconButton {
            id: readButton
            icon.source: bookmarkRead ?
                    "image://theme/icon-m-add" : "image://theme/icon-m-acknowledge"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                bookmarkRead = !bookmarkRead
                linksbagManager.markAsRead(bookmarkId, bookmarkRead)
            }
        }

        IconButton {
            id: favoriteButton
            icon.source: "image://Theme/icon-m-favorite" +
                    (bookmarkFavorite ? "" : "-selected")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                bookmarkFavorite = !bookmarkFavorite
                linksbagManager.markAsFavorite(bookmarkId, bookmarkFavorite)
            }
        }

        IconButton {
            id: clipboardButton
            icon.source: "image://Theme/icon-m-clipboard"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                Clipboard.text = bookmarkUrl
                linksbagManager.notify(qsTr("Url copied into clipboard"))
            }
        }

        IconButton {
            id: browserButton
            icon.source: "image://Theme/icon-m-region"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                Qt.openUrlExternally(encodeURI(bookmarkUrl))
            }
        }
    }

    BusyIndicator {
        running: linksbagManager ? linksbagManager.busy : false
        visible: running
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    Component {
        id: remorsePopupComponent
        RemorsePopup {}
    }
}
