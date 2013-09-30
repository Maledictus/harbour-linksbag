#include "filtermodel.h"
#include <QTimer>
#include <QtDebug>
#include "pocketentriesmodel.h"

namespace LinksBag
{
    FilterModel::FilterModel (QObject *parent)
    : QSortFilterProxyModel (parent)
    , FilterType_ (All)
    {
        setDynamicSortFilter (true);
        setFilterCaseSensitivity (Qt::CaseInsensitive);
    }

    bool FilterModel::filterAcceptsRow (int sourceRow, const QModelIndex& sourceParent) const
    {
        const QModelIndex& index = sourceModel ()->index (sourceRow, 0, sourceParent);
        const auto& tags = sourceModel ()->data (index, PocketEntriesModel::Tags).toStringList ();
        const auto& title = sourceModel ()->data (index, PocketEntriesModel::Title).toString ();
        const bool archive = sourceModel ()->data (index, PocketEntriesModel::Read).toBool ();
        const bool favorite = sourceModel ()->data (index, PocketEntriesModel::Favorite).toBool ();
        switch (FilterType_)
        {
        case Archive:
            if (!archive)
                return false;
            break;
        case Favorite:
            if (!favorite)
                return false;
            break;
        default:
            break;
        };

        bool contains = title.contains (filterRegExp ());
        for (int i = 0, size = tags.count (); !contains && i < size; ++i)
        {
            const auto& tag = tags.at (i);
            if (tag.contains (filterRegExp ()))
            {
                contains = true;
                break;
            }
        }
        return contains;
    }

    QHash<int, QByteArray> FilterModel::roleNames () const
    {
        QHash<int, QByteArray> roleNames;
        roleNames [PocketEntriesModel::Id] = "entryId";
        roleNames [PocketEntriesModel::Title] = "entryTitle";
        roleNames [PocketEntriesModel::Url] = "entryUrl";
        roleNames [PocketEntriesModel::AddTime] = "entryAddTime";
        roleNames [PocketEntriesModel::Favorite] = "entryFavorite";
        roleNames [PocketEntriesModel::Read] = "entryRead";
        roleNames [PocketEntriesModel::Tags] = "entryTags";
        return roleNames;
    }

    bool FilterModel::IsRead (qint64 id) const
    {
        return static_cast<PocketEntriesModel*> (sourceModel ())->IsRead (id);
    }

    bool FilterModel::IsFavorite (qint64 id) const
    {
        return static_cast<PocketEntriesModel*> (sourceModel ())->IsFavorite (id);
    }

    QUrl FilterModel::GetUrl (qint64 id) const
    {
        return static_cast<PocketEntriesModel*> (sourceModel ())->GetUrl (id);
    }

    QString FilterModel::GetTitle (qint64 id) const
    {
        return static_cast<PocketEntriesModel*> (sourceModel ())->GetTitle (id);
    }

    void FilterModel::handleFavoriteStateChanged (qint64 id)
    {
        static_cast<PocketEntriesModel*> (sourceModel ())->handleFavoriteStateChanged (id);
        emit itemUpdated ();
    }

    void FilterModel::handleReadStateChanged (qint64 id)
    {
        static_cast<PocketEntriesModel*> (sourceModel ())->handleReadStateChanged (id);
        emit itemUpdated ();
    }

    void FilterModel::handleItemDeleted (qint64 id)
    {
        static_cast<PocketEntriesModel*> (sourceModel ())->handleItemDeleted (id);
    }

    void FilterModel::handleSearchTextChanged (const QString& text)
    {
        setFilterFixedString (text);
    }

    void FilterModel::filter (int type)
    {
        FilterType_ = static_cast<FilterType> (type);
        QTimer::singleShot (0,
                this,
                SLOT (invalidateFilterSlot ()));
    }

    void FilterModel::invalidateFilterSlot ()
    {
        invalidateFilter ();
    }
}
