/*
The MIT License (MIT)

Copyright (c) 2016 Oleg Linkin <maledictusdemagog@gmail.com>

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

import "cover"
import "pages"

ApplicationWindow {
    id: mainWindow

    cover: CoverPage { model: linksbagManager.filterModel }

    _defaultPageOrientations: Orientation.Landscape | Orientation.Portrait
    initialPage: accountSettings.value("access_token", "").length > 0 &&
                 accountSettings.value("user_name", "").length > 0 ?
            bookmarksComponent :
            authComponent

    Popup {
        id: popup
    }

    function showPopup(message, icon) {
        popup.title = message
        popup.image = icon
        popup.show()
    }

    Connections {
        target: linksbagManager
        onLoggedChanged: {
            if (!linksbagManager.logged)
            {
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("pages/AuthorizationPage.qml"))
            }
            else {
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("pages/BookmarksPage.qml"))
            }
        }

        onError: {
            showPopup(msg, "image://Theme/icon-system-warning")
        }

        onNotify: {
            showPopup(msg, "image://Theme/icon-system-resources")
        }
    }

    Component {
        id: authComponent

        AuthorizationPage {}
    }

    Component {
        id: bookmarksComponent

        BookmarksPage {}
    }
}
