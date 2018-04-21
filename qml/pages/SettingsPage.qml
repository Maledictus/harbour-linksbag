/*
The MIT License (MIT)

Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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
import harbour.linksbag 1.0

Page {
    SilicaFlickable {
        id: settingsContent
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.height

        RemorsePopup { id: remorse }

        Column {
            id: column
            spacing: Theme.paddingSmall
            width: parent.width
            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader { text: qsTr("Sync") }
            TextSwitch {
                property string key: "sync_on_startup"
                text: qsTr("Sync on startup")
                checked: applicationSettings.value(key, false)
                onCheckedChanged: applicationSettings.setValue(key, checked)
                description: qsTr("App will try to sync with Pocket on startup.")
            }
            /*TextSwitch {
                // TODO: implement this
                opacity: 0.5
                automaticCheck: false
                text: qsTr("Download articles automatically")
                description: qsTr("Every new article will be saved for offline viewing automatically.")
            }*/

            ComboBox {
                id: parserSelect
                label: qsTr("Parser")
                value: applicationSettings.value("parser", "Mercury")
                currentIndex: value == "Readability" ? 1 : 0 // ugly :/ FIXME
                onValueChanged: applicationSettings.setValue("parser", value)
                description: qsTr("Mercury is faster and lighter on your device but if you want articles to be processed on your device, you can use Readability instead.")
                menu: ContextMenu {
                    MenuItem {
                        text: "Mercury"
                        onClicked: parserSelect.value = "Mercury"
                    }
                    MenuItem {
                        text: "Readability"
                        onClicked: parserSelect.value = "Readability"
                    }
                }
            }

            SectionHeader { text: qsTr("Cache") }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Remove saved articles")
                onClicked: remorse.execute(qsTr("Removing saved articles"), function() { linksbagManager.resetArticleCache() } )
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear thumbnail cache")
                onClicked: remorse.execute(qsTr("Clearing thumbnail cache"), function() { linksbagManager.resetThumbnailCache() } )
            }

            SectionHeader { text: qsTr("Account") }
            ButtonLayout {
                width: parent.width - 2* Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: qsTr("Logout")
                    onClicked: remorse.execute(qsTr("Logging out"), function() { linksbagManager.resetAccount() } )
                }
            }
        }
    }
}
