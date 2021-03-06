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

            PullDownMenu {
                MenuItem {
                    text: qsTr("About")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                    }
                }
            }

            SectionHeader { text: qsTr("User interface") }

            ComboBox {
                id: itemSizeComboBox

                property var fontSizeCategories: [Theme.paddingSmall, Theme.paddingMedium,
                        Theme.paddingLarge, Theme.paddingLarge * 2]

                function update() {
                    mainWindow.settings.bookmarksViewItemSize = fontSizeCategories[currentIndex]
                }

                currentIndex: {
                    for (var i = 0; i < fontSizeCategories.length; ++i) {
                        if (mainWindow.settings.bookmarksViewItemSize === fontSizeCategories[i]) {
                            return i
                        }
                    }
                    console.log("Unsupported font size multiplier selected")
                    return 0
                }

                label: qsTr("Item size")
                menu: ContextMenu {
                    onClosed: itemSizeComboBox.update()

                    MenuItem {
                        text: qsTr("Small")
                    }
                    MenuItem {
                        text: qsTr("Medium")
                    }
                    MenuItem {
                        text: qsTr("Large")
                    }
                    MenuItem {
                        text: qsTr("Extra Large")
                    }
                }
            }

            TextSwitch {
                text: qsTr("Show bookmark content type")
                checked: mainWindow.settings.showContentType
                onCheckedChanged: {
                    mainWindow.settings.showContentType = checked
                }
            }

            TextSwitch {
                text: qsTr("Show background image")
                checked: mainWindow.settings.showBackgroundImage
                onCheckedChanged: {
                    mainWindow.settings.showBackgroundImage = checked
                }
            }

            SectionHeader { text: qsTr("Sync") }

            TextSwitch {
                text: qsTr("Sync on startup")
                checked: mainWindow.settings.syncOnStartup
                onCheckedChanged: mainWindow.settings.syncOnStartup = checked
                description: qsTr("App will try to sync with Pocket on startup.")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Force full refresh")
                onClicked: {
                    remorse.execute(qsTr("Reloading bookmarks"),
                        function() {
                            mainWindow.settings.lastUpdate = 0
                            mainWindow.settings.sync();
                            linksbagManager.refreshBookmarks();
                        } )
                }
            }
            Label {
                anchors {
                    left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin
                }
                height: paintedHeight + Theme.paddingSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                text: qsTr("In case something gone really, really wrong, this button will make " +
                    "app forget that it ever synced. Good luck.")
            }

            SectionHeader { text: qsTr("Reading") }

            ComboBox {
                id: readingViewComboBox

                property var readingViewCategories: [ LinksBag.BestView, LinksBag.WebView, LinksBag.ArticleView ]

                function update() {
                    mainWindow.settings.readingView = readingViewCategories[currentIndex]
                    mainWindow.settings.sync()
                }

                currentIndex: {
                    for (var i = 0; i < readingViewCategories.length; ++i) {
                        if (mainWindow.settings.readingView === readingViewCategories[i]) {
                            return i
                        }
                    }
                    console.log("Unsupported reading view selected")
                    return 0
                }

                label: qsTr("Reading view")
                description: {
                    switch(readingViewCategories[currentIndex]) {
                    case LinksBag.BestView:
                        return qsTr("LinksBag automatically select the best view(article, webview, image)");
                    case LinksBag.ArticleView:
                        return qsTr("All articles will be opened in articles(reader-mode) view");
                    case LinksBag.WebView:
                    default:
                        return qsTr("All articles will be opened in embeded webview");
                    }
                }

                menu: ContextMenu {
                    onClosed: readingViewComboBox.update()

                    MenuItem {
                        text: qsTr("Best view")
                    }
                    MenuItem {
                        text: qsTr("Web view")
                    }
                    MenuItem {
                        text: qsTr("Article view")
                    }
                }
            }

            ComboBox {
                id: parserSelect

                property var parsersCategories: ["mercury", "readability"]
                function update() {
                    mainWindow.settings.parser = parsersCategories[currentIndex]
                }

                label: qsTr("Parser")
                currentIndex: {
                    for (var i = 0; i < parsersCategories.length; ++i) {
                        if (mainWindow.settings.parser === parsersCategories[i]) {
                            return i
                        }
                    }
                    console.log("Unsupported font size multiplier selected")
                    return 0
                }
                description: qsTr("Mercury is faster and lighter on your device but if you want " +
                        "articles to be processed on your device, you can use Readability instead.")
                menu: ContextMenu {
                    onClosed: parserSelect.update()
                    MenuItem {
                        text: "Mercury"
                        onClicked: mainWindow.settings.parser = "mercury"
                    }
                    MenuItem {
                        text: "Readability"
                        onClicked: mainWindow.settings.parser = "readability"
                    }
                }
            }

            TextSwitch {
                text: qsTr("Mobile browser")
                checked: mainWindow.settings.mobileBrowser
                onCheckedChanged: mainWindow.settings.mobileBrowser = checked
                description: qsTr("Try to open mobile version of web pages")
            }

            SectionHeader { text: qsTr("Offline reading") }

            Label {
                anchors {
                    left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin
                }
                height: paintedHeight + Theme.paddingSmall
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                text: qsTr("The best practice for offline reading - using it with ArticlesView reading mode")
            }

            TextSwitch {
                id: offlineDownloaderSwitch
                text: qsTr("Download articles for offline reading")
                description: qsTr("Downloaded: %L1/%L2")
                    .arg(linksbagManager.downloadedBookmarksCount)
                    .arg(linksbagManager.downloaderQueueSize)
                checked: mainWindow.settings.offlineDownloader
                onCheckedChanged: {
                    mainWindow.settings.offlineDownloader = checked
                    mainWindow.settings.sync()
                }
            }

            TextSwitch {
                text: qsTr("Download only using wifi")
                enabled: offlineDownloaderSwitch.checked
                checked: offlineDownloaderSwitch.checked && mainWindow.settings.wifiOnlyDownloader
                onCheckedChanged: {
                    mainWindow.settings.wifiOnlyDownloader = checked
                    mainWindow.settings.sync()
                }
            }

            TextSwitch {
                text: qsTr("Download only unread")
                enabled: offlineDownloaderSwitch.checked
                checked: offlineDownloaderSwitch.checked && mainWindow.settings.unreadOnlyDownloader
                onCheckedChanged: {
                    mainWindow.settings.unreadOnlyDownloader = checked
                    mainWindow.settings.sync()
                }
            }

            SectionHeader { text: qsTr("Cache") }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Remove saved articles")
                onClicked: remorse.execute(qsTr("Removing saved articles"), function()
                    { linksbagManager.resetArticleCache() } )
            }
            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear thumbnail cache")
                onClicked: remorse.execute(qsTr("Clearing thumbnail cache"), function()
                    { linksbagManager.resetThumbnailCache() } )
            }

            SectionHeader { text: qsTr("Account") }
            Label {
                anchors {
                    left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin
                }
                height: paintedHeight + Theme.paddingSmall
                color: Theme.secondaryColor
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall

                text: qsTr("You're logged in as %1.").arg(mainWindow.settings.userName)
            }
            ButtonLayout {
                width: parent.width - 2* Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: qsTr("Logout")
                    onClicked: remorse.execute(qsTr("Logging out"), function()
                        { linksbagManager.resetAccount() } )
                }
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
        }
    }
}
