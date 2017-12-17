/*
The MIT License (MIT)

Copyright (c) 2014-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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

#include "bookmarksmodel.h"
#include <QtDebug>

namespace LinksBag
{
BookmarksModel::BookmarksModel(QObject *parent)
: QAbstractListModel(parent)
{
}

BookmarksModel::~BookmarksModel()
{
}

QVariant BookmarksModel::data(const QModelIndex& index, int role) const
{
    if(index.row() < 0 || index.row() > m_Bookmarks.count())
    {
        return QVariant();
    }

    auto bookmark = m_Bookmarks.at(index.row());
    switch(role)
    {
    case BRID:
        return bookmark.GetID();
    case BRUrl:
        return bookmark.GetUrl();
    case BRTitle:
        return bookmark.GetTitle();
    case BRDescription:
        return bookmark.GetDescription();
    case BRImageUrl:
        return bookmark.GetImageUrl();
    case BRFavorite:
        return bookmark.IsFavorite();
    case BRRead:
        return bookmark.IsRead();
    case BRTags:
        return bookmark.GetTags().join(',');
    case BRAddTime:
        return bookmark.GetAddTime();
    case BRUpdateTime:
        return bookmark.GetUpdateTime();
    case BRStatus:
        return bookmark.GetStatus();
    default:
        return QVariant();
    }
}

int BookmarksModel::rowCount(const QModelIndex&) const
{
    return m_Bookmarks.count();
}

QHash<int, QByteArray> BookmarksModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles [BRID] = "bookmarkID";
    roles [BRUrl] = "bookmarkUrl";
    roles [BRTitle] = "bookmarkTitle";
    roles [BRDescription] = "bookmarkDescription";
    roles [BRImageUrl] = "bookmarkImageUrl";
    roles [BRFavorite] = "bookmarkFavorite";
    roles [BRRead] = "bookmarkRead";
    roles [BRTags] = "bookmarkTags";
    roles [BRAddTime] = "bookmarkAddTime";
    roles [BRUpdateTime] = "bookmarkUpdateTime";
    roles [BRStatus] = "bookmarkStatus";

    return roles;
}

void BookmarksModel::Clear()
{
    m_Bookmarks.clear();
}

void BookmarksModel::RemoveBookmark(const QString& id)
{
    auto it = std::find_if(m_Bookmarks.begin(), m_Bookmarks.end(),
            [id](decltype(m_Bookmarks.front()) bookmark)
            {
                return id == bookmark.GetID();
            });
    if(it != m_Bookmarks.end())
    {
        const int pos = std::distance(m_Bookmarks.begin(), it);
        beginRemoveRows(QModelIndex(), pos, pos);
        m_Bookmarks.removeAt(pos);
        endRemoveRows();
    }
}

void BookmarksModel::AddBookmarks(const Bookmarks_t& bookmarks)
{
    Bookmarks_t bmss = bookmarks;
    for(int i = bmss.count() - 1; i >= 0; --i)
    {
        auto bms = bmss.at(i);
        auto it = std::find_if(m_Bookmarks.begin(), m_Bookmarks.end(),
                [bms](decltype(m_Bookmarks.front()) bookmark)
                {
                    return bms.GetID() == bookmark.GetID();
                });
        if (it != m_Bookmarks.end())
        {
            const int pos = std::distance(m_Bookmarks.begin(), it);
            switch(bms.GetStatus())
            {
            case Bookmark::SDeleted:
                RemoveBookmark(bms.GetID());
                break;
            case Bookmark::SArchived:
            {
                Bookmark bm = m_Bookmarks[pos];
                bm.SetIsRead(true);

                emit dataChanged(index(pos), index(pos));
                break;
            }
            default:
            {
                Bookmark bm = m_Bookmarks[pos];
                bm.SetUrl(bms.GetUrl());
                bm.SetTitle(bms.GetTitle());
                bm.SetDescription(bms.GetDescription());
                bm.SetIsFavorite(bms.IsFavorite());
                bm.SetIsRead(bms.IsRead());
                bm.SetAddTime(bms.GetAddTime());
                bm.SetUpdateTime(bms.GetUpdateTime());
                bm.SetTags(bms.GetTags());
                bm.SetImageUrl(bms.GetImageUrl());
                bm.SetStatus(bms.GetStatus());

                emit dataChanged(index(pos), index(pos));
                break;
            }
            }
        }
        else {
            beginInsertRows(QModelIndex(), rowCount(), rowCount());
            m_Bookmarks.append(bms);
            endInsertRows();
        }
    }
}

void BookmarksModel::SetBookmarks(const Bookmarks_t& bookmarks)
{
    beginResetModel();
    m_Bookmarks = bookmarks;
    endResetModel();
}

void BookmarksModel::MarkBookmarkAsFavorite(const QString& id, bool favorite)
{
    for(int i = 0, size = m_Bookmarks.count(); i < size; ++i)
    {
        auto& bm = m_Bookmarks[i];
        if(bm.GetID() == id)
        {
            bm.SetIsFavorite(favorite);
            emit dataChanged(index(i, 0), index(i, 0));
            break;
        }
    }
}

void BookmarksModel::MarkBookmarkAsRead(const QString& id, bool read)
{
    for(int i = 0, size = m_Bookmarks.count(); i < size; ++i)
    {
        auto& bm = m_Bookmarks[i];
        if(bm.GetID() == id)
        {
            bm.SetIsRead(read);
            emit dataChanged(index(i, 0), index(i, 0));
            break;
        }
    }
}

void BookmarksModel::UpdateTags(const QString& id, const QString& tags)
{
    for(int i = 0, size = m_Bookmarks.count(); i < size; ++i)
    {
        auto& bm = m_Bookmarks[i];
        if(bm.GetID() == id)
        {
            bm.SetTags(tags.split(',', QString::SkipEmptyParts));
            emit dataChanged(index(i, 0), index(i, 0));
            break;
        }
    }
}

Bookmarks_t BookmarksModel::GetBookmarks() const
{
    return m_Bookmarks;
}

QVariantMap BookmarksModel::getBookmark(const QString& id) const
{
    auto it = std::find_if(m_Bookmarks.begin(), m_Bookmarks.end(),
            [id](decltype(m_Bookmarks.front()) bookmark)
            {
                return bookmark.GetID() == id;
            });
    if(it == m_Bookmarks.end())
    {
        return QVariantMap();
    }

    return it->ToMap();
}
} // namespace LinksBag
