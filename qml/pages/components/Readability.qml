/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

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
    property bool isBusy: true
    property bool ignoreHeader: false;
    property string entry: ""
    property string date: ""
    property string bookmarkImage: ""

    property string nextUrl: ""

    function loadNextUrl() {
        if (nextUrl != "" && !isBusy) {
             isBusy = true;
             webView.url = nextUrl;
         }
    }

    onIsBusyChanged: loadNextUrl()

    function setArticle(url) {
        entry = "";
        isBusy = true;
        ignoreHeader = false;
        webView.url = url;
    }


    SilicaWebView {
        id: webView

        visible: false
        z: -1

        experimental.preferences.webGLEnabled: true
        experimental.preferences.notificationsEnabled: true
        experimental.preferences.javascriptEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.userAgent: "Mozilla/5.0 (Maemo; Linux; U; Sailfish; Mobile; rv:38.0) Gecko/38.0 Firefox/38.0"
        experimental.userScripts: [
            Qt.resolvedUrl("../helpers/readability.js") ,
            Qt.resolvedUrl("../helpers/ReaderModeHandler.js"),
            Qt.resolvedUrl("../helpers/MessageListener.js")
        ]

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                webView.postMessage("readermodehandler_enable");
                getNextPage();
                getSource();
            }
        }

        function postMessage(message, data) {
            experimental.postMessage(JSON.stringify({ "type": message, "data": data }));
        }
    }

    function getNextPage() {
        var js = "(function() {
            var pages = document.querySelectorAll('.page-numbers a .next');
            if (pages.length > 0) {
                return pages[pages.length-1].parentElement.getAttribute('href');
            } else {
                return ''
            }
        })()";
        webView.experimental.evaluateJavaScript(js, function(result) {
            entry += "<p><b>getting page: " + result + "</p></b>";
            if (result) {
                webView.ignoreHeader = true;
                nextUrl = result;
                loadNextUrl();
            }
        });
    }

    function getSource(){
        var js = "(function() {
            var body = document.documentElement.querySelector('body');
            try {
                // document.querySelector('.page-numbers').remove();
            } catch (e) {}
            return body.innerHTML;
        })()";
        if (bookmarkImage) {
            webView.experimental.evaluateJavaScript("document.querySelector('img[src=\"" + bookmarkImage + "\"]').remove()",
                    function(result) {});
        }
        if (webView.ignoreHeader) {
            webView.experimental.evaluateJavaScript("document.querySelector('.article-header').remove()",
                    function(result) {});
        }

        webView.experimental.evaluateJavaScript(js, function(result){
            isBusy = false
            entry += result;
        })
    }
}
