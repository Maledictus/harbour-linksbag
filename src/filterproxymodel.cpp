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
    switch (m_StatusFilter)
    {
    case StatusRead:
        result = sourceModel()->data(index, BookmarksModel::BRRead).toBool();
        break;
    case StatusUnread:
        result = !sourceModel()->data(index, BookmarksModel::BRRead).toBool();
        break;
    case StatusFavorite:
        result = sourceModel()->data(index, BookmarksModel::BRFavorite).toBool();
        break;
    case StatusAll:
    default:
        result = true;
        break;
    }

    switch (m_ContentTypeFilter)
    {
    case ContentTypeArticles:
        result &= (sourceModel()->data(index, BookmarksModel::BRContentType).toInt() == Bookmark::CTArticle);
        break;
    case ContentTypeImages:
        result &= (sourceModel()->data(index, BookmarksModel::BRContentType).toInt() == Bookmark::CTImage);
        break;
    case ContentTypeVideos:
        result &= (sourceModel()->data(index, BookmarksModel::BRContentType).toInt() == Bookmark::CTVideo);
        break;
    case ContentTypeAll:
    default:
        result &= true;
        break;
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

void FilterProxyModel::filterBookmarks(int statusFilter,
        int contentTypeFilter)
{
    m_StatusFilter = static_cast<BookmarksStatusFilter>(statusFilter);
    m_ContentTypeFilter = static_cast<BookmarksContentTypeFilter>(contentTypeFilter);
    invalidateFilter();
}
} // namespace LinksBag
