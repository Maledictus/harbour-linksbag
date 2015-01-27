#pragma once

#include <QAbstractListModel>
#include "bookmark.h"

namespace LinksBag
{
    class BookmarksModel : public QAbstractListModel
    {
        Q_OBJECT

        Bookmarks_t Bookmarks_;

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
            BRIsArticle,
            BRIsImage,
            BRIsVideo
        };

        explicit BookmarksModel (QObject *parent = 0);
        virtual ~BookmarksModel ();

        virtual QVariant data (const QModelIndex& index, int role = Qt::DisplayRole) const;
        virtual int	rowCount (const QModelIndex& parent = QModelIndex ()) const;
        virtual QHash<int, QByteArray> roleNames () const;

        void Clear ();
        void AddBookmarks (const Bookmarks_t& bookmarks);
        void RemoveBookmark (const QString& id);
        void MarkBookmarkAsFavorite (const QString& id, bool favorite);
        void MarkBookmarkAsRead (const QString& id, bool read);

        Bookmarks_t GetBookmarks () const;
        Bookmark* GetBookmark (const QString& id) const;

    };
} // namespace LinksBag
