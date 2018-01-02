import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property bool isBusy: true
    property string entry: ""
    property string bookmarkImage: ""

    function setArticle(article_url) {
        isBusy = true;
        makeRequest(article_url);
    }

    function makeRequest(url) {
        var doc = new XMLHttpRequest();
        entry = "";
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE && doc.status == 200) {
                var entry_text = JSON.parse(doc.responseText).content;
                entry_text = entry_text.replace(new RegExp("\%20[0-9].*x[a-z]?", "g"), "");
                entry_text = entry_text.replace(new RegExp("<img(?!\/)", "g"), "<img width='" + (mainWindow.width - 2*Theme.horizontalPageMargin) + "'");
                entry_text = entry_text.replace(bookmarkImage, "");
                entry = entry_text;
                isBusy = false;
            }
        }

        doc.open("GET", "https://mercury.postlight.com/parser?url=" + url);
        doc.setRequestHeader("Content-Type", "application/json");
        doc.setRequestHeader("x-api-key", "WQuwYvDFOpW5rwWvBy4DPUP4h2r1AMkaRI5VJNN8");
        doc.send();
    }
}
