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
import Sailfish.Silica 1.0

Item {
    id: networkManager

    signal gotBookmarks (string lastUpdate)

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
                " \"state\": \"all\", \"sort\": \"oldest\", \"detailType\": \"complete\"," +
                " \"since\": \"" + lastUpdate + "\"}"
        sendRequest (source, params, "POST")
    }

    function removeBookmark (uid) {
        var source = "https://getpocket.com/v3/send"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"access_token\": \""+ authManager.accessToken +"\"," +
                "\"actions\": [ { \"action\": \"delete\", \"item_id\": \"" +
                uid + "\" } ] }"
        sendRequest (source, params, "POST")
    }

    function markAsRead (uid, read) {
        var source = "https://getpocket.com/v3/send"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"access_token\": \""+ authManager.accessToken +"\"," +
                "\"actions\": [ { \"action\": \"" + (read ? "archive" : "readd") +
                "\", \"item_id\": \"" + uid + "\" } ] }"
        sendRequest (source, params, "POST")
    }

    function markAsFavorite (uid, favorite) {
        var source = "https://getpocket.com/v3/send"
        var params = "{ \"consumer_key\": \"" + authManager.consumerKey +
                "\", \"access_token\": \""+ authManager.accessToken +"\"," +
                "\"actions\": [ { \"action\": \"" +
                (favorite ? "favorite" : "unfavorite") + "\", \"item_id\": \"" +
                uid + "\" } ] }"
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

                        if (resultObject.username !== undefined) {
                            authManager.userName = resultObject.username
                        }

                        if (resultObject.access_token !== undefined) {
                            authManager.accessToken = resultObject.access_token
                        }


                        if (resultObject.list !== undefined) {
                            if (resultObject.complete != 1) {
                                return
                            }
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
                                var favorite = item.favorite !== "0"
                                var read = item.status === "1"
                                var tagsList = item.tags
                                var tags = ""
                                for (var tag in tagsList) {
                                    if (tag === undefined)
                                        continue
                                    if (tags && tags.length !== 0)
                                        tags += ", "
                                    tags += tag
                                }

                                var sortId = item.sort_id

                                var data = {
                                    "uid" : uid,
                                    "url" : url,
                                    "title" : title,
                                    "favorite" : favorite,
                                    "read" : read,
                                    "tags" : tags,
                                    "sortId" : sortId
                                }

                                runtimeCache.addItem(data)
                            }

                            gotBookmarks (resultObject.since)
                        }
                    } catch(e) {
                        console.log("sendRequest: parse failed: " + e)
                    }
                } else if (http.status === 400) {
                    console.log("http.status: 400 - Invalid request, please make sure you follow the documentation for proper syntax")
                } else if (http.status === 401) {
                    console.log("http.status: 401 - Not authorized")
                    authManager.requestToken = ""
                } else if (http.status === 403) {
                    console.log ("https.status: 403 - User was authenticated, but access denied due to lack of permission or rate limiting")
                } else if (http.status === 503) {
                    console.log("http.status: 503 - Pocket's sync server is down for scheduled maintenance")
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
