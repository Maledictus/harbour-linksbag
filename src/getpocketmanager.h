#pragma once

#include <QObject>
#include <QDateTime>
#include <QStringList>
#include <QUrl>

class QNetworkAccessManager;
class QNetworkReply;

namespace LinksBag
{
	struct PocketEntry
	{
		qint64 Id_;
		QString Title_;
		QUrl Url_;
		QDateTime AddTime_;
		bool Favorite_;
		bool Read_;
        QStringList Tags_;

		PocketEntry ()
		: Id_ (-1)
		, Favorite_ (false)
		, Read_ (false)
		{}

		bool IsEmpty () const
		{
			return Id_ < 0 || Url_.isEmpty ();
		}
	};

	class GetPocketManager : public QObject
	{
		Q_OBJECT

		Q_PROPERTY (bool authorized
				READ IsAuthorized
				NOTIFY authorizeStateChanged)
		Q_PROPERTY (QString login
				READ GetLogin
				NOTIFY loginChanged)

		const QString ConsumerKey_;
		QString RequestToken_;
		QString AccessToken_;
		QString Login_;
		QNetworkAccessManager *NetworkManager_;
		bool Authorized_;
        QHash<QNetworkReply*, qint64> Reply2FavoriteId_;
        QHash<QNetworkReply*, qint64> Reply2ReadId_;
        QHash<QNetworkReply*, qint64> Reply2DeleteItemId_;

	public:
		explicit GetPocketManager (QObject *parent = 0);

		bool IsAuthorized () const;
		QString GetLogin () const;

	public slots:
		void authorize ();

		void refresh ();
		void setRead (qint64 id, bool read);
		void setFavorite (qint64 id, bool favorite);
        void deleteItem (qint64 id);

	private slots:
		void requestAccessToken ();
		void obtainRequestTokenFinished ();
		void obtainAccessTokenFinished ();

		void handleGotItems ();
		void handleSetReadFinished ();
		void handleSetFavoriteFinished ();
        void handleDeleteItemFinished ();

	signals:
		void authorizeStateChanged ();
		void loginChanged ();

        void gotEntries (const QList<PocketEntry>& entries);
        void favoriteStateChanged (qint64 id);
        void readStateChanged (qint64 id);
        void itemDeleted (qint64 id);
	};

	QDataStream& operator<< (QDataStream& out, const PocketEntry& entry);
	QDataStream& operator>> (QDataStream& in, PocketEntry& entry);
}
