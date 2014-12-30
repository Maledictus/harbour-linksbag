#pragma once

#include <QObject>
#include <QNetworkReply>
#include "bookmark.h"

class QNetworkAccessManager;

namespace LinksBag
{
    class GetPocketApi : public QObject
    {
        Q_OBJECT

        const QString ConsumerKey_;

        QNetworkAccessManager *NAM_;
        QString RequestToken_;
        QString AccessToken_;
        QString UserName_;
        QHash<QNetworkReply*, QPair<QString, bool>> Reply2Favorite_;
        QHash<QNetworkReply*, QPair<QString, bool>> Reply2Read_;
        QHash<QNetworkReply*, QString> Reply2Remove_;

    public:
        explicit GetPocketApi (QObject *parent = 0);

        void Logout ();
        void ObtainRequestToken ();
        QString GetRequestToken () const;

        void RequestAccessToken ();
        QString GetAccessToken () const;
        QString GetUserName () const;

        void LoadBookmarks (int lastUpdate);
        void RemoveBookmark (const QString& id);
        void MarkBookmarkAsFavorite (const QString& id, bool favorite);
        void MarkBookmarkAsRead (const QString& id, bool read);

    private slots:
        void handleNetworkError (QNetworkReply::NetworkError err);

        void handleObtainRequestToken ();
        void handleRequestAccessToken ();

        void handleLoadBookmarks ();
        void handleRemoveBookmark ();
        void handleMarkBookmarkAsFavorite ();
        void handleMarkBookmarkAsRead ();

    signals:
        void requestTokenChanged ();
        void applicationAuthorized ();

        void gotBookmarks (const Bookmarks_t& bookmarks, quint64 since);
        void bookmarkRemoved (const QString& id);
        void bookmarkMarkedAsFavorite (const QString& id, bool favorite);
        void bookmarkMarkedAsRead (const QString& id, bool read);

    };
} // namespace LinksBag
