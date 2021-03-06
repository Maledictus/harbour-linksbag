﻿/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>

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

#include <QGuiApplication>
#include <QLoggingCategory>
#include <QScopedPointer>
#include <QTimer>

#include <sailfishapp.h>

#include <QtDebug>

#include "src/application.h"
#include "src/debugmessagehandler.h"

int main(int argc, char *argv [])
{
    qInstallMessageHandler(DebugHandler::Write);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    app->setApplicationDisplayName("LinksBag");
    app->setApplicationName("harbour-linksbag");
    app->setApplicationVersion(QString(APP_VERSION));

    qDebug() << "==== Application started: " << app->applicationVersion() << " ==== ";

    QScopedPointer<LinksBag::Application> application(new LinksBag::Application());
    QTimer::singleShot(1, application.data(), SLOT(start()));

    QObject::connect(app.data(),
            &QGuiApplication::aboutToQuit,
            application.data(),
            &LinksBag::Application::handleAboutToQuit);

    const int retVal = app->exec();

    qDebug() << "==== Application ended: ==== ";

    return retVal;
}

