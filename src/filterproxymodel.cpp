/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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

#include "filterproxymodel.h"
#include "bookmarksmodel.h"


namespace LinksBag
{
FilterProxyModel::FilterProxyModel(QObject *parent)
: QSortFilterProxyModel(parent)
{
    setDynamicSortFilter(true);
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

bool FilterProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const
{
    QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);

    bool result = false;
    if (m_Filter == FTAll)
    {
        result = true;
    }
    else if (m_Filter == FTRead)
    {
        result = sourceModel()->data(index, BookmarksModel::BRRead).toBool();
    }
    else if (m_Filter == FTUnread)
    {
        result = !sourceModel()->data(index, BookmarksModel::BRRead).toBool();
    }
    else if (m_Filter == FTFavorite)
    {
        result = sourceModel()->data(index, BookmarksModel::BRFavorite).toBool();
    }
    else if (m_Filter == FTUnsynced)
    {
        result = !sourceModel()->data(index, BookmarksModel::BRRead).toBool() &&
                !sourceModel()->data(index, BookmarksModel::BRHasContent).toBool();
    }

    return result && (index.data(BookmarksModel::BRTitle).toString().contains(filterRegExp()) ||
            index.data(BookmarksModel::BRDescription).toString().contains(filterRegExp()) ||
            index.data(BookmarksModel::BRUrl).toString().contains(filterRegExp()) ||
            index.data(BookmarksModel::BRTags).toString().contains(filterRegExp())) ;
}

bool FilterProxyModel::lessThan(const QModelIndex& left, const QModelIndex& right) const
{
    QVariant leftData = sourceModel()->data(left, BookmarksModel::BRAddTime);
    QVariant rightData = sourceModel()->data(right, BookmarksModel::BRAddTime);

    return leftData.toDateTime() < rightData.toDateTime();
}

void FilterProxyModel::filterBookmarks(int type)
{
    FilterType filter;
    if (type < 0 || type > FTUnsynced)
    {
        filter = FTAll;
    }
    else
    {
        filter = static_cast<FilterType>(type);
    }

    if (m_Filter != filter)
    {
        m_Filter = filter;
        invalidateFilter();
    }
}
} // namespace LinksBag
