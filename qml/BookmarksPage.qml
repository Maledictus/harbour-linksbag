/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property alias m: listModel
    property bool loading

    signal login ()
    signal logout ()
    signal markAsRead (bool read)
    signal markAsFavorite (bool favorite)
    signal removeBookmark (string uid)

    property int lastUpdate: 0

    Component.onCompleted: {
        lastUpdate = parseInt (localStorage.getSettingsValue ("lastUpdate", 0))
    }

    ListModel {
        id: listModel
    }

    function loadBookmarks () {
        networkManager.loadBookmarks (lastUpdate)
    }

    SilicaListView {
        id: listView

        model: listModel
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: authManager.userName === "" ? qsTr("Login") : qsTr ("Logout")
                onClicked: authManager.userName === "" ? login () : logout ()
            }
        }

        header: PageHeader {
            title: qsTr ("All bookmarks")
        }

        spacing: 5

        property Item contextMenu

        delegate: BackgroundItem {
            id: delegate

            property string bookmarkId : uid
            property url bookmarkUrl : url
            property bool bookmarkIsFavorite : favorite
            property bool bookmarkIsRead : read

            property bool menuOpen: listView.contextMenu != null &&
                                listView.contextMenu.parent === delegate
            height: menuOpen ?
                listView.contextMenu.height + 70 :
                70

            Label {
                id: titleLabel

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: tagsLabel.text.length === 0 && !menuOpen ?
                    parent.verticalCenter :
                    undefined
                anchors.margins: Theme.paddingMedium

                font.family: Theme.fontFamilyHeading
                font.pixelSize:  Theme.fontSizeMedium
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: title
            }

            Label {
                id: tagsLabel

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: titleLabel.bottom
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium
                anchors.topMargin: 0

                font.pixelSize:  Theme.fontSizeTiny
                elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor

                text: tags
            }

            function remove () {
                var idx = index
                remorse.execute(delegate, qsTr ("Removing bookmark"),
                        function () {
                            removeBookmark (bookmarkId)
                            listModel.remove (idx)
                        }, 3000);
            }

            RemorseItem { id: remorse }

            onPressAndHold: {
                listView.currentIndex = index;
                if (!listView.contextMenu)
                    listView.contextMenu = bookmarkContextMenuComponent.createObject()
                listView.contextMenu.show(delegate)
            }
        }

        Component {
            id: bookmarkContextMenuComponent
            ContextMenu {
                MenuItem {
                    text: listView.currentItem.bookmarkIsRead ?
                        qsTr ("Mark as unread") :
                        qsTr ("Mark as read")
                    onClicked: markAsRead (!listView.currentItem.bookmarkIsRead)
                }

                MenuItem {
                    text: listView.currentItem.bookmarkIsFavorite ?
                        qsTr ("Mark as favorite") :
                        qsTr ("Mark as unfavorite")
                    onClicked: markAsFavorite (!listView.currentItem.bookmarkIsFavorite)
                }

                MenuItem {
                    text: qsTr ("Remove")
                    onClicked: listView.currentItem.remove ();
                }
            }
        }

        VerticalScrollDecorator{}
    }

    BusyIndicator {
        visible: loading && !listModel.count
        running: visible
        anchors.centerIn: parent
    }

    Label {
        anchors.centerIn: parent
        visible: !loading && !listModel.count
        text: qsTr ("Offline")
    }
}


