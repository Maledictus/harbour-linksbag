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
    anchors.fill: parent

    property string bookmarkId: bookmark ? bookmark.id : ""
    property url bookmarkUrl: bookmark ? bookmark.url : ""
    property bool bookmarkRead: bookmark ? bookmark.read : false
    property bool bookmarkFavorite: bookmark ? bookmark.favorite : false
    property bool hasContent: bookmark ? bookmark.hasContent : false
    property string publishedDate

    SilicaFlickable {
        id: flickable

        anchors.fill: parent

        property bool scaled: false

        readonly property bool enableZoom: true
        property bool active: true
        readonly property bool error: photo.status == Image.Error

        property real _fittedScale: Math.min(maximumZoom, Math.min(width / implicitWidth,
                                                                   height / implicitHeight))
        property real _scale
        // Calculate a default value which produces approximately same level of zoom
        // on devices with different screen resolutions.
        property real maximumZoom: Math.max(Screen.width, Screen.height) / 200
        property int _maximumZoomedWidth: _fullWidth * maximumZoom
        property int _maximumZoomedHeight: _fullHeight * maximumZoom
        property int _minimumZoomedWidth: implicitWidth * _fittedScale
        property int _minimumZoomedHeight: implicitHeight * _fittedScale
        property bool _zoomAllowed: enableZoom && _fittedScale !== maximumZoom
        property int _fullWidth: Math.max(photo.implicitWidth, largePhoto.implicitWidth)
        property int _fullHeight: Math.max(photo.implicitHeight, largePhoto.implicitHeight)

        signal clicked

        // Override SilicaFlickable's pressDelay because otherwise it will
        // block touch events going to PinchArea in certain cases.
        pressDelay: 0

        enabled: !zoomOutAnimation.running
        flickableDirection: Flickable.HorizontalAndVerticalFlick

        implicitWidth: photo.implicitWidth
        implicitHeight: photo.implicitHeight

        contentWidth: container.width
        contentHeight: container.height

        readonly property bool _active: active
        on_ActiveChanged: {
            if (!_active) {
                _resetScale()
                largePhoto.source = ""
            }
        }
        interactive: scaled && !mouseArea.horizontalDragUnused

        function _resetScale() {
            if (scaled) {
                _scale = _fittedScale
                scaled = false
            }
        }

        function _scaleImage(scale, center, prevCenter) {
            if (largePhoto.source != photo.source) {
                largePhoto.source = photo.source
            }

            var newWidth
            var newHeight
            var oldWidth = contentWidth
            var oldHeight = contentHeight

            newWidth = (photo.width) * scale
            if (newWidth <= flickable._minimumZoomedWidth) {
                _resetScale()
                return
            } else {
                newWidth = Math.min(newWidth, flickable._maximumZoomedWidth)
                _scale = newWidth / implicitWidth
                newHeight = photo.height
            }
            // move center
            contentX += prevCenter.x - center.x
            contentY += prevCenter.y - center.y

            // scale about center
            if (newWidth > flickable.width)
                contentX -= (oldWidth - newWidth)/(oldWidth/prevCenter.x)
            if (newHeight > flickable.height)
                contentY -= (oldHeight - newHeight)/(oldHeight/prevCenter.y)

            scaled = true
        }

        Binding { // Update scale on orientation changes
            target: flickable
            when: !flickable.scaled
            property: "_scale"
            value: flickable._fittedScale
        }

        Connections {
            target: pageStack
            onDragInProgressChanged: {
                if (pageStack.dragInProgress && pageStack._noGrabbing) {
                    pageStack._grabMouse()
                }
            }
        }

        children: ScrollDecorator {}

        PinchArea {
            id: container
            enabled: photo.status == Image.Ready
            onPinchUpdated: {
                if (flickable._zoomAllowed)
                    flickable._scaleImage(1.0 + pinch.scale - pinch.previousScale,
                            pinch.center, pinch.previousCenter)
            }
            onPinchFinished: flickable.returnToBounds()
            width: Math.max(flickable.width, photo.width)
            height: Math.max(flickable.height, photo.height)

            Image {
                id: photo
                property var errorLabel
                objectName: "zoomableImage"

                smooth: !(flickable.movingVertically || flickable.movingHorizontally)
                width: Math.ceil(implicitWidth * flickable._scale)
                height: Math.ceil(implicitHeight * flickable._scale)
                sourceSize.width: Screen.height
                fillMode:  Image.PreserveAspectFit
                asynchronous: true
                anchors.centerIn: parent
                cache: false
                source: !hasContent ? bookmarkUrl : linksbagManager.getContentUri(bookmarkId)

                onStatusChanged: {
                    if (status == Image.Error) {
                       errorLabel = errorLabelComponent.createObject(photo)
                    }
                    else if (status == Image.Ready && !hasContent) {
                        photo.grabToImage(function(result) {
                            linksbagManager.updateContent(bookmarkId, result.image)
                        })
                    }
                }

                onSourceChanged: {
                    if (errorLabel) {
                        errorLabel.destroy()
                    }

                    flickable.scaled = false
                }

                opacity: status == Image.Ready ? 1 : 0
                Behavior on opacity { FadeAnimation{} }
            }
            Image {
                id: largePhoto
                sourceSize {
                    width: 3264
                    height: 3264
                }
                cache: false
                asynchronous: true
                anchors.fill: photo
            }

            BusyIndicator {
                running: photo.status === Image.Loading &&
                        !delayBusyIndicator.running
                size: BusyIndicatorSize.Large
                anchors.centerIn: parent
                Timer {
                    id: delayBusyIndicator
                    running: photo.status === Image.Loading
                    interval: 1000
                }
            }

            MouseArea {
                id: mouseArea

                property int startX
                property int startY
                property bool horizontalDragUnused
                property bool verticalDragUnused

                function reset() {
                    verticalDragUnused = false
                    horizontalDragUnused = false
                }
                onPressed: {
                    reset()
                    startX = mouseX
                    startY = mouseY
                }
                onPositionChanged: {
                    if (container.pinch.active) return
                    if (mouseX - startX > Theme.startDragDistance && flickable.atXBeginning
                            || mouseX - startX < -Theme.startDragDistance && flickable.atXEnd) {
                        horizontalDragUnused = true
                    } else if (mouseY - startY > Theme.startDragDistance && flickable.atYBeginning
                               || mouseY - startY < -Theme.startDragDistance && flickable.atYEnd) {

                        verticalDragUnused = true
                    }
                }
                onClicked: overlay.active = !overlay.active
                onDoubleClicked: {
                    if (_scale !== _fittedScale) {
                        zoomOutAnimation.start()
                    }
                }

                anchors.fill: parent

                ParallelAnimation {
                    id: zoomOutAnimation
                    SequentialAnimation {
                        NumberAnimation {
                            target: flickable
                            property: "_scale"
                            to: flickable._fittedScale
                            easing.type: Easing.InOutQuad
                            duration: 200
                        }
                        ScriptAction {
                            script: scaled = false
                        }
                    }
                    NumberAnimation {
                        target: flickable
                        properties: "contentX, contentY"
                        to: 0
                        easing.type: Easing.InOutQuad
                        duration: 200
                    }
                }
            }
        }

        Component {
            id: errorLabelComponent
            InfoLabel {
                text: qsTr("Oops, can't display the image")
                anchors.verticalCenter: parent.verticalCenter
                opacity: photo.status == Image.Error ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator {}}
            }
        }
    }

    ImageOverlay {
        id: overlay

        sourceBookmark: bookmark
        anchors.fill: parent
        z: 2

        onRemove: {
            var bkm = overlay.sourceBookmark
            remorseAction(qsTr("Deleting"), function() {
                linksbagManager.removeBookmark(bkm.id)
                if (bkm === overlay.bookmark) {
                    pageStack.pop()
                }
            })
        }
    }
}

