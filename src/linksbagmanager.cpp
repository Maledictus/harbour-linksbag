/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
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

#include "linksbagmanager.h"

#include <QDir>
#include <QSettings>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QFile>
#include <QByteArray>
#include <QImage>
#include <QTimer>
#include <QThread>
#include <QThreadPool>

#include "settings/applicationsettings.h"
#include "application.h"
#include "bookmarksmodel.h"
#include "downloadedcontenthandler.h"
#include "downloadedimagehandler.h"
#include "enumsproxy.h"
#include "filterproxymodel.h"
#include "getpocketapi.h"
#include "offlinedownloader.h"

namespace LinksBag
{
LinksBagManager::LinksBagManager(QObject *parent)
: QObject(parent)
, m_Api(new GetPocketApi(this))
, m_IsBusy(false)
, m_IsLogged(false)
, m_BookmarksModel(new BookmarksModel(this))
, m_FilterProxyModel(new FilterProxyModel(m_BookmarksModel, this))
, m_CoverModel(new FilterProxyModel(m_BookmarksModel, this))
, m_ThumbnailDownloader(new QNetworkAccessManager(this))
, m_SyncTimer(new QTimer(this))
, m_OfflineDownloader(new OfflineDownloader())
, m_OfflineDownloaderThread(new QThread())
{
    MakeConnections();

    QDir dir;
    dir.mkpath(Application::GetPath(Application::ThumbnailCacheDirectory));
    dir.mkpath(Application::GetPath(Application::ArticleCacheDirectory));
    dir.mkpath(Application::GetPath(Application::CoverCacheDirectory));

    m_FilterProxyModel->setSourceModel(m_BookmarksModel);
    m_CoverModel->setSourceModel(m_BookmarksModel);

    m_FilterProxyModel->filterBookmarks(ApplicationSettings::Instance(this)->value("statusFilter").toInt(),
            ApplicationSettings::Instance(this)->value("contentTypeFilter").toInt());
    m_CoverModel->filterBookmarks(ApplicationSettings::Instance(this)->value("statusFilter").toInt(),
            ContentTypeAll);

    connect(m_ThumbnailDownloader, &QNetworkAccessManager::finished,
            this, &LinksBagManager::thumbnailReceived);

    m_OfflineDownloader->moveToThread(m_OfflineDownloaderThread);
    connect(m_OfflineDownloader, &OfflineDownloader::updateArticleContent,
            this, &LinksBagManager::handleUpdateArticleContent, Qt::QueuedConnection);
    connect(m_OfflineDownloader, &OfflineDownloader::updateImageContent,
            this, &LinksBagManager::handleUpdateImageContent, Qt::QueuedConnection);
    connect(m_OfflineDownloaderThread, &QThread::started,
            m_OfflineDownloader, &OfflineDownloader::start);
    connect(m_OfflineDownloaderThread, &QThread::finished,
            m_OfflineDownloaderThread, &QThread::deleteLater);
    connect(this, &LinksBagManager::offlineDownloaderEnabled,
            m_OfflineDownloader, &OfflineDownloader::handleOfflineDownloaderEnabled,
            Qt::QueuedConnection);
    connect(this, &LinksBagManager::wifiOnlyDownloaderEnabled,
            m_OfflineDownloader, &OfflineDownloader::handleWifiOnlyDownloaderEnabled,
            Qt::QueuedConnection);

    connect(m_SyncTimer, &QTimer::timeout, this, &LinksBagManager::refreshBookmarks);

    SetLogged(!ApplicationSettings::Instance(this)->value("accessToken").isNull() &&
              !ApplicationSettings::Instance(this)->value("userName").isNull());

    m_OfflineDownloaderThread->start();

    if (m_IsLogged)
    {
        loadBookmarksFromCache();
        QMetaObject::invokeMethod(m_OfflineDownloader, "SetBookmarks", Qt::QueuedConnection,
                Q_ARG(Bookmarks_t, m_BookmarksModel->GetBookmarks()));
    }

    restartSyncTimer();
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

BookmarksModel* LinksBagManager::GetBookmarksModel() const
{
    return m_BookmarksModel;
}

FilterProxyModel* LinksBagManager::GetFilterModel() const
{
    return m_FilterProxyModel;
}

FilterProxyModel *LinksBagManager::GetCoverModel() const
{
    return m_CoverModel;
}

void LinksBagManager::Stop()
{
    m_OfflineDownloader->stop();
    m_OfflineDownloader->deleteLater();
    m_OfflineDownloaderThread->quit();
    m_OfflineDownloaderThread->wait();
}

void LinksBagManager::MakeConnections()
{
    connect(this, &LinksBagManager::articlesCacheReset,
            m_BookmarksModel, &BookmarksModel::handleArticlesCacheReset);

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
                ApplicationSettings::Instance(this)->
                        setValue("accessToken", accessToken);
                ApplicationSettings::Instance(this)->
                        setValue("userName", userName);
                SetLogged(logged);
            });

    connect(m_Api.get(),
            &GetPocketApi::gotBookmarks,
            this,
            [this](const Bookmarks_t& bookmarks, quint64 since)
            {
                m_BookmarksModel->AddBookmarks(bookmarks);
                saveBookmarks();
                const auto& savedBookmarks = m_BookmarksModel->GetBookmarks();
                for (int i=savedBookmarks.size()-1; i>=0; --i) {
                    auto b = savedBookmarks.at(i);
                    QString path = Application::GetPath(Application::ThumbnailCacheDirectory) +
                            b->GetID() + ".jpg";
                    if (QFile(path).exists())
                        continue;

                    const QUrl url = b->GetImageUrl();
                    if (!url.isEmpty())
                    {
                        m_ThumbnailUrls[url] = b->GetID();
                        m_ThumbnailDownloader->get(QNetworkRequest(url));
                    }
                }
                m_FilterProxyModel->invalidate();
                m_FilterProxyModel->sort(0, Qt::DescendingOrder);
                ApplicationSettings::Instance(this)->setValue("lastUpdate", since);

                QMetaObject::invokeMethod(m_OfflineDownloader, "SetBookmarks", Qt::QueuedConnection,
                        Q_ARG(Bookmarks_t, m_BookmarksModel->GetBookmarks()));
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarksRemoved,
            this,
            [this](const QStringList& ids)
            {
                m_BookmarksModel->RemoveBookmarks(ids);

                QMetaObject::invokeMethod(m_OfflineDownloader, "SetBookmarks", Qt::QueuedConnection,
                        Q_ARG(Bookmarks_t, m_BookmarksModel->GetBookmarks()));
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarksMarkedAsFavorite,
            [this](const QStringList& ids, bool favorite)
            {
                m_BookmarksModel->MarkBookmarksAsFavorite(ids, favorite);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarksMarkedAsRead,
            [this](const QStringList& ids, bool read)
            {
                m_BookmarksModel->MarkBookmarksAsRead(ids, read);
            });

    connect(m_Api.get(),
            &GetPocketApi::tagsUpdated,
            [this](const QString& id, const QString& tags)
            {
                m_BookmarksModel->UpdateTags(id, tags);
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

void LinksBagManager::thumbnailReceived(QNetworkReply *pReply)
{
    if (!pReply)
    {
        return;
    }

    if (pReply->error() == QNetworkReply::NoError)
    {
        QString bookmarkId = m_ThumbnailUrls.value(pReply->url(), "");
        QThreadPool::globalInstance()->start(new DownloadedImageHandler(pReply,
                bookmarkId, m_BookmarksModel));
    }
    m_ThumbnailUrls.remove(pReply->url());
}

void LinksBagManager::handleUpdateArticleContent(const QString& id, const QString& pubDate,
        const QString& content)
{
    updatePublishDate(id, pubDate);
    updateContent(id, content);
}

void LinksBagManager::handleUpdateImageContent(const QString& id, const QImage& imageContent)
{
    updateContent(id, imageContent);
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
    QSettings settings(Application::GetPath(Application::CacheDirectory) +
            "/linksbag_cache", QSettings::IniFormat);
    const int size = settings.beginReadArray("Bookmarks");
    Bookmarks_t bookmarks;
    for (int i = 0; i < size; ++i)
    {
        settings.setArrayIndex(i);
        QByteArray data = settings.value("SerializedData").toByteArray();
        auto bm = Bookmark::Deserialize(data);
        if (!bm->IsValid())
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

void LinksBagManager::saveBookmarks()
{
    const auto& bookmarks = m_BookmarksModel->GetBookmarks();
    if (bookmarks.isEmpty())
        return;

    QSettings settings(Application::GetPath(Application::CacheDirectory) +
            "/linksbag_cache", QSettings::IniFormat);
    settings.beginWriteArray("Bookmarks");
    for (int i = 0, size = bookmarks.size(); i < size; ++i)
    {
        settings.setArrayIndex(i);
        settings.setValue("SerializedData", bookmarks.at(i)->Serialize());
    }
    settings.endArray();
    settings.sync();
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
    m_Api->RemoveBookmarks({ id });
}

void LinksBagManager::removeBookmarks(const QStringList& ids)
{
    SetBusy(true);
    m_Api->RemoveBookmarks(ids);
}

void LinksBagManager::markAsFavorite(const QString& id, bool favorite)
{
    SetBusy(true);
    m_Api->MarkBookmarksAsFavorite({ id }, favorite);
}

void LinksBagManager::markAsRead(const QString& id, bool read)
{
    SetBusy(true);
    m_Api->MarkBookmarksAsRead({ id }, read);
}

void LinksBagManager::markAsFavorite(const QStringList& ids, bool favorite)
{
    SetBusy(true);
    m_Api->MarkBookmarksAsFavorite(ids, favorite);
}

void LinksBagManager::markAsRead(const QStringList& ids, bool read)
{
    SetBusy(true);
    m_Api->MarkBookmarksAsRead(ids, read);
}

void LinksBagManager::updateTags(const QString& id, const QString& tags)
{
    SetBusy(true);
    m_Api->UpdateTags(id, tags);
}

void LinksBagManager::updateContent(const QString& id, const QString& content)
{
    QThreadPool::globalInstance()->start(new DownloadedContentHandler(id,
            content, m_BookmarksModel));
}

void LinksBagManager::updateContent(const QString& id, const QImage& imageContent)
{
    QThreadPool::globalInstance()->start(new DownloadedContentHandler(id,
            imageContent, m_BookmarksModel));
}

void LinksBagManager::updatePublishDate(const QString& id, const QString& date)
{
    m_BookmarksModel->UpdatePublishDate(id, date);
}

QString LinksBagManager::getContent(const QString& id) {

    QString filePath(Application::GetPath(Application::ArticleCacheDirectory) + id + ".html");
    if (!QFile::exists(filePath))
    {
        filePath = Application::GetPath(Application::ArticleCacheDirectory) + id;
        if (!QFile::exists(filePath))
        {
            filePath = "";
        }
    }

    if (filePath.isEmpty())
    {
        return "";
    }

    QFile file(filePath);
    if(!file.open(QIODevice::ReadOnly))
    {
        return "";
    }

    QTextStream in(&file);
    QString content;

    while(!in.atEnd())
    {
        content += in.readLine();
    }
    file.close();
    return content;
}

QUrl LinksBagManager::getContentUri(const QString& id)
{
    return Application::GetPath(Application::ArticleCacheDirectory) + id;
}

void LinksBagManager::resetAccount()
{
    ApplicationSettings::Instance(this)->remove("syncOnStartup");
    ApplicationSettings::Instance(this)->remove("lastUpdate");
    ApplicationSettings::Instance(this)->remove("bookmarksViewItemSize");
    ApplicationSettings::Instance(this)->remove("parser");
    ApplicationSettings::Instance(this)->remove("showSearchField");
    ApplicationSettings::Instance(this)->remove("userName");
    ApplicationSettings::Instance(this)->remove("accessToken");
    ApplicationSettings::Instance(this)->remove("useBestView");
    ApplicationSettings::Instance(this)->remove("showContentType");
    ApplicationSettings::Instance(this)->remove("mobileBrowser");
    ApplicationSettings::Instance(this)->remove("backgroundSyncPeriod");
    ApplicationSettings::Instance(this)->remove("showBackgroundImage");
    ApplicationSettings::Instance(this)->remove("statusFilter");
    ApplicationSettings::Instance(this)->remove("contentTypeFilter");

    m_Api->ResetAccount();

    QSettings settings(Application::GetPath(Application::CacheDirectory) +
            "/linksbag_cache", QSettings::IniFormat);
    settings.remove("Bookmarks");
    settings.sync();
    resetArticleCache();
    resetThumbnailCache();

    // fix logout
    QDir webkitCache(Application::GetPath(Application::CacheDirectory) + "/.QtWebKit");
    webkitCache.removeRecursively();
    webkitCache = QDir(Application::GetPath(Application::AppDataDirectory) + "/.QtWebKit");
    webkitCache.removeRecursively();

    m_BookmarksModel->Clear();

    SetLogged(false);
}

void LinksBagManager::resetArticleCache()
{
    // remove directory
    QDir article(Application::GetPath(Application::ArticleCacheDirectory));
    article.removeRecursively();

    // recreate directory
    article.mkpath(Application::GetPath(Application::ArticleCacheDirectory));

    emit articlesCacheReset();
}

void LinksBagManager::resetThumbnailCache()
{
    // remove directories
    QDir cache(Application::GetPath(Application::ThumbnailCacheDirectory));
    cache.removeRecursively();
    cache = QDir(Application::GetPath(Application::CoverCacheDirectory));
    cache.removeRecursively();

    // recreate directories
    cache.mkpath(Application::GetPath(Application::ThumbnailCacheDirectory));
    cache.mkpath(Application::GetPath(Application::CoverCacheDirectory));
}

void LinksBagManager::handleGotAuthAnswer(const QString& data)
{
    if (data.contains("/linksbag_authorization"))
    {
        m_Api->RequestAccessToken();
    }
}

void LinksBagManager::restartSyncTimer()
{
    const int period = ApplicationSettings::Instance(this)->value("backgroundSyncPeriod", "-1").toInt();

    if (period == -1)
    {
        m_SyncTimer->stop();
        return;
    }

    const qint64 lastSync = ApplicationSettings::Instance(this)->value("lastUpdate", 0).toLongLong();
    if (QDateTime::currentDateTime().toTime_t() - lastSync > period)
    {
        refreshBookmarks();
    }

    m_SyncTimer->start(period * 1000);
}

void LinksBagManager::handleWifiOnlyDownloaderChanged(bool wifiOnly)
{
    emit wifiOnlyDownloaderEnabled(wifiOnly);
}

void LinksBagManager::handleOfflineyDownloaderChanged(bool offlineDownloader)
{
    emit offlineDownloaderEnabled(offlineDownloader);
}
} // namespace LinskBag
