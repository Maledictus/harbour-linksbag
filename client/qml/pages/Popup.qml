/*
The MIT License (MIT)

Copyright (c) 2016 Oleg Linkin <maledictusdemagog@gmail.com>

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

MouseArea {
    id: popup

    anchors.top: parent.top
    width: parent.width
    height: messageLabel.paintedHeight + Theme.paddingSmall * 2

    property alias title: messageLabel.text
    property alias timeout: hideTimer.interval
    property alias image: img.source

    visible: opacity > 0
    opacity: 0.0

    Behavior on opacity {
        FadeAnimation {}
    }

    Rectangle {
        id: bg

        anchors.fill: parent
        color: Theme.rgba(Theme.secondaryHighlightColor, 0.4)
    }

    Timer {
        id: hideTimer

        triggeredOnStart: false
        repeat: false
        interval: 5000
        onTriggered: popup.hide()
    }

    function hide() {
        messageLabel.text = ""
        hideTimer.stop()
        popup.opacity = 0.0
    }

    function show() {
        popup.opacity = 1.0
        hideTimer.restart()
    }

    function notify(text) {
        popup.title = text
        show()
    }

    Image {
        id: img

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
    }

    Timer {
        id: backPosTimer

        triggeredOnStart: false
        repeat: false
        interval: 250
        onTriggered: flickable.contentX = 0
    }


    SilicaFlickable {
        id: flickable
        anchors.left: img.right
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        anchors.verticalCenter: img.verticalCenter

        height: messageLabel.paintedHeight
        contentWidth: messageLabel.width
        clip:true

        flickableDirection: Flickable.HorizontalFlick
        PropertyAnimation on contentX {
            id: animation

            from: 0
            duration: 4000
            loops: 1

            onStopped: {
                backPosTimer.start()
            }
        }

        Label {
            id: messageLabel

            anchors.left: parent.left
            horizontalAlignment: Text.AlignLeft

            font.pixelSize: Theme.fontSizeTiny

            onTextChanged: {
                if (text != "" && flickable.width < messageLabel.width) {
                    animation.to = messageLabel.width - flickable.width +
                            Theme.paddingMedium * 2
                    animation.restart ()
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: {
                hide()
            }
        }
    }

    onClicked: hide()
}
