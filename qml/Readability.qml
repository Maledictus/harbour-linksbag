import QtQuick 2.0
import QtWebKit 3.0
import Sailfish.Silica 1.0

Item {
    property bool isBusy: false
    property bool ignoreHeader: false;
    property string entry: ""
    property string coverImage: ""

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
                getNextPage();
                getSource();
                getCoverImage();
            }
        }

        function postMessage(message, data) {
            experimental.postMessage(JSON.stringify({ "type": message, "data": data }));
        }
    }

    function getCoverImage() {
        var js = "(function() {
            var images = document.querySelectorAll('img');
            if (images.length > 0) {
                return images[0].getAttribute('src');
            } else {
                return ''
            }
        })()";
        webView.experimental.evaluateJavaScript(js, function(result) {
            coverImage = result;
        });
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
            if (result !== "") {
                webView.url = result;
                isBusy = true;
                webView.ignoreHeader = true;
            }
        });
    }

    function getSource(){
        var js = "(function() {
            var body = document.querySelector('.page');
            document.querySelector('.page-numbers').remove();
            return body.innerHTML;
        })()";
        if (webView.ignoreHeader) {
            webView.experimental.evaluateJavaScript("document.querySelector('.article-header').remove()", function(result) {});
        }

        webView.experimental.evaluateJavaScript(js, function(result){
            isBusy = false
            entry += result;
        })
    }
}
