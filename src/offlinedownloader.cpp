/*
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

#include "offlinedownloader.h"

#include <algorithm>

#include <QImage>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkConfigurationManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QtDebug>

#include "bookmarksmodel.h"
#include "linksbagmanager.h"
#include "settings/applicationsettings.h"

namespace LinksBag
{
QString OfflineDownloader::MercuryApiKey = "kmEINFMf17L8zYYZlrOzsfL6XaNXCMqd2gx7JxTT";

OfflineDownloader::OfflineDownloader()
: m_OfflineDownloader(ApplicationSettings::Instance(this)->value("offlineDownloader", false).toBool())
, m_WifiOnlyDownloader(ApplicationSettings::Instance(this)->value("wifiOnlyDownloader", false).toBool())
, m_UnreadOnlyDownloader(ApplicationSettings::Instance(this)->value("unreadOnlyDownloader", false).toBool())
, m_IsOnline(false)
, m_IsWifi(false)
{
}

OfflineDownloader::~OfflineDownloader()
{
    m_NAM->deleteLater();
    m_NCM->deleteLater();
}

int OfflineDownloader::GetBookmarkCount()
{
    return m_QueueSize;
}

void OfflineDownloader::SetBookmarks(const Bookmarks_t& bookmarks)
{
    Bookmarks_t tempBookmarks = bookmarks;

    if (m_UnreadOnlyDownloader) {
        tempBookmarks.erase(std::remove_if(tempBookmarks.begin(), tempBookmarks.end(),
                [](decltype(tempBookmarks.front()) bkmrk) { return bkmrk->IsRead(); }),
                tempBookmarks.end());
    }
    m_QueueSize = tempBookmarks.count();

    tempBookmarks.erase(std::remove_if(tempBookmarks.begin(), tempBookmarks.end(),
            [](decltype(tempBookmarks.front()) bkmrk) { return bkmrk->HasContent(); }),
            tempBookmarks.end());

    m_Mutex.lock();
    m_Bookmarks = tempBookmarks;
    m_Mutex.unlock();
    emit updateBookmarkCount();

    DownloadNextBookmark();
}

void OfflineDownloader::DownloadNextBookmark()
{
    if (!m_OfflineDownloader)
    {
        return;
    }

    if (m_WifiOnlyDownloader && !m_IsWifi)
    {
        return;
    }

    if (!m_IsOnline)
    {
        return;
    }

    if (m_CurrentReply)
    {
        return;
    }

    QMutexLocker locker(&m_Mutex);
    std::shared_ptr<Bookmark> bookmark;
    while (!bookmark && !m_Bookmarks.empty())
    {
        bookmark = m_Bookmarks.takeFirst();
    }

    if (bookmark)
    {
        DownloadBookmark(bookmark);
    }
}

namespace
{
QNetworkRequest CreateRequest(const QString& downloadingUrl)
{
    QNetworkRequest request(QUrl("https://mercury.postlight.com/parser?url=" +
            downloadingUrl));
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("x-api-key", OfflineDownloader::MercuryApiKey.toUtf8());
    return request;
}
}

void OfflineDownloader::DownloadBookmark(std::shared_ptr<Bookmark> bookmark)
{
    m_CurrentReply = m_NAM->get(bookmark->GetContentType() == Bookmark::CTImage ?
                QNetworkRequest(bookmark->GetUrl()) :
                CreateRequest(bookmark->GetUrl().toDisplayString()));
    connect(m_CurrentReply.data(),
            &QNetworkReply::finished,
            this,
            [this, bookmark]()
            {
                handleBookmarkDownloaded(bookmark);
            });
}

void OfflineDownloader::start()
{
    m_NAM = new QNetworkAccessManager();
    m_NCM = new QNetworkConfigurationManager();
    connect(m_NCM, &QNetworkConfigurationManager::onlineStateChanged,
            this, &OfflineDownloader::handleOnlineStateChanged);
    connect(m_NCM, &QNetworkConfigurationManager::configurationAdded,
            this, &OfflineDownloader::handleConfigurationAdded);
    connect(m_NCM, &QNetworkConfigurationManager::configurationRemoved,
            this, &OfflineDownloader::handleConfigurationRemoved);
    connect(m_NCM, &QNetworkConfigurationManager::configurationChanged,
            this, &OfflineDownloader::handleConfigurationChanged);
    handleOnlineStateChanged(m_NCM->isOnline());
}

void OfflineDownloader::stop()
{
}

void OfflineDownloader::handleOnlineStateChanged(bool isOnline)
{
    bool runDownloading = false;
    if (m_IsOnline != isOnline)
    {
        m_IsOnline = isOnline;
        runDownloading = isOnline;
    }

    updateWifiState();

    if (runDownloading)
    {
        DownloadNextBookmark();
    }
}

void OfflineDownloader::handleConfigurationAdded(const QNetworkConfiguration&)
{
    handleOnlineStateChanged(m_NCM->isOnline());
}

void OfflineDownloader::handleConfigurationRemoved(const QNetworkConfiguration&)
{
    handleOnlineStateChanged(m_NCM->isOnline());
}

void OfflineDownloader::handleConfigurationChanged(const QNetworkConfiguration& config)
{
    if (config.state() == QNetworkConfiguration::Active)
    {
        handleOnlineStateChanged(m_NCM->isOnline());
    }
}

namespace
{
QByteArray PreparsingReply(QObject *sender, bool& ok)
{
    QByteArray data;
    auto reply = qobject_cast<QNetworkReply*>(sender);
    if (!reply)
    {
        qWarning() << "Invalid reply";
        ok = false;
        return data;
    }
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError)
    {
        qWarning() << Q_FUNC_INFO << "There is network error: "
                << reply->error() << reply->errorString();
        ok = false;
        return data;
    }

    ok = true;
    return reply->readAll();
}
}

void OfflineDownloader::handleBookmarkDownloaded(std::shared_ptr<Bookmark> bookmark)
{
    bool ok = false;
    QByteArray data = PreparsingReply(sender(), ok);
    if (ok && bookmark)
    {
        if (bookmark->GetContentType() != Bookmark::CTImage)
        {
            QJsonParseError err;
            QJsonDocument doc = QJsonDocument::fromJson(data, &err);
            if (err.error != QJsonParseError::NoError)
            {
                qWarning() << "Unable to generate json from reply";
            }
            else
            {
                QJsonObject rootObject = doc.object();
                QString content;
                QString publishDate;
                if (rootObject.contains("content")) {
                    content = rootObject["content"].toString();
                }
                if (rootObject.contains("date_published")) {
                    publishDate = rootObject["date_published"].toString();
                }

                emit updateArticleContent(bookmark->GetID(), publishDate, content);
            }
        }
        else
        {
            emit updateImageContent(bookmark->GetID(), QImage::fromData(data));
        }
    }
    else
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
    }
    m_CurrentReply.clear();
    DownloadNextBookmark();
}

void OfflineDownloader::updateWifiState()
{
    for (auto config : m_NCM->allConfigurations(QNetworkConfiguration::Active))
    {
        if (config.bearerType() == QNetworkConfiguration::BearerWLAN) {
            m_IsWifi = true;
            return;
        }
    }
    m_IsWifi = false;
}

void OfflineDownloader::handleWifiOnlyDownloaderEnabled(bool wifiOnly)
{
    m_WifiOnlyDownloader = wifiOnly;
    DownloadNextBookmark();
}

void OfflineDownloader::handleOfflineDownloaderEnabled(bool offlineDownloader)
{
    if (m_OfflineDownloader != offlineDownloader)
    {
        m_OfflineDownloader = offlineDownloader;
        if (m_OfflineDownloader)
        {
            DownloadNextBookmark();
        }
    }
}

void OfflineDownloader::handleUnreadOnlyDownloaderEnabled(bool unreadOnly)
{
    m_UnreadOnlyDownloader = unreadOnly;
    emit queueNeedsRefresh();
    DownloadNextBookmark();
}
} // namespace LinksBag
