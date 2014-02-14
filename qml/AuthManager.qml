import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Item {
    id: authManager

    property string consumerKey: "12464-6eefaffd8db4baedd23a64af"

    property string requestToken
    property string accessToken
    property int lastUpdate: 0

    property int countLoading: 0

    Component.onCompleted: {
        try {
            accessToken = localStorage.getSettingsValue ("accessToken", "")
            lastUpdate = parseInt (localStorage.getSettingsValue ("lastUpdate", 0))
        } catch (e) {
            console.log ("exception: getSettingsValue" + e)
        }

        if (accessToken === "") {
            auth_refresh()
        }

    }

    onRequestTokenChanged: {
        console.log("request token changed ! " + requestToken)
//        webview.url = "https://getpocket.com/auth/authorize?request_token=" +
//                requestToken + "&redirect_uri=linksbag:authorizationFinished"
    }

    function auth_refresh () {
        networkManager.obtainAccessToken()
    }

    WebView {
        id: webview
        anchors.fill: parent;

        onLoadingChanged: {
            console.log("webview"  + loading)
            if (loading) {
                countLoading++;

            } else {
                countLoading--;

//                var str = url.toString();
//                var i = str.indexOf("access_token", 0)
//                if (i > 0) {
//                    var t = str.substr(i+13,str.length)
//                    accessToken = t;
//                    data.visible = false;
//                } else {
//                    if (str.indexOf("foursquare.com",0) <= 0) {
//                        console.log("authentication error")
//                        auth_refresh();
//                    } else {
//                        console.log("web page of foursquare.com")
//                    }
//                }

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
