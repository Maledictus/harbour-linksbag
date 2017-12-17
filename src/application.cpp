/*
The MIT License (MIT)

Copyright (c) 2014-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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

#include "application.h"

#include "sailfishapp.h"

#include <QQuickView>
#include <QQmlContext>
#include <QtDebug>
#include <QtQml>

#include "bookmarksmodel.h"
#include "enumsproxy.h"
#include "filterproxymodel.h"
#include "linksbagmanager.h"
#include "settings/accountsettings.h"
#include "settings/applicationsettings.h"

namespace LinksBag
{
Application::Application(QObject *parent)
: QObject(parent)
, m_View(nullptr)
{
}

void Application::ShowUI()
{
    if (!m_View)
    {
        qDebug() << "Construct view";
        m_View = SailfishApp::createView();
        m_View->setTitle("LinksBag");
        m_View->rootContext()->setContextProperty("accountSettings",
                AccountSettings::Instance(this));
        m_View->rootContext()->setContextProperty("applicationSettings",
                ApplicationSettings::Instance(this));
        m_View->rootContext()->setContextProperty("linksbagManager",
                LinksBagManager::Instance(this));
        m_View->setSource(SailfishApp::pathTo("qml/harbour-linksbag.qml"));
        m_View->showFullScreen();
    }
    else
    {
        qDebug() << "Activating view";
        m_View->raise();
        m_View->requestActivate();
    }
}

void Application::start()
{
    qRegisterMetaType<BookmarksModel*>("BookmarksModel*");
    qRegisterMetaType<FilterProxyModel*>("FilterProxyModel*");
    qmlRegisterUncreatableType<LinksBagManager>("harbour.linksbag", 1, 0,
            "LinksBagManager", "LinksBagManager static uncreatable type");
    qmlRegisterUncreatableType<LinksBag::EnumsProxy>("harbour.linksbag", 1, 0,
            "LinksBag", "This exports otherwise unavailable \
                    LinksBag datatypes to QML");

   ShowUI();
}

void Application::handleAboutToQuit()
{
    LinksBagManager::Instance(this)->SaveBookmarks();
}
} // namespace LinksBag