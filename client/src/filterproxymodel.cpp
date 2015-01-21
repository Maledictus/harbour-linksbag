#include "filterproxymodel.h"
#include "bookmarksmodel.h"

namespace LinksBag
{
    FilterProxyModel::FilterProxyModel (QObject *parent)
    : QSortFilterProxyModel (parent)
    {
        setDynamicSortFilter (true);
        setSortCaseSensitivity (Qt::CaseInsensitive);
        setFilterCaseSensitivity (Qt::CaseInsensitive);
    }

    void FilterProxyModel::SetFilter(const QString& filter)
    {
        if (Filter_ == filter)
            return;

        Filter_ = filter;
        invalidateFilter ();
    }

    bool FilterProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex& sourceParent) const
    {
        QModelIndex index = sourceModel ()->index (sourceRow, 0, sourceParent);

        bool result = false;
        if (Filter_ == "all")
            result = true;
        else if (Filter_ == "read")
            result = sourceModel ()->data (index, BookmarksModel::BRRead).toBool ();
        else if (Filter_ == "unread")
            result = !sourceModel ()->data (index, BookmarksModel::BRRead).toBool ();
        else if (Filter_ == "favorite")
            result = sourceModel ()->data (index, BookmarksModel::BRFavorite).toBool ();

        return result && (index.data (BookmarksModel::BRTitle).toString ().contains (filterRegExp ()) ||
                index.data (BookmarksModel::BRDescription).toString ().contains (filterRegExp ()) ||
                index.data (BookmarksModel::BRUrl).toString ().contains (filterRegExp ()) ||
                index.data (BookmarksModel::BRTags).toString ().contains (filterRegExp ())) ;
    }

    bool FilterProxyModel::lessThan (const QModelIndex& left, const QModelIndex& right) const
    {
        QVariant leftData = sourceModel ()->data (left, BookmarksModel::BRAddTime);
        QVariant rightData = sourceModel ()->data (right, BookmarksModel::BRAddTime);

        return leftData.toDateTime () < rightData.toDateTime ();
    }
} // namespace LinksBag
