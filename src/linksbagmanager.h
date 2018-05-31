/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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

#include "src/bookmark.h"
#include <QObject>
#include <QVariantMap>
#include <QMap>
#include <QNetworkReply>
#include <QNetworkAccessManager>
#include <QThreadPool>

class QTimer;

namespace LinksBag
{
class BookmarksModel;
class FilterProxyModel;
class GetPocketApi;

class DownloadedImageHandler: public QRunnable
{
public:
    DownloadedImageHandler(QNetworkReply *reply, QString id, BookmarksModel* model = 0);
    void run();
private:
    QNetworkReply* m_reply;
    const QString m_id;
    BookmarksModel* m_model;
};

class LinksBagManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(LinksBagManager)

    std::shared_ptr<GetPocketApi> m_Api;

    bool m_IsBusy;
    bool m_IsLogged;

    QString m_RequesToken;
    QString m_UserName;
    QString m_Filter;
    bool m_Authorized;
    BookmarksModel *m_BookmarksModel;
    FilterProxyModel *m_FilterProxyModel;
    FilterProxyModel *m_DownloadingModel;

    QMap<QUrl, QString> m_thumbnailUrls;
    QNetworkAccessManager *m_thumbnailDownloader;
    QTimer *m_SyncTimer;

    Q_PROPERTY(bool busy READ GetBusy NOTIFY busyChanged)
    Q_PROPERTY(bool logged READ GetLogged NOTIFY loggedChanged)
    Q_PROPERTY(BookmarksModel* bookmarksModel READ GetBookmarksModel
            NOTIFY bookmarksModelChanged)
    Q_PROPERTY(FilterProxyModel* filterModel READ GetFilterModel
            NOTIFY filterModelChanged)
    Q_PROPERTY(FilterProxyModel* downloadingModel READ GetDownloadingModel
            NOTIFY downloadingModelChanged)

    explicit LinksBagManager(QObject *parent = 0);
public:
    static LinksBagManager* Instance(QObject *parent = 0);
    bool GetBusy() const;
    bool GetLogged() const;

    BookmarksModel* GetBookmarksModel() const;
    FilterProxyModel* GetFilterModel() const;
    FilterProxyModel* GetDownloadingModel() const;

private:
    void MakeConnections();
    void SetBusy(const bool busy);
    void SetLogged(const bool logged);

private slots:
    void thumbnailReceived(QNetworkReply* pReply);

public slots:
    void obtainRequestToken();
    void requestAccessToken();

    void filterBookmarks(const QString& text);

    void loadBookmarksFromCache();
    void saveBookmarks();
    void refreshBookmarks();
    void removeBookmark(const QString& id);
    void markAsFavorite(const QString& id, bool favorite);
    void markAsRead(const QString& id, bool read);
    void updateTags(const QString& id, const QString& tags);

    void updateContent(const QString& id, const QString& content);
    void updateContent(const QString& id, const QImage& imageContent);
    void updatePublishDate(const QString& id, const QString& date);
    QString getContent(const QString& id);
    QUrl getContentUri(const QString& id);

    void resetAccount();
    void resetThumbnailCache();
    void resetArticleCache();

    void handleGotAuthAnswer(const QString& data);

    void restartSyncTimer();

signals:
    void busyChanged();
    void loggedChanged();
    void requestTokenChanged(const QString& requestToken);

    void bookmarksModelChanged();
    void filterModelChanged();
    void downloadingModelChanged();

    void bookmarkReadStateChanged(const QString& id, bool readState);
    void bookmarkFavoriteStateChanged(const QString& id, bool favoriteState);

    void error(const QString& msg, int type);
    void notify(const QString& msg);

    void articlesCacheReset();
};
} // namespace LinskBag
