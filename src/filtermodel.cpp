#include "filtermodel.h"
#include "pocketentriesmodel.h"

namespace LinksBag
{
    FilterModel::FilterModel (QObject *parent)
    : QSortFilterProxyModel (parent)
    {
        setDynamicSortFilter (true);
        setFilterCaseSensitivity (Qt::CaseInsensitive);
    }

    bool FilterModel::filterAcceptsRow (int sourceRow, const QModelIndex& sourceParent) const
    {
        const QModelIndex& index = sourceModel ()->index (sourceRow, 0, sourceParent);
        return sourceModel ()->data (index, PocketEntriesModel::Title).toString ().contains (filterRegExp ());
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
    }

    void FilterModel::handleReadStateChanged (qint64 id)
    {
        static_cast<PocketEntriesModel*> (sourceModel ())->handleReadStateChanged (id);
    }

    void FilterModel::handleItemDeleted (qint64 id)
    {
        static_cast<PocketEntriesModel*> (sourceModel ())->handleItemDeleted (id);
    }

    void FilterModel::handleSearchTextChanged (const QString& text)
    {
        setFilterFixedString (text);
    }
}
