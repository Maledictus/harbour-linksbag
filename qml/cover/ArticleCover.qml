import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    anchors.fill: parent

    property alias image: articleImage.source
    property alias title: articleTitle.text

    Image {
        id: articleImage
        sourceSize.width: width
        sourceSize.height: height
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    OpacityRampEffect {
        slope: 1.0
        offset: 0.15
        sourceItem: articleImage
        direction: OpacityRamp.BottomToTop
    }

    Label {
        id: articleTitle
        anchors {
            fill: parent; margins: Theme.paddingLarge;
        }
        font.pixelSize: Theme.fontSizeLarge
        wrapMode: Text.WordWrap
        text: ""
    }
}
