import QtQuick 2.0
import Sailfish.Silica 1.0
MouseArea {
    id: popup

    anchors.top: parent.top
    width: parent.width
    height: messageLabel.paintedHeight + (Theme.paddingSmall * 2)

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
        onTriggered: popup.hide ()
    }

    function hide () {
        if (hideTimer.running)
            messageLabel.text = ""
            hideTimer.stop ()
            popup.opacity = 0.0
    }

    function show () {
        popup.opacity = 1.0
        hideTimer.restart ()
    }

    function notify (text) {
        popup.title = text
        show()
    }

    Image {
        id: img

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
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
        anchors.verticalCenter: parent.verticalCenter

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
                backPosTimer.start ()
            }
        }

        Label {
            id: messageLabel

            anchors.left: parent.left
            horizontalAlignment: Text.AlignLeft

            font.pixelSize: Theme.fontSizeTiny

            onTextChanged: {
                if (text != "" && flickable.width < messageLabel.width) {
                    animation.to = messageLabel.width - flickable.width + Theme.paddingMedium * 2
                    animation.restart ()
                }
            }
        }
    }

    onClicked: hide ()
}
