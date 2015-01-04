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
        interval: 3000
        onTriggered: popup.hide ()
    }

    function hide () {
        if (hideTimer.running)
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

        anchors.verticalCenter: popup.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingMedium
    }

    Label {
        id: messageLabel

        anchors.verticalCenter: popup.verticalCenter
        anchors.left: img.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        horizontalAlignment: Text.AlignLeft

        font.pixelSize: Theme.fontSizeTiny
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        maximumLineCount: 3
    }

    onClicked: hide ()
}
