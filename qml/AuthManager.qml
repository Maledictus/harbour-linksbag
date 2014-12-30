/*
    Copyright (c) 2014 Oleg Linkin <MaledictusDeMagog@gmail.com>

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
import QtWebKit 3.0
import Sailfish.Silica 1.0

Item {
    id: authManager

    property string consumerKey: "12464-6eefaffd8db4baedd23a64af"

    property string requestToken
    property string accessToken

    property string userName

    property int countLoading: 0

    signal authenticated ()

    Component.onCompleted: {
        try {
            userName = localStorage.getSettingsValue ("userName", "")
            accessToken = localStorage.getSettingsValue ("accessToken", "")
        } catch (e) {
            console.log ("exception: getSettingsValue" + e)
        }

        if (accessToken === "") {
            auth_refresh()
        }

    }

    onRequestTokenChanged: {
        if (requestToken === undefined || requestToken === "")
            return

        console.log("request token changed ! " + requestToken)
        webview.url = "https://getpocket.com/auth/authorize?request_token=" +
                requestToken + "&redirect_uri=linksbag:authorizationFinished"
    }

    onAccessTokenChanged: {
        if (accessToken === undefined || accessToken === "")
            return

        console.log ("access token changed ! " + accessToken)
        webview.visible = false
        localStorage.setSettingsValue("accessToken", accessToken)

        authenticated ()
    }

    onUserNameChanged: {
        console.log ("user name changed ! " + userName)
        localStorage.setSettingsValue("userName", userName)
    }

    function auth_refresh () {
        webview.visible = true
        networkManager.obtainAccessToken ()
    }

    function logout () {
        console.log ("Logout")

        localStorage.setSettingsValue("accessToken", "")
        localStorage.setSettingsValue("userName", "")
        localStorage.setSettingsValue("lastUpdate", "0")

        accessToken = ""
        requestToken = ""
        userName = ""

        auth_refresh()
    }

    WebView {
        id: webview
        anchors.fill: parent

        visible: false

        onLoadingChanged: {

            console.log ("webview "  + loading)
            if (loading) {
                countLoading++;
            } else {
                countLoading--;

                var str = loadRequest.url.toString();
                var i = str.indexOf ("linksbag:authorizationFinished", 0)
                if (!i) {
                    networkManager.requestAccessToken ()
                }
            }
        }

        BusyIndicator {
            id: webviewBusyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            visible: webview.loading;
            running: true;
        }

    }
}
