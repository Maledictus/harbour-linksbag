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

#pragma once

#include <memory>

#include <QNetworkConfiguration>
#include <QObject>
#include <QMutex>
#include <QString>
#include <QPointer>

#include "bookmark.h"

class QNetworkAccessManager;
class QNetworkConfigurationManager;
class QNetworkReply;

namespace LinksBag
{
class Bookmark;

class OfflineDownloader : public QObject
{
    Q_OBJECT

    QNetworkAccessManager *m_NAM;
    QNetworkConfigurationManager *m_NCM;
    Bookmarks_t m_Bookmarks;
    QMutex m_Mutex;
    QPointer<QNetworkReply> m_CurrentReply;
    bool m_OfflineDownloader;
    bool m_WifiOnlyDownloader;
    bool m_UnreadOnlyDownloader;
    bool m_IsOnline;
    bool m_IsWifi;
    int m_QueueSize;

public:
    static QString MercuryApiKey;

    explicit OfflineDownloader();
    ~OfflineDownloader();

    int GetBookmarkCount();
    Q_INVOKABLE void SetBookmarks(const Bookmarks_t& bookmarks);

private:
    void DownloadNextBookmark();
    void DownloadBookmark(std::shared_ptr<Bookmark> bookmark);

public slots:
    void start();
    void stop();

    void handleWifiOnlyDownloaderEnabled(bool wifiOnly);
    void handleOfflineDownloaderEnabled(bool offlineDownloader);
    void handleUnreadOnlyDownloaderEnabled(bool unreadOnly);

private slots:
    void handleOnlineStateChanged(bool isOnline);
    void handleConfigurationAdded(const QNetworkConfiguration& config);
    void handleConfigurationRemoved(const QNetworkConfiguration& config);
    void handleConfigurationChanged(const QNetworkConfiguration& config);

    void handleBookmarkDownloaded(std::shared_ptr<Bookmark> bookmark);

    void updateWifiState();

signals:
    void queueNeedsRefresh();
    void updateBookmarkCount();
    void updateArticleContent(const QString& id, const QString& pubDate, const QString& content);
    void updateImageContent(const QString& id, const QImage& imageContent);
};

} // namespace LinksBag

