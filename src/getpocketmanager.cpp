#include "getpocketmanager.h"
#include <QDateTime>
#include <QDesktopServices>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSettings>
#include <QStringList>
#include <QtDebug>
#include <QTextCodec>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace LinksBag
{
	GetPocketManager::GetPocketManager(QObject *parent)
	: QObject(parent)
	, ConsumerKey_ ("12464-6eefaffd8db4baedd23a64af")
	, NetworkManager_ (new QNetworkAccessManager (this))
	{
		//TODO Temporary solution
		Login_ = "Maledictus";
		AccessToken_ = "4f61008e-5406-4d64-c023-35512d";
//		QSettings settings;
//		AccessToken_ = settings.value ("AccessToken").toString ();
//		Login_ = settings.value ("Username").toString ();

		Authorized_ = !AccessToken_.isEmpty ();

		emit loginChanged ();
		emit authorizeStateChanged ();
	}

	bool GetPocketManager::IsAuthorized () const
	{
		return Authorized_;
	}

	QString GetPocketManager::GetLogin () const
	{
		return Login_;
	}

	void GetPocketManager::authorize ()
	{
		QByteArray payload = QString ("consumer_key=%1&redirect_uri=%2")
				.arg (ConsumerKey_)
				.arg ("linksbag://authorizationFinished").toUtf8 ();

		QString requestTokenUrlStr ("https://getpocket.com/v3/oauth/request?");
		QUrl url = QUrl::fromEncoded (requestTokenUrlStr.toUtf8 () + payload);
		QNetworkRequest request (url);
		request.setHeader (QNetworkRequest::ContentTypeHeader,
				"application/x-www-form-urlencoded; charset=UTF8");

		QNetworkReply *reply = NetworkManager_->post (request, payload);
		connect (reply,
				SIGNAL (finished ()),
				this,
				SLOT (obtainRequestTokenFinished ()));
	}

	void GetPocketManager::refresh ()
	{
		QVariantMap payload;
		payload ["consumer_key"] = ConsumerKey_;
		payload ["access_token"] = AccessToken_;
		payload ["state"] = "all";
		payload ["sort"] = "newest";
        payload ["detailType"] = "complete";

//        QSettings settings;
//        if (settings.contains ("LastSyncDate"))
//            payload ["since"] = settings.value ("LastSyncDate");

        QJsonDocument doc = QJsonDocument::fromVariant (payload);
        QNetworkRequest request (QUrl ("https://getpocket.com/v3/get"));
		request.setHeader (QNetworkRequest::ContentTypeHeader,
				"application/json; charset=UTF-8");
		request.setRawHeader ("X-Accept", "application/json");
        QNetworkReply *reply = NetworkManager_->post (request, doc.toJson ());
		connect (reply,
				SIGNAL (finished ()),
				this,
				SLOT (handleGotItems ()));
	}

    //TODO doesn't work
	void GetPocketManager::setRead (qint64 id, bool read)
	{
		QVariantMap map;
		map ["action"] = read ? "archive" : "readd";
		map ["item_id"] = id;

        QJsonDocument doc = QJsonDocument::fromVariant (map);
        QByteArray payload = QString ("&consumer_key=%1&access_token=%2")
				.arg (ConsumerKey_)
                .arg (AccessToken_).toUtf8 ();

        QString str = QString::fromUtf8 (doc.toJson (QJsonDocument::Compact));
        str.remove (' ');
        payload = "actions=" + QUrl::toPercentEncoding (str) + payload;
        QString requestTokenUrlStr ("https://getpocket.com/v3/send?");

        QUrl url (requestTokenUrlStr + payload);
        QNetworkRequest request (url);
        QNetworkReply *reply = NetworkManager_->get (request);
        Reply2ReadId_ [reply] = id;
		connect (reply,
				SIGNAL (finished ()),
				this,
				SLOT (handleSetReadFinished ()));
	}

	void GetPocketManager::setFavorite (qint64 id, bool favorite)
	{
		QVariantList list;
		QVariantMap map;
		map ["action"] = favorite ? "favorite" : "unfavorite";
		map ["item_id"] = id;
		list << map;

        QJsonDocument doc = QJsonDocument::fromVariant (list);
        QByteArray payload = QString ("&consumer_key=%1&access_token=%2")
				.arg (ConsumerKey_)
				.arg (AccessToken_).toUtf8 ();

        QString str = QString::fromUtf8 (doc.toJson (QJsonDocument::Compact));
		str.remove (' ');
		payload = "actions=" + QUrl::toPercentEncoding (str) + payload;
		QString requestTokenUrlStr ("https://getpocket.com/v3/send?");

        QUrl url (requestTokenUrlStr + payload);
		QNetworkRequest request (url);
        QNetworkReply *reply = NetworkManager_->get (request);
        Reply2FavoriteId_ [reply] = id;
		connect (reply,
				SIGNAL (finished ()),
				this,
                SLOT (handleSetFavoriteFinished ()));
    }

    void GetPocketManager::deleteItem (qint64 id)
    {
        QVariantList list;
        QVariantMap map;
        map ["action"] = "delete";
        map ["item_id"] = id;
        list << map;

        QJsonDocument doc = QJsonDocument::fromVariant (list);
        QByteArray payload = QString ("&consumer_key=%1&access_token=%2")
                .arg (ConsumerKey_)
                .arg (AccessToken_).toUtf8 ();

        QString str = QString::fromUtf8 (doc.toJson (QJsonDocument::Compact));
        str.remove (' ');
        payload = "actions=" + QUrl::toPercentEncoding (str) + payload;
        QString requestTokenUrlStr ("https://getpocket.com/v3/send?");

        QUrl url (requestTokenUrlStr + payload);
        QNetworkRequest request (url);
        QNetworkReply *reply = NetworkManager_->get (request);
        Reply2DeleteItemId_ [reply] = id;
        connect (reply,
                SIGNAL (finished ()),
                this,
                SLOT (handleDeleteItemFinished ()));
    }

	void GetPocketManager::requestAccessToken ()
	{
		QByteArray payload = QString ("consumer_key=%1&code=%2")
				.arg (ConsumerKey_)
				.arg (RequestToken_).toUtf8 ();

		QString requestTokenUrlStr ("https://getpocket.com/v3/oauth/authorize?");
		QUrl url = QUrl::fromEncoded (requestTokenUrlStr.toUtf8 () + payload);
		QNetworkRequest request (url);
		request.setHeader (QNetworkRequest::ContentTypeHeader,
				"application/x-www-form-urlencoded; charset=UTF8");

		QNetworkReply *reply = NetworkManager_->post (request, payload);
		connect (reply,
				SIGNAL (finished ()),
				this,
				SLOT (obtainAccessTokenFinished ()));
	}

	void GetPocketManager::obtainRequestTokenFinished ()
	{
		QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
		if (!reply)
			return;
		reply->deleteLater ();

		RequestToken_ = QString::fromUtf8 (reply->readAll ()).split ('=').at (1);
		QByteArray payload = QString ("request_token=%1&redirect_uri=%2")
				.arg (RequestToken_)
				.arg ("linksbag://authorizationFinished").toUtf8 ();

		QString requestTokenUrlStr ("https://getpocket.com/auth/authorize?");
		QUrl url = QUrl::fromEncoded (requestTokenUrlStr.toUtf8 () + payload);
		qDebug () << url;
//		QDesktopServices::openUrl (url);
	}

	void GetPocketManager::obtainAccessTokenFinished ()
	{
		QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
		if (!reply)
			return;
		reply->deleteLater ();

		const QStringList values = QString::fromUtf8 (reply->readAll ()).split ('&');
		AccessToken_ = values.value (0).section ('=', 1, 1);
		Login_ = values.value (1).section ('=', 1, 1);

		emit loginChanged();
		emit authorizeStateChanged ();

		QSettings settings;
		settings.setValue ("Username", Login_);
		settings.setValue ("AccessToken", AccessToken_);

		QByteArray payload = QString ("consumer_key=%1&access_token=%2")
				.arg (ConsumerKey_)
				.arg (AccessToken_).toUtf8 ();

		QString requestTokenUrlStr ("https://getpocket.com/auth/authorize?");
		QUrl url = QUrl::fromEncoded (requestTokenUrlStr.toUtf8 () + payload);
	}

	void GetPocketManager::handleGotItems ()
	{
		QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
		if (!reply)
			return;
		reply->deleteLater ();

        QJsonParseError error;
        QJsonDocument doc = QJsonDocument::fromJson (reply->readAll (), &error);
        if (doc.isNull ())
		{
            qCritical () << "Something went wrong:" << error.errorString ();
			return;
		}
        const auto& object = doc.object ();
        if (object.isEmpty ())
            return;

		QList<PocketEntry> entries;
        for (const auto& item : object.value ("list").toObject ())
		{
            const QJsonObject itemObject = item.toObject ();
            if (itemObject.isEmpty ())
                continue;

            PocketEntry entry;
            entry.Id_ = itemObject.value ("item_id").toVariant ().toLongLong ();
            entry.Title_ = itemObject.value ("resolved_title").toString ();

			if (entry.Title_.isEmpty ())
                entry.Title_ = itemObject.value ("given_title").toString ();
            entry.Url_ = QUrl (itemObject.value ("resolved_url").toString ());
            entry.AddTime_ = QDateTime::fromTime_t (itemObject.value ("time_added")
                    .toVariant ().toLongLong ());
            entry.Favorite_ = itemObject.value ("favorite").toBool ();
            entry.Read_ = itemObject.value ("time_read").toDouble () != 0;
            for (const auto& tag : itemObject.value ("tags").toObject ())
            {
                const auto& tagObject = tag.toObject ();
                entry.Tags_ << tagObject.value ("tag").toString ();
            }

			if (!entry.IsEmpty ())
				entries << entry;
		}

		emit gotEntries (entries);
//        QSettings settings;
//        settings.setValue ("LastSyncDate", map ["since"].toLongLong () + 1);
	}

	void GetPocketManager::handleSetReadFinished ()
	{
        QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
        if (!reply)
            return;
        const auto& content = reply->readAll ();
        QJsonDocument doc = QJsonDocument::fromBinaryData (content);
        reply->deleteLater ();
        const auto& object = doc.object ();
        if (object.isEmpty ())
            return;

        qDebug () << content;
        if (object.value ("action_results").toArray ().at (0).toBool () &&
                object.value ("status").toString () == "1")
            emit favoriteStateChanged (Reply2ReadId_.take (reply));
	}

	void GetPocketManager::handleSetFavoriteFinished ()
	{
		QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
		if (!reply)
			return;
        const auto& content = reply->readAll ();
		reply->deleteLater ();
        QJsonDocument doc = QJsonDocument::fromJson (content);
        const auto& object = doc.object ();
        if (object.isEmpty ())
            return;

        if (object.value ("action_results").toArray ().at (0).toBool () &&
                object.value ("status").toVariant ().toInt () == 1)
            emit favoriteStateChanged (Reply2FavoriteId_.take (reply));

    }

    void GetPocketManager::handleDeleteItemFinished ()
    {
        QNetworkReply *reply = qobject_cast<QNetworkReply*> (sender ());
        if (!reply)
            return;
        const auto& content = reply->readAll ();
        reply->deleteLater ();

        QJsonDocument doc = QJsonDocument::fromJson (content);
        const auto& object = doc.object ();
        if (object.isEmpty ())
            return;

        if (object.value ("action_results").toArray ().at (0).toBool () &&
                object.value ("status").toVariant ().toInt () == 1)
            emit itemDeleted (Reply2DeleteItemId_.take (reply));
    }

	QDataStream& operator<< (QDataStream& out, const PocketEntry& entry)
	{
        out << static_cast<qint8> (2)
				<< entry.Id_
				<< entry.Title_
				<< entry.Url_
				<< entry.AddTime_
				<< entry.Favorite_
                << entry.Read_
                << entry.Tags_;
		return out;
	}

	QDataStream& operator>> (QDataStream& in, PocketEntry& entry)
	{
		qint8 version = 0;
		in >> version;
        if (version > 0)
			in >> entry.Id_
					>> entry.Title_
					>> entry.Url_
					>> entry.AddTime_
					>> entry.Favorite_
					>> entry.Read_;
        if (version == 2)
            in >> entry.Tags_;

		return in;
	}
}
