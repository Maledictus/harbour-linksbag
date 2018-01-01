import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property bool isBusy: true
    property string entry: ""
    property string bookmarkImage: ""

    function setArticle(article_url) {
        entry = "";
        isBusy = true;
        makeRequest(article_url);
    }

    function escapeRegExp(str) {
        return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
    }

    function makeRequest(url) {
        var doc = new XMLHttpRequest();
        entry = "";
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE && doc.status == 200) {
                entry = JSON.parse(doc.responseText).content;
                entry = entry.replace(bookmarkImage, "").replace(new RegExp("figcaption", "g"), "p");
                isBusy = false;
            }
        }

        doc.open("GET", "https://mercury.postlight.com/parser?url=" + url);
        doc.setRequestHeader("Content-Type", "application/json");
        doc.setRequestHeader("x-api-key", "WQuwYvDFOpW5rwWvBy4DPUP4h2r1AMkaRI5VJNN8");
        doc.send();
    }
}
