import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: networkManager

    function obtainAccessToken () {
        var source = "https://getpocket.com/v3/oauth/request"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"redirect_uri\": \"linksbag://authorizationFinished\" }"
        sendRequest (source, params, "POST")
    }

    function requestAccessToken () {
        var source = "https://getpocket.com/v3/oauth/authorize"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"code\": \""+ authManager.requestToken +"\" }"
        sendRequest (source, params, "POST")
    }

    function loadBookmarks (lastUpdate) {
        var source = "https://getpocket.com/v3/get"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey + "\"," +
                " \"access_token\": \""+ authManager.accessToken +"\"," +
                " \"state\": \"all\", \"sort\": \"newest\", \"detailType\": \"complete\"," +
                " \"since\": \"" + lastUpdate + "\"}"
        sendRequest (source, params, "POST")
    }

    function sendRequest (source, params, method) {
        console.log(method + ": " + source + "?" + params)

        var http = new XMLHttpRequest ()
        http.open (method, source, true);
        http.onreadystatechange = function () {
            //console.log("http.status: " + http.readyState + " " + http.status + " " + http.statusText)
            var maxValue = 0

            if (http.readyState === XMLHttpRequest.DONE) {
                authManager.countLoading = Math.max (authManager.countLoading - 1, 0)
                if (http.status === 200) {
                    try {
                        var result = http.responseText;
                        //console.log("XXXXXXXXXXXXXXX " + result + "YYYYYYYYYYYYYYYYYYYYY")
                        var resultObject = JSON.parse (result)

                        if (resultObject.code !== undefined) {
                            authManager.requestToken = resultObject.code
                        }

                        if (resultObject.access_token !== undefined) {
                            authManager.accessToken = resultObject.access_token
                        }

                        if (resultObject.username !== undefined) {
                            authManager.userName = resultObject.username
                        }

                        if (resultObject.list !== undefined) {
                            bookmarksPage.m.clear()
                            var list = resultObject.list
                            for (var key in list) {
                                var item = list [key]
                                var uid = item.item_id
                                var url = item.resolved_url
                                var title = item.resolved_title
                                if (!title || title.length === 0)
                                    title = item.given_title
                                if (!title || title.length === 0)
                                    title = url
                                var favorite = item.favorite
                                var read = item.time_read !== "0"
                                var tagsList = item.tags
                                var tags = ""
                                for (var tag in tagsList) {
                                    if (tag === undefined)
                                        continue
                                    if (tags && tags.length !== 0)
                                        tags += ", "
                                    tags += tag
                                }

                                var data = {
                                    "uid" : uid,
                                    "url" : url,
                                    "title" : title,
                                    "favorite" : favorite,
                                    "read" : read,
                                    "tags" : tags
                                }

                                bookmarksPage.m.append (data)
                            }
                        }
                    } catch(e) {
                        console.log("sendRequest: parse failed: " + e)
                    }
                } else if (http.status === 401) {
                    console.log("http.status: 401 not authorized")
                    authManager.requestToken = ""

                } else if (http.status === 0) {
                    authManager.countLoading = 0
                } else {
                    console.log("error in onreadystatechange: " + http.status +
                            " " + http.statusText + ", " +
                            http.getAllResponseHeaders () + "," +http.responseText)
                }
            }
        }
        http.setRequestHeader("Content-Type", "application/json; charset=UTF-8")
        http.setRequestHeader("X-Accept", "application/json")
        authManager.countLoading++
        http.send (params)
    }
}
