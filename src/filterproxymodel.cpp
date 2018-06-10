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

#include <QtDebug>

namespace LinksBag
{
FilterProxyModel::FilterProxyModel(BookmarksModel *bookmarksModel, QObject *parent)
: QSortFilterProxyModel(parent)
, m_BookmarksModel(bookmarksModel)
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
    const QVariant leftData = sourceModel()->data(left, BookmarksModel::BRAddTime);
    const QVariant rightData = sourceModel()->data(right, BookmarksModel::BRAddTime);
    const QVariant leftTitle = sourceModel()->data(left, BookmarksModel::BRTitle);
    const QVariant rightTitle = sourceModel()->data(right, BookmarksModel::BRTitle);

    if (leftData.toDateTime() < rightData.toDateTime()) {
        return true;
    }
    else if (leftData.toDateTime() == rightData.toDateTime()) {
        return QString::localeAwareCompare(leftTitle.toString(), rightTitle.toString()) < 0;
    }
    else {
        return false;
    }
}

bool FilterProxyModel::IsUnreadBookmarksSelected() const
{
    return !m_UnreadSelectedBookmarksIds.isEmpty();
}

bool FilterProxyModel::IsUnfavoriteBookmarksSelected() const
{
    return !m_UnfavoriteSelectedBookmarksIds.isEmpty();
}

QStringList FilterProxyModel::selectedBookmarks() const
{
    return m_BookmarksModel->GetSelectedBookmarks();
}

void FilterProxyModel::filterBookmarks(int statusFilter,
        int contentTypeFilter)
{
    m_StatusFilter = static_cast<BookmarksStatusFilter>(statusFilter);
    m_ContentTypeFilter = static_cast<BookmarksContentTypeFilter>(contentTypeFilter);
    invalidateFilter();
}

void FilterProxyModel::selectBookmark(int row)
{
    const auto srcIdx = mapToSource(index(row, 0));
    m_BookmarksModel->SelectBookmark(srcIdx);
    const bool isRead = sourceModel()->data(srcIdx, BookmarksModel::BRRead).toBool();
    const bool isFavorite = sourceModel()->data(srcIdx, BookmarksModel::BRFavorite).toBool();

    if (m_UnreadSelectedBookmarksIds.isEmpty() && !isRead) {
        m_UnreadSelectedBookmarksIds.append(row);
        emit unreadBookmarksSelectedChanged();
    }
    else if (!isRead) {
        m_UnreadSelectedBookmarksIds.append(row);
    }

    if (m_UnfavoriteSelectedBookmarksIds.isEmpty() && !isFavorite) {
        m_UnfavoriteSelectedBookmarksIds.append(row);
        emit unfavoriteBookmarksSelectedChanged();
    }
    else if (!isFavorite) {
        m_UnfavoriteSelectedBookmarksIds.append(row);
    }
}

void FilterProxyModel::deselectBookmark(int row)
{
    const auto srcIdx = mapToSource(index(row, 0));
    m_BookmarksModel->DeselectBookmark(srcIdx);

    if (m_UnreadSelectedBookmarksIds.contains(row)) {
        m_UnreadSelectedBookmarksIds.removeOne(row);
        if (m_UnreadSelectedBookmarksIds.isEmpty()) {
            emit unreadBookmarksSelectedChanged();
        }
    }

    if (m_UnfavoriteSelectedBookmarksIds.contains(row)) {
        m_UnfavoriteSelectedBookmarksIds.removeOne(row);
        if (m_UnfavoriteSelectedBookmarksIds.isEmpty()) {
            emit unfavoriteBookmarksSelectedChanged();
        }
    }
}

void FilterProxyModel::selectAllBookmarks()
{
    //TODO
}

void FilterProxyModel::deselectAllBookmarks()
{
    m_BookmarksModel->DeselectAllBookmarks();
    m_UnreadSelectedBookmarksIds.clear();
    emit unreadBookmarksSelectedChanged();
    m_UnfavoriteSelectedBookmarksIds.clear();
    emit unfavoriteBookmarksSelectedChanged();
}
} // namespace LinksBag
