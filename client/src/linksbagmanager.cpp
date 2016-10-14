/*
The MIT License(MIT)

Copyright(c) 2016 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
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


#include "linksbagmanager.h"

#include <QSettings>
#include <QStandardPaths>

#include "src/enumsproxy.h"
#include "src/bookmarksmodel.h"
#include "src/filterproxymodel.h"
#include "src/getpocketapi.h"
#include "src/settings/accountsettings.h"
#include "src/settings/applicationsettings.h"

namespace LinksBag
{
LinksBagManager::LinksBagManager(QObject *parent)
: QObject(parent)
, m_Api(new GetPocketApi(this))
, m_IsBusy(false)
, m_IsLogged(false)
, m_BookmarksModel(new BookmarksModel(this))
, m_FilterProxyModel(new FilterProxyModel(this))
{
    MakeConnections();

    m_FilterProxyModel->setSourceModel(m_BookmarksModel);

    SetLogged(!AccountSettings::Instance(this)->value("access_token").isNull() &&
              !AccountSettings::Instance(this)->value("user_name").isNull());
    if (m_IsLogged)
    {
        loadBookmarksFromCache();
    }
}

LinksBagManager* LinksBagManager::Instance(QObject *parent)
{
    static LinksBagManager *linksBagManager = nullptr;
    if (!linksBagManager)
    {
        linksBagManager = new LinksBagManager(parent);
    }
    return linksBagManager;
}

bool LinksBagManager::GetBusy() const
{
    return m_IsBusy;
}

bool LinksBagManager::GetLogged() const
{
    return m_IsLogged;
}

void LinksBagManager::MakeConnections()
{
    connect(m_Api.get(),
            &GetPocketApi::requestFinished,
            this,
            [=](bool success, const QString& errorMsg)
            {
                SetBusy(false);
                if (!success && !errorMsg.isEmpty())
                {
                    emit error(errorMsg, ETGeneral);
                }
            });
    connect(m_Api.get(),
            &GetPocketApi::error,
            this,
            [=](const QString& msg, int code, ErrorType type)
            {
                SetBusy(false);
                const QString errorMessage = (type == ETGetPocket?
                        (tr("GetPocket error (%1): ").arg(code) + msg) :
                        msg);
                emit error(errorMessage, type);
            });

    connect(m_Api.get(),
            &GetPocketApi::requestTokenChanged,
            this,
            &LinksBagManager::requestTokenChanged);

    connect(m_Api.get(),
            &GetPocketApi::logged,
            this,
            [=](bool logged, const QString& accessToken, const QString& userName)
            {
                SetLogged(logged);
                AccountSettings::Instance(this)->
                        setValue("access_token", accessToken);
                AccountSettings::Instance(this)->
                        setValue("user_name", userName);
            });

    connect(m_Api.get(),
            &GetPocketApi::gotBookmarks,
            this,
            [this](const Bookmarks_t& bookmarks, quint64 since)
            {
                m_BookmarksModel->AddBookmarks(bookmarks);
                m_FilterProxyModel->sort(0, Qt::DescendingOrder);
                ApplicationSettings::Instance(this)->setValue("lastUpdate", since);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkRemoved,
            this,
            [this](const QString& id)
            {
                qDebug() << Q_FUNC_INFO;
               m_BookmarksModel->RemoveBookmark(id);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkMarkedAsFavorite,
            [this](const QString& id, bool favorite)
            {
                qDebug() << Q_FUNC_INFO;
                m_BookmarksModel->MarkBookmarkAsFavorite(id, favorite);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkMarkedAsRead,
            [this](const QString& id, bool read)
            {
                qDebug() << Q_FUNC_INFO;
                m_BookmarksModel->MarkBookmarkAsRead(id, read);
            });
}

void LinksBagManager::SetBusy(const bool busy)
{
    m_IsBusy = busy;
    emit busyChanged();
}

void LinksBagManager::SetLogged(const bool logged)
{
    m_IsLogged = logged;
    emit loggedChanged();
}

void LinksBagManager::SaveBookmarks()
{
    qDebug() << Q_FUNC_INFO;
    const auto& bookmarks = m_BookmarksModel->GetBookmarks();
    if (bookmarks.isEmpty())
        return;

    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
            "/linksbag_cache", QSettings::IniFormat);
    settings.beginWriteArray("Bookmarks");
    for (int i = 0, size = bookmarks.size(); i < size; ++i)
    {
        settings.setArrayIndex(i);
        settings.setValue("SerializedData", bookmarks.at(i).Serialize());
    }
    settings.endArray();
    settings.sync();
}

BookmarksModel* LinksBagManager::GetBookmarksModel() const
{
    return m_BookmarksModel;
}

FilterProxyModel*LinksBagManager::GetFilterModel() const
{
    return m_FilterProxyModel;
}

void LinksBagManager::obtainRequestToken()
{
    SetBusy(true);
    m_Api->ObtainRequestToken();
}

void LinksBagManager::requestAccessToken()
{
    SetBusy(true);
    m_Api->RequestAccessToken();
}

void LinksBagManager::filterBookmarks(const QString &text)
{
    m_FilterProxyModel->setFilterRegExp(text);
}

void LinksBagManager::loadBookmarksFromCache()
{
    qDebug() << Q_FUNC_INFO;
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
            "/linksbag_cache", QSettings::IniFormat);
    const int size = settings.beginReadArray("Bookmarks");
    Bookmarks_t bookmarks;
    for (int i = 0; i < size; ++i)
    {
        settings.setArrayIndex(i);
        QByteArray data = settings.value("SerializedData").toByteArray();
        Bookmark bm = Bookmark::Deserialize(data);
        if (!bm.IsValid())
        {
            qWarning() << Q_FUNC_INFO
                    << "unserializable entry"
                    << i;
            continue;
        }
        bookmarks << bm;
    }
    settings.endArray();

    m_BookmarksModel->SetBookmarks(bookmarks);
    m_FilterProxyModel->sort(0, Qt::DescendingOrder);
}

void LinksBagManager::refreshBookmarks()
{
    SetBusy(true);
    m_Api->LoadBookmarks(ApplicationSettings::Instance(this)->
            value("lastUpdate", 0).toLongLong());
}

void LinksBagManager::removeBookmark(const QString& id)
{
    SetBusy(true);
    m_Api->RemoveBookmark(id);
}

void LinksBagManager::markAsFavorite(const QString& id, bool favorite)
{
    SetBusy(true);
    m_Api->MarkBookmarkAsFavorite(id, favorite);
}

void LinksBagManager::markAsRead(const QString& id, bool read)
{
    SetBusy(true);
    m_Api->MarkBookmarkAsRead(id, read);
}
} // namespace LinskBag
