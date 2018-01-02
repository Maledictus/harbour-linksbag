import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    anchors.fill: parent

    property alias model: listView.model
    property string filter: ""

    Row {
        id: coverHeader
        height: Theme.itemSizeSmall
        anchors {
            top: parent.top;
            left: parent.left;
            right: parent.right;
            topMargin: Theme.paddingMedium
            leftMargin: Theme.paddingLarge;
            rightMargin: Theme.paddingLarge;
        }
        Label {
            id: coverHeaderCount
            font.pixelSize: Theme.fontSizeHuge
            color: Theme.primaryColor
            text: listView.count
        }
        spacing: Theme.paddingMedium
        Label  {
            id: coverHeaderTitle
            anchors {
                top: parent.top;
                topMargin: Theme.paddingMedium;
            }
            font.pixelSize: Theme.fontSizeExtraSmall
            lineHeight: 0.8;
            maximumLineCount: 2
            fontSizeMode: Text.HorizontalFit
            text: filter + "\n" + qsTr("articles")
        }
    }

    SilicaListView {
        id: listView

        anchors {
            top: coverHeader.bottom;
            left: parent.left;
            right: parent.right;
            margins: Theme.paddingLarge;
            bottom: parent.bottom;
            bottomMargin: 0;
        }

        spacing: Theme.paddingSmall

        width: parent.width
        clip: true

        delegate: BackgroundItem {
            id: delegate
            height: Theme.itemSizeExtraSmall

            Column {
                width: parent.width;
                Label {
                    id: itemLabel
                    width: parent.width
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    text: bookmarkTitle
                }
                Label {
                    width: parent.width

                    font.pixelSize:  Theme.fontSizeTiny
                    truncationMode: TruncationMode.Fade
                    color: Theme.secondaryColor

                    text: {
                        var matches = bookmarkUrl.toString()
                                .match(/^https?\:\/\/(?:www\.)?([^\/?#]+)(?:[\/?#]|$)/i);
                        return matches ? matches[1] : bookmarkUrl
                    }
                }
            }
        }
    }
}
