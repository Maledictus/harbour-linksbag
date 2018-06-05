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

import QtQuick 2.5
import Sailfish.Silica 1.0
import harbour.linksbag 1.0

Item {
    property bool bookmarkRead: bookmark ? bookmark.read : false
    property bool bookmarkFavorite: bookmark ? bookmark.favorite : false
    property bool hasContent: bookmark ? bookmark.hasContent : false
    property string publishedDate

    Drawer {
        id:drawer
        anchors.fill: parent
        dock: mainWindow.isLandscape ? Dock.Left : Dock.Top
        Flickable {
            id: imageFlickable
            anchors.fill: parent
            contentWidth: imageContainer.width
            contentHeight: imageContainer.height
            clip: true
            onHeightChanged: {
                if (imagePreview.status === Image.Ready) {
                    imagePreview.fitToScreen()
                }
            }

            Item {
                id: imageContainer
                width: Math.max(imagePreview.width * imagePreview.scale, imageFlickable.width)
                height: Math.max(imagePreview.height * imagePreview.scale, imageFlickable.height)

                Image {
                    id: imagePreview

                    property real prevScale

                    function fitToScreen() {
                        scale = Math.min(imageFlickable.width / width, imageFlickable.height / height, 1)
                        pinchArea.minScale = scale
                        prevScale = scale
                    }

                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    cache: true
                    asynchronous: true
                    sourceSize.width: Screen.width;
                    smooth: false
                    source: !hasContent ? (bookmark ? bookmark.url : "") : linksbagManager.getContentUri(bookmark.id)

                    onStatusChanged: {
                        if (status === Image.Ready && !hasContent) {
                            imagePreview.grabToImage(function(result) {
                                linksbagManager.updateContent(bookmark.id, result.image)
                            })
                        }
                    }

                    onScaleChanged: {
                        if ((width * scale) > imageFlickable.width) {
                            var xoff = (imageFlickable.width / 2 + imageFlickable.contentX) *
                                    scale / prevScale;
                            imageFlickable.contentX = xoff - imageFlickable.width / 2
                        }
                        if ((height * scale) > imageFlickable.height) {
                            var yoff = (imageFlickable.height / 2 + imageFlickable.contentY) *
                                    scale / prevScale;
                            imageFlickable.contentY = yoff - imageFlickable.height / 2
                        }
                        prevScale = scale
                    }
                }
            }

            PinchArea {
                id: pinchArea
                opacity: 0.3
                property real minScale: 1.0
                property real maxScale: 3.0

                anchors.fill: parent
                enabled: imagePreview.status === Image.Ready
                pinch.target: imagePreview
                pinch.minimumScale: minScale * 0.5 // This is to create "bounce back effect"
                pinch.maximumScale: maxScale * 1.5 // when over zoomed

                onPinchFinished: {
                    imageFlickable.returnToBounds()
                    if (imagePreview.scale < pinchArea.minScale) {
                        bounceBackAnimation.to = pinchArea.minScale
                        bounceBackAnimation.start()
                    }
                    else if (imagePreview.scale > pinchArea.maxScale) {
                        bounceBackAnimation.to = pinchArea.maxScale
                        bounceBackAnimation.start()
                    }
                }
                NumberAnimation {
                    id: bounceBackAnimation
                    target: imagePreview
                    duration: 250
                    property: "scale"
                    from: imagePreview.scale
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: imagePreview.status === Image.Ready
                    onClicked: drawer.open = !drawer.open
                }
            }
        }

        background: SilicaFlickable {
            anchors.fill: parent
            PullDownMenu {
                enabled: !busyIndicator.running
                MenuItem {
                    text: qsTr("Reload")
                    onClicked: {
                        imagePreview.source = bookmark ? bookmark.url : ""
                    }
                }

                MenuItem {
                    text: bookmarkRead ?
                            qsTr("Mark as unread") :
                            qsTr("Mark as read")

                    onClicked: {
                        linksbagManager.markAsRead(bookmark.id, !bookmarkRead)
                    }
                }

                MenuItem {
                    text: bookmarkFavorite ?
                            qsTr("Mark as unfavorite") :
                            qsTr("Mark as favorite")
                    onClicked: {
                        linksbagManager.markAsFavorite(bookmark.id, !bookmarkFavorite)
                    }
                }

                MenuItem {
                    text: qsTr("Open in browser")
                    onClicked: {
                        Qt.openUrlExternally(encodeURI(bookmark.url))
                    }
                }
            }
        }
    }
    BusyIndicator {
        id: busyIndicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: imagePreview.status === Image.Loading || (linksbagManager ? linksbagManager.busy : false)
        visible: running
    }
}
