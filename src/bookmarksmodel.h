/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

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

#include <memory>

#include <QAbstractListModel>
#include <QMap>

#include "bookmark.h"

namespace LinksBag
{
class BookmarksModel : public QAbstractListModel
{
    Q_OBJECT

    Bookmarks_t m_Bookmarks;
    QMap<int, QString> m_SelectedBookmarksIds;

    Q_PROPERTY(int count READ GetCount NOTIFY countChanged)

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
        BRStatus,
        BRThumbnail,
        BRCoverImage,
        BRHasContent,
        BRImages,
        BRVideos,
        BRContentType,
        BRBookmark,
        BRSelected
    };

    explicit BookmarksModel(QObject *parent = 0);
    virtual ~BookmarksModel();

    int GetCount() const;

    virtual QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const;
    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const;
    virtual QHash<int, QByteArray> roleNames() const;

    void Clear();
    void AddBookmarks(const Bookmarks_t& bookmarks);
    void SetBookmarks(const Bookmarks_t& bookmarks);
    void RemoveBookmarks(const QStringList& ids);
    void MarkBookmarksAsFavorite(const QStringList& ids, bool favorite);
    void MarkBookmarksAsRead(const QStringList& ids, bool read);
    void UpdateTags(const QString& id, const QString& tags);
    void UpdatePublishDate(const QString& id, const QString& date);

    void RefreshBookmark(const QString& id);

    Bookmarks_t GetBookmarks() const;

    void SelectBookmark(const QModelIndex& index);
    void DeselectBookmark(const QModelIndex& index);
    void SelectAllBookmarks();
    void DeselectAllBookmarks();
    QStringList GetSelectedBookmarks() const;

public slots:
    void handleArticlesCacheReset();

signals:
    void countChanged();
};
} // namespace LinksBag
