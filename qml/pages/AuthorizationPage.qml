/*
The MIT License (MIT)

Copyright (c) 2014-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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
import QtWebKit 3.0

Page {
    id: authPage

    SilicaWebView {
        id: webView

        anchors.fill: parent

        property url mainUrl
        property bool firefoxAuth: false
        property bool getpocketAuth: true

        experimental.userScripts: [ Qt.resolvedUrl("helpers/userscript.js") ]
        experimental.preferences.navigatorQtObjectEnabled: true

        onUrlChanged: {
            var str = url.toString();
            if (str === "https://getpocket.com/a/") {
                webView.url = mainUrl
                return
            }

            if (!str.indexOf("https://getpocket.com/ff_signin")) {
                console.log("Authorization via firefox sign-in")
            }
            else if (!str.indexOf("linksbag:authorizationFinished")) {
                console.log("GetPocket access granted. Request access token")
                linksbagManager.requestAccessToken()
            }
        }

        experimental.onMessageReceived: {
            var data = null
            try {
                data = JSON.parse(message.data)
            }
            catch (error) {
                console.log('onMessageReceived: ' + message.data );
                return
            }

            switch (data.type) {
            case 'link': {
                if (!data.href.toString().indexOf("https://accounts.firefox.com/signin_permissions?")) {
                    webView.url = mainUrl
                }

            break;
            }
            }
        }

        onLoadingChanged: {
            if (loadRequest.status !== WebView.LoadSucceededStatus) {
                return;
            }

            var str = loadRequest.url.toString();
            if (!str.indexOf("https://getpocket.com/ff_auth")) {
                console.log("Firefox access granted. Request access token")
            }
        }

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: webView.loading || linksbagManager.busy
            visible: running
        }
    }
    Component.onCompleted: {
        linksbagManager.obtainRequestToken()
    }

    Connections {
        target: linksbagManager
        onRequestTokenChanged: {
            webView.mainUrl = "https://getpocket.com/auth/authorize?request_token=" +
                    requestToken + "&redirect_uri=linksbag:authorizationFinished"
            webView.url = "https://getpocket.com/auth/authorize?request_token=" +
                    requestToken + "&redirect_uri=linksbag:authorizationFinished"
        }
    }
}
