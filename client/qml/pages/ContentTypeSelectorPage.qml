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

Page {

    property var _callback
    property var bookmarksPage

    Component.onDestruction: {
        if (_callback) {
            _callback()
        }
    }

    SilicaListView {
        id: listview

        anchors.fill: parent
        model: bookmarksPage.contentTypeFilters

        header: PageHeader {
            title: qsTr("Filter by")
        }

        delegate: ListItem {
            id: listitem

            width: listview.width

            Label {
                text: modelData.name
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                color: listitem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                function closure(sorter)
                {
                    return function()
                    {
                        bookmarksPage.contentTypeFilter = sorter;
                    }
                }

                _callback = closure(modelData);
                pageStack.pop();
            }
        }
    }
}
