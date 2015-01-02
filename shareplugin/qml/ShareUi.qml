import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

ShareDialog {
    id: root

    property int viewWidth: root.isPortrait ? Screen.width : Screen.width / 2

    onAccepted: {
        shareItem.start ()
    }

    Item {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Label {
            anchors.centerIn:parent
            width: viewWidth
            text: root.content + " " +
                    root.content.status + " " +
                    root.content.linkTitle + " " +
                    typeof(root.content.status) + " " +
                    typeof(root.content.linkTitle) + " " +
                    typeof(shareItem)

            horizontalAlignment: Text.AlignHCenter
        }
    }

    SailfishShare {
        id: shareItem

        source: root.source
        metadataStripped: true
        serviceId: root.methodId
        userData: {
            "description": "Add url to getpocket.com",
            "accountId": root.accountId,
            "scalePercent": root.scalePercent
        }
    }

    DialogHeader {
        acceptText: qsTr ("Put in pocket")
    }
}
