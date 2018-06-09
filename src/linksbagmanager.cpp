﻿/*
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
#include <QNetworkRequest>
#include <QFile>
#include <QByteArray>
#include <QImage>
#include <QTimer>

#include "application.h"
#include "src/enumsproxy.h"
#include "src/bookmarksmodel.h"
#include "src/filterproxymodel.h"
#include "src/getpocketapi.h"
#include "src/settings/applicationsettings.h"

namespace LinksBag
{
DownloadedImageHandler::DownloadedImageHandler(QNetworkReply *reply, QString id, BookmarksModel *model):
    m_reply(reply), m_id(id), m_model(model) {}

void DownloadedImageHandler::run()
{
    QImage downloadedImage = QImage::fromData(m_reply->readAll());
    if (!downloadedImage.isNull()) {
        downloadedImage.save(Application::GetPath(Application::CoverCacheDirectory) + m_id + ".jpg");
        downloadedImage.scaled(
            720, 400, Qt::KeepAspectRatioByExpanding
        ).copy(0, 0, 720, 400).save(Application::GetPath(Application::ThumbnailCacheDirectory) + m_id + ".jpg");
        m_model->RefreshBookmark(m_id);
    }
}

LinksBagManager::LinksBagManager(QObject *parent)
: QObject(parent)
, m_Api(new GetPocketApi(this))
, m_IsBusy(false)
, m_IsLogged(false)
, m_BookmarksModel(new BookmarksModel(this))
, m_FilterProxyModel(new FilterProxyModel(this))
, m_CoverModel(new FilterProxyModel(this))
, m_DownloadingModel(new FilterProxyModel(this))
, m_thumbnailDownloader(new QNetworkAccessManager(this))
, m_SyncTimer(new QTimer(this))
{
    MakeConnections();

    QDir dir;
    dir.mkpath(Application::GetPath(Application::ThumbnailCacheDirectory));
    dir.mkpath(Application::GetPath(Application::ArticleCacheDirectory));
    dir.mkpath(Application::GetPath(Application::CoverCacheDirectory));

    m_FilterProxyModel->setSourceModel(m_BookmarksModel);
    m_DownloadingModel->setSourceModel(m_BookmarksModel);
    m_CoverModel->setSourceModel(m_BookmarksModel);
    m_FilterProxyModel->filterBookmarks(ApplicationSettings::Instance()->value("statusFilter").toInt(),
            ApplicationSettings::Instance()->value("contentTypeFilter").toInt());
    m_CoverModel->filterBookmarks(ApplicationSettings::Instance()->value("statusFilter").toInt(),
            ContentTypeAll);

    //m_DownloadingModel->filterBookmarks(LinksBag::FTUnsynced);
    connect(m_thumbnailDownloader, &QNetworkAccessManager::finished,
            this, &LinksBagManager::thumbnailReceived);
    SetLogged(!ApplicationSettings::Instance(this)->value("accessToken").isNull() &&
              !ApplicationSettings::Instance(this)->value("userName").isNull());
    if (m_IsLogged)
    {
        loadBookmarksFromCache();
    }

    connect(m_SyncTimer, &QTimer::timeout, this, &LinksBagManager::refreshBookmarks);
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

                    QUrl url = b->GetImageUrl();
                    if (!url.isEmpty()) {
                        m_thumbnailUrls[url] = b->GetID();
                        m_thumbnailDownloader->get(QNetworkRequest(url));
                    }
                }
                m_FilterProxyModel->invalidate();
                m_FilterProxyModel->sort(0, Qt::DescendingOrder);
                ApplicationSettings::Instance(this)->setValue("lastUpdate", since);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkRemoved,
            this,
            [this](const QString& id)
            {
                m_BookmarksModel->RemoveBookmark(id);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkMarkedAsFavorite,
            [this](const QString& id, bool favorite)
            {
                m_BookmarksModel->MarkBookmarkAsFavorite(id, favorite);
                emit bookmarkFavoriteStateChanged(id, favorite);
            });

    connect(m_Api.get(),
            &GetPocketApi::bookmarkMarkedAsRead,
            [this](const QString& id, bool read)
            {
                m_BookmarksModel->MarkBookmarkAsRead(id, read);
                emit bookmarkReadStateChanged(id, read);
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

void LinksBagManager::thumbnailReceived(QNetworkReply *pReply) {
    if (pReply->error() == QNetworkReply::NoError) {
        QString bookmarkId = m_thumbnailUrls.value(pReply->url(), "");
        QThreadPool::globalInstance()->start(new DownloadedImageHandler(pReply, bookmarkId, m_BookmarksModel));
    }
    m_thumbnailUrls.remove(pReply->url());
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

BookmarksModel* LinksBagManager::GetBookmarksModel() const
{
    return m_BookmarksModel;
}

FilterProxyModel* LinksBagManager::GetFilterModel() const
{
    return m_FilterProxyModel;
}

FilterProxyModel* LinksBagManager::GetDownloadingModel() const
{
    return m_DownloadingModel;
}

FilterProxyModel *LinksBagManager::GetCoverModel() const
{
    return m_CoverModel;
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

void LinksBagManager::updateTags(const QString& id, const QString& tags)
{
    SetBusy(true);
    m_Api->UpdateTags(id, tags);
}

void LinksBagManager::updateContent(const QString& id, const QString& content)
{
    QFile file(Application::GetPath(Application::ArticleCacheDirectory) + id);
    if (file.open(QIODevice::WriteOnly)) {
        QTextStream stream(&file);
        stream << content;
    } else {
        qDebug() << "Can't save file: " << file.errorString();
    }
    file.close();
    m_BookmarksModel->RefreshBookmark(id);
}

void LinksBagManager::updateContent(const QString& id, const QImage& imageContent)
{
    imageContent.save(Application::GetPath(Application::ArticleCacheDirectory) + id,
            "PNG");
    m_BookmarksModel->RefreshBookmark(id);
}

void LinksBagManager::updatePublishDate(const QString& id, const QString& date)
{
    m_BookmarksModel->UpdatePublishDate(id, date);
    m_BookmarksModel->RefreshBookmark(id);
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

    if (filePath.isEmpty()) {
        return "";
    }

    QFile file(filePath);
    if(!file.open(QIODevice::ReadOnly)) {
        return "";
    }

    QTextStream in(&file);
    QString content;

    while(!in.atEnd()) {
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
    const int period = ApplicationSettings::Instance()->value("backgroundSyncPeriod", "-1").toInt();

    if (period == -1) {
        m_SyncTimer->stop();
        return;
    }

    const qint64 lastSync = ApplicationSettings::Instance(this)->value("lastUpdate", 0).toLongLong();
    if (QDateTime::currentDateTime().toTime_t() - lastSync > period) {
        refreshBookmarks();
    }

    m_SyncTimer->start(period * 1000);
}

} // namespace LinskBag
