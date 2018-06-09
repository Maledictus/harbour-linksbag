/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

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
import harbour.linksbag 1.0
import "./components"

Page {
    id: bookmarksPage

    BusyIndicator {
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: linksbagManager.busy
        visible: running
        z: 2
    }

    SilicaListView {
        id: bookmarksView

        anchors.fill: parent

        property bool showSearchField: mainWindow.settings.showSearchField === true

        header: Column {
            id: headerColumn
            width: bookmarksView.width
            property alias description: pageHeader.description
            PageHeader {
                id: pageHeader
                title: qsTr("Bookmarks")
                description: mainWindow.generateFilterTitle(mainWindow.settings.statusFilter,
                    mainWindow.settings.contentTypeFilter)
            }

            SearchField {
                id: search

                visible: bookmarksView.showSearchField

                anchors.left: parent.left
                anchors.right: parent.right

                placeholderText: qsTr("Search")

                onTextChanged: {
                    linksbagManager.filterBookmarks(text)
                    search.forceActiveFocus()
                    bookmarksView.currentIndex = -1
                }
            }
        }

        ViewPlaceholder {
            enabled: !bookmarksView.count && !linksbagManager.busy
            text: qsTr("There are no bookmarks. Pull down to refresh.")
        }

        PullDownMenu {
            visible: !linksbagManager.busy

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));
            }

            MenuItem {
                text: qsTr("Select bookmarks")
                visible: bookmarksView.count > 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("MultiSelectionPage.qml"),
                        { selectionModel: linksbagManager.filterModel,
                          removeRemorse: removeRemorse })
                }
            }

            MenuItem {
                text: bookmarksView.showSearchField ?
                        qsTr("Hide search field") :
                        qsTr("Show search field")

                onClicked: {
                    bookmarksView.showSearchField = !bookmarksView.showSearchField
                    mainWindow.settings.showSearchField = bookmarksView.showSearchField
                }
            }

            MenuItem {
                text: qsTr("Filter")

                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("../dialogs/FilterBookmarksDialog.qml"))
                    dialog.accepted.connect(function () {
                        mainWindow.settings.statusFilter = dialog.statusFilter
                        mainWindow.settings.contentTypeFilter = dialog.contentTypeFilter
                        linksbagManager.filterModel.filterBookmarks(mainWindow.settings.statusFilter,
                            mainWindow.settings.contentTypeFilter)
                        linksbagManager.coverModel.filterBookmarks(mainWindow.settings.statusFilter, 0)
                        bookmarksView.headerItem.description = mainWindow.generateFilterTitle(mainWindow.settings.statusFilter,
                            mainWindow.settings.contentTypeFilter)
                    })
                }
            }

            MenuItem {
                text: qsTr("Refresh")
                onClicked: linksbagManager.refreshBookmarks()
            }
        }

        BookmarkRemorsePopup {
            id: removeRemorse
        }

        currentIndex: -1

        model: linksbagManager.filterModel
        cacheBuffer: bookmarksView.height * 2

        delegate: BookmarkItem {
            selectMode: false
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted: {
        // Sync on startup
        if (mainWindow.settings.syncOnStartup) {
            linksbagManager.refreshBookmarks();
        }
    }
}
