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

#include "getpocketapi.h"

#include <memory>

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QSettings>
#include <QStandardPaths>

#include "settings/applicationsettings.h"

namespace LinksBag
{
GetPocketApi::GetPocketApi(QObject *parent)
: QObject(parent)
, m_ConsumerKey(CONSUMER_KEY)
, m_NAM(new QNetworkAccessManager(this))
{
}

namespace
{
    QNetworkRequest CreateRequest(const QString& path)
    {
        QNetworkRequest request(QUrl(QString("https://getpocket.com/v3") +
                path));
        request.setHeader(QNetworkRequest::ContentTypeHeader,
                "application/json; charset=UTF-8");
        request.setRawHeader("X-Accept", "application/json");

        return request;
    }
}

void GetPocketApi::ObtainRequestToken()
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["redirect_uri"] = "linksbag://authorizationFinished";

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/oauth/request"),
            doc.toJson());

    connect(reply,
            &QNetworkReply::finished,
            this,
            &GetPocketApi::handleObtainRequestToken);
}

void GetPocketApi::RequestAccessToken()
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["code"] = m_RequestToken;

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/oauth/authorize"),
            doc.toJson());

    connect(reply,
            &QNetworkReply::finished,
            this,
            &GetPocketApi::handleRequestAccessToken);
}

void GetPocketApi::LoadBookmarks(int lastUpdate)
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["access_token"] = ApplicationSettings::Instance(this)->value("accessToken");
    params["state"] = "all";
    params["sort"] = "oldest";
    params["detailType"] = "complete";
    params["since"] = lastUpdate;

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/get"),
            doc.toJson());

    connect(reply,
            &QNetworkReply::finished,
            this,
            &GetPocketApi::handleLoadBookmarks);
}

void GetPocketApi::RemoveBookmarks(const QStringList& ids)
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["access_token"] = ApplicationSettings::Instance(this)->value("accessToken");
    QVariantList actions;
    for (const auto& id : ids)
    {
        QVariantMap action;
        action["action"] = "delete";
        action["item_id"] = id;
        actions.append(action);
        params["actions"] = actions;
    }

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/send"),
            doc.toJson());
    connect(reply,
            &QNetworkReply::finished,
            this,
            [this, ids]()
            {
                handleRemoveBookmarks(ids);
            });
}

void GetPocketApi::MarkBookmarksAsFavorite(const QStringList& ids, bool favorite)
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["access_token"] = ApplicationSettings::Instance(this)->value("accessToken");
    QVariantList actions;
    for (const auto& id : ids)
    {
        QVariantMap action;
        action["action"] = favorite ? "favorite" : "unfavorite";
        action["item_id"] = id;
        actions.append(action);
    }
    params["actions"] = actions;

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/send"),
            doc.toJson());
    connect(reply,
            &QNetworkReply::finished,
            this,
            [this, ids, favorite]()
            {
                handleMarkBookmarksAsFavorite(ids, favorite);
            });
}

void GetPocketApi::MarkBookmarksAsRead(const QStringList& ids, bool read)
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["access_token"] = ApplicationSettings::Instance(this)->value("accessToken");
    QVariantList actions;
    for (const auto& id : ids)
    {
        QVariantMap action;
        action["action"] = read ? "archive" : "readd";
        action["item_id"] = id;
        actions.append(action);
    }
    params ["actions"] = actions;

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/send"),
            doc.toJson());
    connect(reply,
            &QNetworkReply::finished,
            this,
            [this, ids, read]()
            {
                handleMarkBookmarksAsRead(ids, read);
            });
}

void GetPocketApi::UpdateTags(const QString& id, const QString& tags)
{
    QVariantMap params;
    params["consumer_key"] = m_ConsumerKey;
    params["access_token"] = ApplicationSettings::Instance(this)->value("accessToken");
    QVariantList actions;
    QVariantMap action;
    action["action"] = "tags_replace";
    action["item_id"] = id;
    action["tags"] = tags;
    actions.append(action);
    params ["actions"] = actions;

    QJsonDocument doc(QJsonObject::fromVariantMap(params));

    QNetworkReply *reply = m_NAM->post(CreateRequest("/send"),
            doc.toJson());
    connect(reply,
            &QNetworkReply::finished,
            this,
            [this, id, tags]()
            {
                handleTagsUpdated(id, tags);
            });
}

void GetPocketApi::ResetAccount()
{
    m_RequestToken.clear();
}

QJsonDocument GetPocketApi::PreparsingReply(QObject *sender, bool& ok)
{
    QJsonDocument doc;
    auto reply = qobject_cast<QNetworkReply*> (sender);
    if (!reply)
    {
        qWarning() << "Invalid reply";
        emit error(tr("General error"), 503, ETGeneral);
        ok = false;
        return doc;
    }
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError &&
            reply->error() != QNetworkReply::UnknownContentError &&
            reply->error() != QNetworkReply::UnknownNetworkError &&
            reply->error() != m_InvalidRequestError &&
            reply->error() != m_AuthError &&
            reply->error() != m_PermissionsRateError &&
            reply->error() != m_MaintenanceError &&
            reply->error() != QNetworkReply::ContentOperationNotPermittedError)
    {
        qWarning() << Q_FUNC_INFO << "There is network error: "
                << reply->error() << reply->errorString();
        emit error(tr("Network error: %1").arg(reply->errorString()), reply->error(), ETGeneral);
        ok = false;
        return doc;
    }
    else if (reply->error() != QNetworkReply::NoError)
    {
        const int errorCode = reply->rawHeader("X-Error-Code").toInt();
        const QString errorString = reply->rawHeader("X-Error");
        qWarning() << Q_FUNC_INFO << "There is getpocket error: "
                << errorCode << errorString;
        emit error(errorString, errorCode, ETGetPocket);
        ok = false;
        return doc;
    }

    ok = false;
    QJsonParseError err;
    doc = QJsonDocument::fromJson(reply->readAll(), &err);
    if (err.error != QJsonParseError::NoError)
    {
        qWarning() << "Unable to generate json from reply";
        emit error(tr("Reply data is corrupted"), 503, ETGetPocket);
        return doc;
    }

    ok = true;
    return doc;
}

void GetPocketApi::handleObtainRequestToken()
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    m_RequestToken = doc.object()["code"].toString();
    emit requestTokenChanged(m_RequestToken);
}

void GetPocketApi::handleRequestAccessToken()
{
    emit requestFinished(true);

    auto reply = qobject_cast<QNetworkReply*> (sender());
    if (!reply)
    {
        qWarning() << "Invalid reply";
        emit error(tr("General error"), 503, ETGeneral);
        return;
    }
    reply->deleteLater();

    bool result = false;
    if (reply->error() != QNetworkReply::NoError &&
            reply->error() != QNetworkReply::UnknownContentError &&
            reply->error() != QNetworkReply::UnknownNetworkError &&
            reply->error() != m_InvalidRequestError &&
            reply->error() != m_AuthError &&
            reply->error() != m_PermissionsRateError &&
            reply->error() != m_MaintenanceError &&
            reply->error() != QNetworkReply::ContentOperationNotPermittedError)
    {
        qWarning() << Q_FUNC_INFO << "There is network error: "
                << reply->error() << reply->errorString();
        emit error(tr("Network error: %1").arg(reply->errorString()), reply->error(), ETGeneral);
    }
    else if (reply->error() != QNetworkReply::NoError)
    {
        const int errorCode = reply->rawHeader("X-Error-Code").toInt();
        const QString errorString = reply->rawHeader("X-Error");
        qWarning() << Q_FUNC_INFO << "There is getpocket error: "
                << errorCode << errorString;
        emit error(errorString, errorCode, ETGetPocket);
        emit logged(result, QString(), QString());
        return;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(reply->readAll(), &err);
    if (err.error != QJsonParseError::NoError)
    {
        qWarning() << "Unable to generate json from reply";
        emit error(tr("Reply data is corrupted"), 503, ETGetPocket);
    }

    const auto& accessToken = doc.object()["access_token"].toString();
    const auto& userName = doc.object()["username"].toString();
    result = !accessToken.isEmpty() && !userName.isEmpty();
    emit logged(result, accessToken, userName);
}

void GetPocketApi::handleLoadBookmarks()
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    QJsonObject rootObject = doc.object();
    const quint64 since = rootObject["since"].toDouble();

    const auto& listObject = rootObject["list"].toObject();
    Bookmarks_t bookmarks;
    for(const auto& key : listObject.keys())
    {
        QJsonObject bookmarkObject = listObject[key].toObject();

        if (!bookmarkObject.contains("resolved_url") ||
                !bookmarkObject.contains("item_id"))
        {
            continue;
        }

        auto bm = std::make_shared<Bookmark>();
        bm->SetID(bookmarkObject["item_id"].toString());
        bm->SetUrl(bookmarkObject["resolved_url"].toString());
        QString title = bookmarkObject["resolved_title"].toString();
        if(title.isEmpty())
        {
            title = bookmarkObject["given_title"].toString();
        }
        if(title.isEmpty())
        {
            title = bm->GetUrl().toString();
        }
        bm->SetTitle(title);
        bm->SetDescription(bookmarkObject["excerpt"].toString());
        bm->SetIsFavorite(bookmarkObject["favorite"].toString() != "0" ||
                bookmarkObject["time_favorited"].toString() != "0");
        bm->SetIsRead(bookmarkObject["read"].toString() == "1" ||
                bookmarkObject["time_read"].toString() != "0");
        bm->SetAddTime(QDateTime::fromTime_t(bookmarkObject["time_added"]
                .toString().toLongLong()));
        bm->SetUpdateTime(QDateTime::fromTime_t(bookmarkObject["time_updated"]
                .toString().toLongLong()));
        const auto& tagsObject = bookmarkObject["tags"].toObject();
        bm->SetTags(tagsObject.keys());
        bm->SetImageUrl(bookmarkObject["image"].toObject()["src"].toString());
        bm->SetStatus(static_cast<Bookmark::Status>(bookmarkObject["status"]
                .toString().toInt()));
        Bookmark::ContentType ct = Bookmark::CTNoType;
        if (bookmarkObject.contains("is_article") && bookmarkObject["is_article"].toString().toInt() == 1)
        {
            ct = Bookmark::CTArticle;
        }
        else if (bookmarkObject.contains("has_image") && bookmarkObject["has_image"].toString().toInt() == 2)
        {
            ct = Bookmark::CTImage;
        }
        else if (bookmarkObject.contains("has_video") && bookmarkObject["has_video"].toString().toInt() == 2)
        {
            ct = Bookmark::CTVideo;
        }
        bm->SetContentType(ct);
        if (bookmarkObject.contains("images"))
        {
            const auto& imagesObject = bookmarkObject["images"].toObject();
            QList<QUrl> images;
            for(const auto& imageKey : imagesObject.keys())
            {
                QJsonObject imageObject = imagesObject[imageKey].toObject();
                if (imageObject.contains("src"))
                {
                    images << QUrl(imagesObject["src"].toString());
                }
            }
            bm->SetImages(images);
        }

        if (bookmarkObject.contains("videos"))
        {
            const auto& videosObject = bookmarkObject["videos"].toObject();
            QList<QUrl> videos;
            for(const auto& videoKey : videosObject.keys())
            {
                QJsonObject videoObject = videosObject[videoKey].toObject();
                if (videoObject.contains("src"))
                {
                    videos << QUrl(videoObject["src"].toString());
                }
            }
        }
        bookmarks << bm;
    }

    emit gotBookmarks(bookmarks, since);
}

void GetPocketApi::handleRemoveBookmarks(const QStringList& ids)
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    const auto& rootObject = doc.object();
    if(rootObject ["status"].toInt() == 1)
    {
        emit bookmarksRemoved(ids);
    }
    else
    {
        emit error(tr("Unable to remove bookamark"));
    }
}

void GetPocketApi::handleMarkBookmarksAsFavorite(const QStringList& ids, bool favorite)
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    const auto& rootObject = doc.object();
    if(rootObject ["status"].toInt() == 1)
    {
        emit bookmarksMarkedAsFavorite(ids, favorite);
    }
    else
    {
        emit error(tr("Unable to mark bookamark as %1")
                .arg(favorite ? tr("favorite") : tr("unfavorite")));
    }
}

void GetPocketApi::handleMarkBookmarksAsRead(const QStringList& ids, bool read)
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    const auto& rootObject = doc.object();
    if(rootObject ["status"].toInt() == 1)
    {
        emit bookmarksMarkedAsRead(ids, read);
    }
    else
    {
        emit error(tr("Unable to mark bookamark as %1")
                .arg(read ? tr("read") : tr("unread")));
    }
}

void GetPocketApi::handleTagsUpdated(const QString& id, const QString& tags)
{
    emit requestFinished(true);

    bool ok = false;
    QJsonDocument doc = PreparsingReply(sender(), ok);
    if (!ok)
    {
        qWarning() << Q_FUNC_INFO << "Failed preparsing reply phase";
        return;
    }

    const auto& rootObject = doc.object();
    if(rootObject ["status"].toInt() == 1)
    {
        emit tagsUpdated(id, tags);
    }
    else
    {
        emit error(tr("Unable to update tags"));
    }
}
} // namespace LinksBag
