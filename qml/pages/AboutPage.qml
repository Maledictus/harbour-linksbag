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
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0

Page {
    allowedOrientations: defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingMedium

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                id: header
                title: qsTr("About LinksBag")
            }

            Image {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/images/harbour-linksbag.png"
                width: Theme.iconSizeExtraLarge
                height: Theme.iconSizeExtraLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                text: "LinksBag " + Qt.application.version
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                color:  Theme.highlightColor
                text: qsTr("Unofficial native Pocket client for Sailfish OS")
                horizontalAlignment: Qt.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
            }

            Label {
                width: parent.width
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                textFormat: Text.RichText
                color:  Theme.highlightColor
                text: qsTr("Copyright &#169; 2014-2018 Oleg Linkin")
                horizontalAlignment: Qt.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
            }

            Row {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                spacing: Theme.paddingLarge

                Item {
                    height: Theme.itemSizeMedium
                    width: parent.width / 2
                    IconButton {
                        anchors.centerIn: parent
                        icon.source: "qrc:/images/icon-m-github"
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
                        onClicked: {
                            Qt.openUrlExternally("https://github.com/Maledictus/harbour-linksbag/issues/new")
                        }
                    }
                }

                Item {
                    width: parent.width / 2
                    height: Theme.itemSizeMedium
                    IconButton {
                        anchors.centerIn: parent
                        icon.source: "image://theme/icon-m-mail"
                        icon.width: Theme.iconSizeLarge
                        icon.height: Theme.iconSizeLarge
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            var subjectHeader = "[SailfishOS][LinksBag " + Qt.application.version + "] "
                            var mailBodyHeader = "Yo man, "
                            var email = "maledictusdemagog@gmail.com"
                            Qt.openUrlExternally("mailto:" + email +"?subject=" + subjectHeader +
                                    "&body=" + mailBodyHeader)
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("License")
            }

            property string _style: "<style>a:link { color:" + Theme.primaryColor + "; }</style>"

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                color:  Theme.highlightColor
                textFormat: Text.RichText
                text: column._style + qsTr("LinksBag is an open source software which is distributed under the terms of the<br /> <a href='%0'>MIT License</a><br />" +
                        "The source code is available at <a href='%1'>GitHub</a>")
                    .arg("https://github.com/Maledictus/harbour-linksbag/blob/master/LICENCE.txt")
                    .arg("https://github.com/Maledictus/harbour-linksbag/")

                horizontalAlignment: Qt.AlignHCenter
                font.pixelSize: Theme.fontSizeSmall
                onLinkActivated: Qt.openUrlExternally(link)
            }

            SectionHeader {
                text: qsTr("Donate or Contribute")
            }

            ButtonLayout {
                width: parent.width

                Button {
                    text: qsTr("WebMoney")
                    onClicked: Qt.openUrlExternally("https://vk.com/public167510767")
                }

                Button {
                    text: qsTr("YandexMoney")
                    onClicked: Qt.openUrlExternally("https://money.yandex.ru/to/410015442465267")
                }

                Button {
                    text: qsTr("Development")
                    onClicked: Qt.openUrlExternally("https://github.com/Maledictus/harbour-linksbag")
                }

                Button {
                    text: qsTr("Translations")
                    onClicked: Qt.openUrlExternally("https://www.transifex.com/maledictus/harbour-linksbag/dashboard")
                }
            }

           SectionHeader {
               text: qsTr("Gratitude")
           }

           ButtonLayout {
               width: parent.width
               Button {
                   text: qsTr("Developers")
                   onClicked: pageStack.push(Qt.resolvedUrl("DevelopersPage.qml"))
               }

               Button {
                   text: qsTr("Translators")
                   onClicked: pageStack.push(Qt.resolvedUrl("TranslatorsPage.qml"))
               }
           }
        }

        VerticalScrollDecorator{}
    }
}
