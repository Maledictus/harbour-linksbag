#pragma once

#include <QStandardItemModel>
#include "getpocketmanager.h"

namespace LinksBag
{
	class PocketEntriesModel : public QStandardItemModel
	{
		Q_OBJECT


		QMap<qint64, QStandardItem*> Id2Item_;

	public:
        enum Roles
        {
            Id = Qt::UserRole + 1,
            Title,
            Url,
            AddTime,
            Favorite,
            Read,
            Tags
        };

        explicit PocketEntriesModel (QObject *parent = 0);

        void RestoreItems ();

        bool IsRead (qint64 id) const;
        bool IsFavorite (qint64 id) const;
        QUrl GetUrl (qint64 id) const;
        QString GetTitle (qint64 id) const;

	private:
		void UpdateItem (const PocketEntry& entry);
		void SaveItems () const;

	public slots:
		void handleGotEntries (const QList<PocketEntry>& entries);
        void handleFavoriteStateChanged (qint64 id);
        void handleReadStateChanged (qint64 id);

	signals:
		void readStateChanged ();
	};
}
