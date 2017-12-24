import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Item {
    property bool isBusy: true
    property bool ignoreHeader: false;
    property string entry: ""
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

        experimental.userScripts: [
            Qt.resolvedUrl("pages/helpers/readability.js") ,
            Qt.resolvedUrl("pages/helpers/ReaderModeHandler.js"),
            Qt.resolvedUrl("pages/helpers/MessageListener.js")
        ]

        onLoadingChanged: {
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                webView.postMessage("readermodehandler_enable");
                //getNextPage();
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
                document.querySelector('.page-numbers').remove();
            } catch (e) {}
            return body.innerHTML;
        })()";
        if (bookmarkImage) {
            webView.experimental.evaluateJavaScript("document.querySelector('img[src=\"" + bookmarkImage + "\"]').remove()", function(result) {});
        }
        if (webView.ignoreHeader) {
            webView.experimental.evaluateJavaScript("document.querySelector('.article-header').remove()", function(result) {});
        }

        webView.experimental.evaluateJavaScript(js, function(result){
            isBusy = false
            entry += result;
        })
    }
}
