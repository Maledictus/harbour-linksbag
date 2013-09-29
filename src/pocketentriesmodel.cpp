#include "pocketentriesmodel.h"
#include <QSettings>
#include <QtDebug>

namespace LinksBag
{
	PocketEntriesModel::PocketEntriesModel (QObject *parent)
	: QStandardItemModel (parent)
    {
    }

    void PocketEntriesModel::UpdateItem (const PocketEntry& entry)
	{
		auto item = Id2Item_ [entry.Id_];
		item->setData (entry.Id_, Id);
		item->setData (entry.Title_, Title);
		item->setData (entry.Url_, Url);
		item->setData (entry.AddTime_, AddTime);
		item->setData (entry.Favorite_, Favorite);
		item->setData (entry.Read_, Read);
	}

	void PocketEntriesModel::SaveItems () const
	{
		QList<PocketEntry> entries;
		for (auto item : Id2Item_.values ())
		{
			PocketEntry entry;
			entry.Id_ = item->data (Id).toLongLong ();
			entry.Title_ = item->data (Title).toString ();
			entry.Url_ = item->data (Url).toUrl ();
			entry.AddTime_ = item->data (AddTime).toDateTime ();
			entry.Favorite_ = item->data (Favorite).toBool ();
			entry.Read_ = item->data (Read).toBool ();
            entry.Tags_ = item->data (Tags).toStringList ();

			entries << entry;
		}

		quint8 version = 1;
		QByteArray result;
		{
			QDataStream ostr (&result, QIODevice::WriteOnly);
			ostr << version
					<< entries;
		}

		QSettings settings;
		settings.setValue ("Entries", result);
	}

	void PocketEntriesModel::RestoreItems ()
	{
		QSettings settings;
		QByteArray data = settings.value ("Entries").toByteArray ();
		quint8 version = 0;
		QDataStream in (data);
		in >> version;

		if (version != 1)
		{
			qWarning () << Q_FUNC_INFO
					<< "unknown version"
					<< version;
			return;
		}

		QList<PocketEntry> entries;
        in >> entries;

		handleGotEntries (entries);
	}

	bool PocketEntriesModel::IsRead (qint64 id) const
	{
        return Id2Item_.contains (id) ?
			Id2Item_ [id]->data (Read).toBool () :
			false;
	}

	bool PocketEntriesModel::IsFavorite (qint64 id) const
	{
		return Id2Item_.contains (id) ?
			Id2Item_ [id]->data (Favorite).toBool () :
			false;
	}

	QUrl PocketEntriesModel::GetUrl (qint64 id) const
	{
		return Id2Item_.contains (id) ?
			Id2Item_ [id]->data (Url).toUrl () :
			QUrl ();
	}

	QString PocketEntriesModel::GetTitle (qint64 id) const
	{
		return Id2Item_.contains (id) ?
			Id2Item_ [id]->data (Title).toString () :
                    QString ();
    }

	void PocketEntriesModel::handleGotEntries (const QList<PocketEntry>& entries)
	{
		auto entriesList = entries;
		std::sort (entriesList.begin (), entriesList.end (),
				[] (const PocketEntry& entry1, const PocketEntry& entry2)
				{
					return entry1.AddTime_ > entry2.AddTime_;
				});
		for (const auto& entry : entriesList)
		{
			if (Id2Item_.contains (entry.Id_))
				UpdateItem (entry);
			else
			{
				QStandardItem *item = new QStandardItem;
                item->setData (entry.Id_,PocketEntriesModel::Id);
                item->setData (entry.Title_,PocketEntriesModel::Title);
                item->setData (entry.Url_, PocketEntriesModel::Url);
                item->setData (entry.AddTime_, PocketEntriesModel::AddTime);
                item->setData (entry.Favorite_, PocketEntriesModel::Favorite);
                item->setData (entry.Read_, PocketEntriesModel::Read);
                item->setData (entry.Tags_.join (','), PocketEntriesModel::Tags);

				Id2Item_ [entry.Id_] = item;
				appendRow (item);
			}
		}

        SaveItems ();
    }

    void PocketEntriesModel::handleFavoriteStateChanged (qint64 id)
    {
        if (!Id2Item_.contains (id))
            return;

        bool favorite = Id2Item_ [id]->data (Favorite).toBool ();
        Id2Item_ [id]->setData (!favorite, Favorite);
    }

    void PocketEntriesModel::handleReadStateChanged (qint64 id)
    {
        if (!Id2Item_.contains (id))
            return;
        bool read = Id2Item_ [id]->data (Read).toBool ();
        Id2Item_ [id]->setData (!read, Read);
    }

    void PocketEntriesModel::handleItemDeleted (qint64 id)
    {
        if (!Id2Item_.contains (id))
            return;
        auto item = Id2Item_.take (id);
        removeRow (item->index ().row (), QModelIndex ());
    }
}
