/*
The MIT License(MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
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

Dialog {
    id: filterBookamarksDialog

    property int statusFilter: mainWindow.settings.statusFilter
    property int contentTypeFilter: mainWindow.settings.contentTypeFilter

    Column {
        width: parent.width

        DialogHeader {
            acceptText: qsTr("Filter")
            cancelText: qsTr("Cancel")
        }

        ComboBox {
            id: statusComboBox

            property var statusCategories: [LinksBag.AllStatus, LinksBag.ReadStatus,
                    LinksBag.UnreadStatus, LinksBag.FavoriteStatus]

            function update() {
                statusFilter = statusCategories[currentIndex]
            }

            currentIndex: {
                for (var i = 0; i < statusCategories.length; ++i) {
                    if (statusFilter === statusCategories[i]) {
                        return i
                    }
                }
                console.log("Unsupported bookmark status filter multiplier selected")
                return 0
            }

            label: qsTr("Status")
            menu: ContextMenu {
                onClosed: statusComboBox.update()

                MenuItem {
                    text: qsTr("All")
                }
                MenuItem {
                    text: qsTr("Read")
                }
                MenuItem {
                    text: qsTr("Unread")
                }
                MenuItem {
                    text: qsTr("Favorite")
                }
            }
        }

        ComboBox {
            id: contentTypeComboBox

            property var contentTypeCategories: [LinksBag.AllContentType, LinksBag.ArticlesContentType,
                    LinksBag.ImagesContentType, LinksBag.VideosContentType]

            function update() {
                contentTypeFilter = contentTypeCategories[currentIndex]
            }

            currentIndex: {
                for (var i = 0; i < contentTypeCategories.length; ++i) {
                    if (contentTypeFilter === contentTypeCategories[i]) {
                        return i
                    }
                }
                console.log("Unsupported content type filter multiplier selected")
                return 0
            }

            label: qsTr("Content type")
            menu: ContextMenu {
                onClosed: contentTypeComboBox.update()

                MenuItem {
                    text: qsTr("All")
                }
                MenuItem {
                    text: qsTr("Articles")
                }
                MenuItem {
                    text: qsTr("Images")
                }
                MenuItem {
                    text: qsTr("Videos")
                }
            }
        }
    }

    canAccept: true
}
