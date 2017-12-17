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

#pragma once

#include <QAbstractListModel>
#include "bookmark.h"

namespace LinksBag
{
class BookmarksModel : public QAbstractListModel
{
    Q_OBJECT

    Bookmarks_t m_Bookmarks;

public:
    enum BookmarkRoles
    {
        BRID = Qt::UserRole + 1,
        BRUrl,
        BRTitle,
        BRDescription,
        BRImageUrl,
        BRFavorite,
        BRRead,
        BRTags,
        BRAddTime,
        BRUpdateTime,
        BRStatus
    };

    explicit BookmarksModel(QObject *parent = 0);
    virtual ~BookmarksModel();

    virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const;
    virtual QHash<int, QByteArray> roleNames() const;

    void Clear();
    void AddBookmarks(const Bookmarks_t& bookmarks);
    void SetBookmarks(const Bookmarks_t& bookmarks);
    void RemoveBookmark(const QString& id);
    void MarkBookmarkAsFavorite(const QString& id, bool favorite);
    void MarkBookmarkAsRead(const QString& id, bool read);
    void UpdateTags(const QString& id, const QString& tags);

    Bookmarks_t GetBookmarks() const;

    Q_INVOKABLE QVariantMap getBookmark(const QString& id) const;
};
} // namespace LinksBag
