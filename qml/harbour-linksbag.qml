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
import Sailfish.Silica 1.0
import harbour.linksbag 1.0
import Nemo.Notifications 1.0
import Nemo.Configuration 1.0

import "cover"
import "pages"

ApplicationWindow {
    id: mainWindow

    cover: CoverPage { model: linksbagManager.filterModel }

    property alias settings: settings

    property bool alreadyLogged: settings.accessToken.length > 0 && settings.userName.length > 0

    _defaultPageOrientations: Orientation.Landscape | Orientation.Portrait
    initialPage: alreadyLogged ? bookmarksComponent : loginComponent


    Notification {
        id: notification

        appIcon: "qrc:/images/harbour-linksbag.png"
        appName: "LinksBag"
        itemCount: 1
    }

    Connections {
        target: linksbagManager
        onLoggedChanged: {
            if (!linksbagManager.logged) {
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("pages/LoginPage.qml"))
            }
            else {
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("pages/BookmarksPage.qml"))
            }
        }

        onError: {
            notification.previewSummary = ""
            notification.previewBody = msg
            notification.icon = "image://Theme/icon-system-warning"
            notification.publish()
        }

        onNotify: {
            notification.previewSummary = ""
            notification.previewBody = msg
            notification.icon = "image://Theme/icon-system-resources"
            notification.publish()
        }
    }

    Component {
        id: loginComponent

        LoginPage {}
    }

    Component {
        id: bookmarksComponent

        BookmarksPage {}
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-linksbag"

        property bool settingsMigration: true
        property bool syncOnStartup: false
        property int lastUpdate: 0
        property real bookmarksViewItemSize: Theme.paddingMedium
        property string parser: "mercury"
        property string bookmarksFilter: "unread"
        property bool showSearchField: false
        property string accessToken
        property string userName
        property bool useBestView: true
    }
}
