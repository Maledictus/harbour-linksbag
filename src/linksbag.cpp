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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QGuiApplication>
#include <QtQml>
#include <QQmlEngine>
#include <QQuickView>
#include <QQmlContext>

#include <sailfishapp.h>
#include "enumsproxy.h"
#include "linksbagmanager.h"

static const char *URI = "harbour.linksbag.LinksBagManager";

int main (int argc, char *argv [])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

    QGuiApplication* app = SailfishApp::application (argc, argv);
    app->setApplicationName ("harbour-linksbag");
    app->setApplicationVersion ("1.2");

    QQuickView* view = SailfishApp::createView ();
    auto getpocket = new LinksBag::LinksBagManager;
    Q_UNUSED (getpocket)
    qmlRegisterType<LinksBag::LinksBagManager> (URI, 1, 0, "LinksBagManager");
    qmlRegisterUncreatableType<LinksBag::EnumsProxy> (URI, 1, 0, "LinksBag",
            "This exports otherwise unavailable LinksBag datatypes to QML");

    view->setSource (SailfishApp::pathTo ("qml/harbour-linksbag.qml"));
    view->showFullScreen ();

    return app->exec ();
}

