import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

ShareDialog {
    id: root

    property bool isLink: root.content && ('type') in root.content && root.content.type === "text/x-url"

    onAccepted: {
        shareItem.start ()
    }

    Column {
        anchors.fill: parent

        spacing: Theme.paddingMedium

        DialogHeader {
            acceptText: qsTr ("Put in pocket")
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.isLink
            text: root.content.linkTitle
            width: root.width - Theme.paddingLarge * 2
            elide: Text.ElideRight
            wrapMode:  Text.Wrap
            maximumLineCount: 2
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.highlightColor
            text: root.content.status
            width: root.width - Theme.paddingLarge * 2
            elide: Text.ElideRight
            wrapMode:  Text.Wrap
            maximumLineCount: 3
            opacity: .6
            font.pixelSize: Theme.fontSizeSmall
        }

        TextArea {
            id: tagsArea

            visible: root.isLink
            label: qsTr ("Tags")
            placeholderText: qsTr ("Tags (separate by comma)...")
            width: parent.width
        }
    }

    SailfishShare {
        id: shareItem

        source: root.source
        metadataStripped: true
        serviceId: root.methodId
        userData: {
            "accountId": root.accountId,
            "link": root.content.status,
            "tags": tagsArea.text
        }
        mimeType: root.isLink ? "text/x-url" : "text/plain"
    }

    Component.onCompleted:  tagsArea.forceActiveFocus ()
}
