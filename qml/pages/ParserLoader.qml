/*
The MIT License (MIT)

Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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


Loader {
    id: loader
    property bool isBusy: false
    property string entry: ""
    property string bookmarkImage: ""
    property string articleUrl: ""

    onBookmarkImageChanged: item.bookmarkImage = bookmarkImage
    function setArticle(url) {
        if (status == Loader.Ready)
            loader.item.setArticle(url)
        else articleUrl = url
    }
    onLoaded: if (articleUrl) loader.item.setArticle(articleUrl)

    Connections {
        target: loader.item
        onIsBusyChanged: loader.isBusy = loader.item.isBusy
        onEntryChanged: loader.entry = loader.item.entry
    }
    Component.onCompleted: {
        var parserPage = "Mercury.qml"
        if (mainWindow.settings.parser === "readability") {
            parserPage = "Readability.qml"
        }
        loader.source = Qt.resolvedUrl("components/" + parserPage)
    }
}
