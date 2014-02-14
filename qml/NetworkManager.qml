import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: networkManager

    function obtainAccessToken () {
        var source = "https://getpocket.com/v3/oauth/request"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"redirect_uri\": \"linksbag://authorizationFinished\" }"
        sendRequest (source, params, "POST");
    }

    function authorizeApplication () {

    }

    function sendRequest (source, params, method) {
        console.log(method + ": " + source + "?" + params)

        var array, item, i, data, user;

        var http = new XMLHttpRequest ()
        http.open (method, source, true);
        http.onreadystatechange = function () {
            //console.log("http.status: " + http.readyState + " " + http.status + " " + http.statusText)
            var maxValue = 0;

            if (http.readyState === XMLHttpRequest.DONE) {
                authManager.countLoading = Math.max (authManager.countLoading - 1, 0);
                if (http.status === 200) {
                    try {
                        var result = http.responseText;
                        //console.log("XXXXXXXXXXXXXXX " + result + "YYYYYYYYYYYYYYYYYYYYY")
                        var resultObject = JSON.parse (result)
                        authManager.requestToken = resultObject.code;
                    } catch(e) {
                        console.log("sendRequest: parse failed: " + e)
                    }
                } else if (http.status === 401) {
                    console.log("http.status: 401 not authorized")
                    authManager.requestToken = "";

                } else if (http.status === 0) {
                    authManager.countLoading = 0;
                } else {
                    console.log("error in onreadystatechange: " + http.status +
                            " " + http.statusText + ", " +
                            http.getAllResponseHeaders () + "," +http.responseText)
                }
            }
        }
        http.setRequestHeader("Content-Type", "application/json; charset=UTF-8");
        http.setRequestHeader("X-Accept", "application/json");
        authManager.countLoading++;
        http.send (params)
    }
}
