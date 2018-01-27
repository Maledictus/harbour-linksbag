/*
The MIT License (MIT)

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
import Sailfish.Silica 1.0

Item {
    anchors.fill: parent

    property alias image: articleImage.source
    property alias title: articleTitle.text

    Image {
        id: articleImage
        sourceSize.width: width
        sourceSize.height: height
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    OpacityRampEffect {
        slope: 1.0
        offset: 0.15
        sourceItem: articleImage
        direction: OpacityRamp.BottomToTop
    }

    Label {
        id: articleTitle
        anchors {
            fill: parent; margins: Theme.paddingLarge;
        }
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 6
        elide: Text.ElideRight
        text: ""
    }
}
