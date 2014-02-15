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
            accessToken = localStorage.getSettingsValue ("accessToken", "")
            userName = localStorage.getSettingsValue ("userName", "")
        } catch (e) {
            console.log ("exception: getSettingsValue" + e)
        }

        if (accessToken === "") {
            auth_refresh()
        }

    }

    onRequestTokenChanged: {
        console.log("request token changed ! " + requestToken)
        webview.url = "https://getpocket.com/auth/authorize?request_token=" +
                requestToken + "&redirect_uri=linksbag:authorizationFinished"
    }

    onAccessTokenChanged: {
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
