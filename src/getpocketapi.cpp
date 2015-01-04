#include "getpocketapi.h"
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QSettings>
#include <QStandardPaths>

namespace LinksBag
{       
    GetPocketApi::GetPocketApi (QObject *parent)
    : QObject (parent)
    , ConsumerKey_ ("36050-db8157de51cbb0c5f72edc33")
    , NAM_ (new QNetworkAccessManager (this))
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        UserName_ = settings.value ("username").toString ();
        AccessToken_ = QByteArray::fromHex (QByteArray::fromBase64 (settings.value ("access_token").toByteArray ()));
    }

    void GetPocketApi::Logout ()
    {
        RequestToken_.clear ();
        AccessToken_.clear ();
        UserName_.clear ();
    }

    namespace
    {
        QNetworkRequest CreateRequest (const QUrl& url)
        {
            QNetworkRequest request (url);
            request.setHeader (QNetworkRequest::ContentTypeHeader ,
                    "application/json; charset=UTF-8");
            request.setRawHeader ("X-Accept", "application/json");

            return request;
        }
    }

    void GetPocketApi::ObtainRequestToken ()
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["redirect_uri"] = "linksbag://authorizationFinished";

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/oauth/request")),
                doc.toJson ());

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleObtainRequestToken);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    QString GetPocketApi::GetRequestToken () const
    {
        return RequestToken_;
    }

    void GetPocketApi::RequestAccessToken ()
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["code"] = RequestToken_;

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/oauth/authorize")),
                doc.toJson ());

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleRequestAccessToken);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    QString GetPocketApi::GetAccessToken () const
    {
        return AccessToken_;
    }

    QString GetPocketApi::GetUserName () const
    {
        return UserName_;
    }

    void GetPocketApi::LoadBookmarks (int lastUpdate)
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["access_token"] = AccessToken_;
        params ["state"] = "all";
        params ["sort"] = "oldest";
        params ["detailType"] = "complete";
        params ["since"] = lastUpdate;

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/get")),
                doc.toJson ());

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleLoadBookmarks);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    void GetPocketApi::RemoveBookmark (const QString& id)
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["access_token"] = AccessToken_;
        QVariantList actions;
        QVariantMap action;
        action ["action"] = "delete";
        action ["item_id"] = id;
        actions.append (action);
        params ["actions"] = actions;

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/send")),
                doc.toJson ());
        Reply2Remove_ [reply] = id;

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleRemoveBookmark);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    void GetPocketApi::MarkBookmarkAsFavorite (const QString& id, bool favorite)
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["access_token"] = AccessToken_;
        QVariantList actions;
        QVariantMap action;
        action ["action"] = favorite ? "favorite" : "unfavorite";
        action ["item_id"] = id;
        actions.append (action);
        params ["actions"] = actions;

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/send")),
                doc.toJson ());
        Reply2Favorite_ [reply] = qMakePair (id, favorite);

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleMarkBookmarkAsFavorite);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    void GetPocketApi::MarkBookmarkAsRead (const QString& id, bool read)
    {
        QVariantMap params;
        params ["consumer_key"] = ConsumerKey_;
        params ["access_token"] = AccessToken_;
        QVariantList actions;
        QVariantMap action;
        action ["action"] = read ? "archive" : "readd";
        action ["item_id"] = id;
        actions.append (action);
        params ["actions"] = actions;

        QJsonDocument doc (QJsonObject::fromVariantMap (params));

        QNetworkReply *reply = NAM_->post (CreateRequest (QUrl ("https://getpocket.com/v3/send")),
                doc.toJson ());
        Reply2Read_ [reply] = qMakePair (id, read);

        connect (reply,
                &QNetworkReply::finished,
                this,
                &GetPocketApi::handleMarkBookmarkAsRead);
        connect (reply,
                SIGNAL (error (QNetworkReply::NetworkError)),
                this,
                SLOT (handleNetworkError (QNetworkReply::NetworkError)));
    }

    void GetPocketApi::handleNetworkError (QNetworkReply::NetworkError err)
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            emit error (reply->errorString ());
        }
    }

    void GetPocketApi::handleObtainRequestToken ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            if (doc.isNull ())
                ;//TODO error
            else
            {
                RequestToken_ = doc.object () ["code"].toString ();
                emit requestTokenChanged ();
            }
        }
    }

    void GetPocketApi::handleRequestAccessToken ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            if (doc.isNull ())
                ;//TODO error
            else
            {
                AccessToken_ = doc.object () ["access_token"].toString ();
                UserName_ = doc.object () ["username"].toString ();
                emit applicationAuthorized ();
            }
        }
    }

    void GetPocketApi::handleLoadBookmarks ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            QJsonObject rootObject = doc.object ();
            if (rootObject ["error"].toString () == "null")
            {
                //TODO error
                return;
            }

            const quint64 since = rootObject ["since"].toDouble ();

            const auto& listObject = rootObject ["list"].toObject ();
            Bookmarks_t bookmarks;
            for (const auto& key : listObject.keys ())
            {
                QJsonObject bookmarkObject = listObject [key].toObject ();

                Bookmark *bm = new Bookmark;
                bm->SetID (bookmarkObject ["item_id"].toString ());
                bm->SetUrl (bookmarkObject ["resolved_url"].toString ());
                QString title = bookmarkObject ["resolved_title"].toString ();
                if (title.isEmpty ())
                    title = bookmarkObject ["given_title"].toString ();
                if (title.isEmpty ())
                    title = bm->GetUrl ().toString ();
                bm->SetTitle (title);
                bm->SetDescription (bookmarkObject ["excerpt"].toString ());
                bm->SetIsFavorite (bookmarkObject ["favorite"].toString () != "0" || bookmarkObject ["time_favorited"].toString() != "0");
                bm->SetIsRead (bookmarkObject ["read"].toString () == "1" || bookmarkObject ["time_read"].toString() != "0");
                bm->SetAddTime (QDateTime::fromTime_t (bookmarkObject ["time_added"].toString ().toLongLong()));
                bm->SetUpdateTime (QDateTime::fromTime_t (bookmarkObject ["time_updated"].toString ().toLongLong()));
                const auto& tagsObject = bookmarkObject ["tags"].toObject ();
                bm->SetTags (tagsObject.keys ());
                bm->SetImageUrl (bookmarkObject ["image"].toObject () ["src"].toString ());
                bm->SetStatus (static_cast<Bookmark::Status> (bookmarkObject ["status"].toString ().toInt ()));

                bookmarks << bm;
            }

            emit gotBookmarks (bookmarks, since);
        }
    }

    void GetPocketApi::handleRemoveBookmark ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            const QString& id = Reply2Remove_.take (reply);
            if (doc.isNull ())
                ;//TODO error
            else
            {
                const auto& rootObject = doc.object ();
                if (rootObject ["status"].toInt () == 1)
                    emit bookmarkRemoved (id);
            }
        }
    }

    void GetPocketApi::handleMarkBookmarkAsFavorite ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            const auto& pair = Reply2Favorite_.take (reply);
            if (doc.isNull ())
                ;//TODO error
            else
            {
                const auto& rootObject = doc.object ();
                if (rootObject ["status"].toInt () == 1)
                    emit bookmarkMarkedAsFavorite (pair.first, pair.second);
            }
        }
    }

    void GetPocketApi::handleMarkBookmarkAsRead ()
    {
        if (auto reply = qobject_cast<QNetworkReply*> (sender ()))
        {
            QJsonDocument doc = QJsonDocument::fromJson (reply->readAll ());
            const auto& pair = Reply2Read_.take (reply);
            if (doc.isNull ())
                ;//TODO error
            else
            {
                const auto& rootObject = doc.object ();
                if (rootObject ["status"].toInt () == 1)
                    emit bookmarkMarkedAsRead (pair.first, pair.second);
            }
        }
    }
} // namespace LinksBag
