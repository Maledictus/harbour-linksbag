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
#include <QQmlEngine>
#include <QQuickView>
#include <QQmlContext>

#include <sailfishapp.h>
#include "networkaccessmanagerfactory.h"


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

    LinksBag::NetworkAccessManagerFactory namFactory;

    QGuiApplication* app = SailfishApp::application (argc, argv);
    QQuickView* view = SailfishApp::createView ();


    QTranslator translator;
    if (translator.load (QLatin1String ("linksbag_") + QLocale::system ().name (),
            SailfishApp::pathTo (QString ("i18n")).toLocalFile ()))
    {
        app->installTranslator (&translator);
        view->rootContext ()->setContextProperty ("locale",
                QLocale::system ().bcp47Name ());
    }
    else
    {
        view->rootContext ()->setContextProperty ("locale","en");
    }


    view->engine ()->setNetworkAccessManagerFactory (&namFactory);
    view->setSource (SailfishApp::pathTo ("qml/linksbag.qml"));
    view->showFullScreen ();

    return app->exec ();
}

