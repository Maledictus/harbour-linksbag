#include "bookmarksmodel.h"
#include <QtDebug>

namespace LinksBag
{
    BookmarksModel::BookmarksModel (QObject *parent)
    : QAbstractListModel (parent)
    {
    }

    BookmarksModel::~BookmarksModel ()
    {
        Clear ();
    }

    QVariant BookmarksModel::data (const QModelIndex& index, int role) const
    {
        if (index.row () < 0 || index.row () > Bookmarks_.count ())
            return QVariant ();

        auto bookmark = Bookmarks_.at (index.row ());

        switch (role)
        {
        case BRID:
            return bookmark->GetID ();
        case BRUrl:
            return bookmark->GetUrl ();
        case BRTitle:
            return bookmark->GetTitle ();
        case BRDescription:
            return bookmark->GetDescription ();
        case BRImageUrl:
            return bookmark->GetImageUrl ();
        case BRFavorite:
            return bookmark->IsFavorite ();
        case BRRead:
            return bookmark->IsRead ();
        case BRTags:
            return bookmark->GetTags ().join (',');
        case BRAddTime:
            return bookmark->GetAddTime ();
        case BRUpdateTime:
            return bookmark->GetUpdateTime ();
        case BRStatus:
            return bookmark->GetStatus ();
        case BRIsArticle:
            return bookmark->IsArticle ();
        case BRIsImage:
            return bookmark->IsImage ();
        case BRIsVideo:
            return bookmark->IsVideo ();
        default:
            return QVariant ();
        }
    }

    int BookmarksModel::rowCount (const QModelIndex&) const
    {
        return Bookmarks_.count ();
    }

    QHash<int, QByteArray> BookmarksModel::roleNames () const
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
        roles [BRIsArticle] = "bookmarkIsArticle";
        roles [BRIsImage] = "bookmarkIsImage";
        roles [BRIsVideo] = "bookmarkIsVideo";

        return roles;
    }

    void BookmarksModel::Clear ()
    {
        qDeleteAll (Bookmarks_);
        Bookmarks_.clear ();
    }

    void BookmarksModel::RemoveBookmark (const QString& id)
    {
        auto it = std::find_if (Bookmarks_.begin (), Bookmarks_.end (),
                [id] (decltype (Bookmarks_.front ()) bookmark)
                {
                    return id == bookmark->GetID ();
                });
        if (it != Bookmarks_.end ())
        {
            const int pos = std::distance (Bookmarks_.begin (), it);
            beginRemoveRows (QModelIndex (), pos, pos);
            Bookmarks_.removeAt (pos);
            endRemoveRows ();
        }
    }

    void BookmarksModel::AddBookmarks (const Bookmarks_t& bookmarks)
    {
        Bookmarks_t bmss = bookmarks;
        for (int i = bmss.count () - 1; i >= 0; --i)
        {
            auto bms = bmss.at (i);
            auto it = std::find_if (Bookmarks_.begin (), Bookmarks_.end (),
                    [bms] (decltype (Bookmarks_.front ()) bookmark)
                    {
                        return bms->GetID () == bookmark->GetID ();
                    });
            if (it != Bookmarks_.end ())
            {
                const int pos = std::distance (Bookmarks_.begin (), it);
                switch (bms->GetStatus ())
                {
                case Bookmark::SDeleted:
                    RemoveBookmark (bms->GetID ());
                    break;
                case Bookmark::SArchived:
                {
                    Bookmark *bm = Bookmarks_ [pos];
                    bm->SetUrl (bms->GetUrl ());
                    bm->SetTitle (bms->GetTitle ());
                    bm->SetDescription (bms->GetDescription ());
                    bm->SetIsFavorite (bms->IsFavorite ());
                    bm->SetIsRead (true);
                    bm->SetAddTime (bms->GetAddTime ());
                    bm->SetUpdateTime (bms->GetUpdateTime ());
                    bm->SetTags (bms->GetTags ());
                    bm->SetImageUrl (bms->GetImageUrl ());
                    bm->SetStatus (bms->GetStatus ());
                    bm->SetIsArticle (bms->IsArticle ());
                    bm->SetIsImage (bms->IsImage ());
                    bm->SetIsVideo (bms->IsVideo ());

                    emit dataChanged (index (pos), index (pos));

                    break;
                }
                default:
                {
                    Bookmark *bm = Bookmarks_ [pos];
                    bm->SetUrl (bms->GetUrl ());
                    bm->SetTitle (bms->GetTitle ());
                    bm->SetDescription (bms->GetDescription ());
                    bm->SetIsFavorite (bms->IsFavorite ());
                    bm->SetIsRead (bms->IsRead ());
                    bm->SetAddTime (bms->GetAddTime ());
                    bm->SetUpdateTime (bms->GetUpdateTime ());
                    bm->SetTags (bms->GetTags ());
                    bm->SetImageUrl (bms->GetImageUrl ());
                    bm->SetStatus (bms->GetStatus ());
                    bm->SetIsArticle (bms->IsArticle ());
                    bm->SetIsImage (bms->IsImage ());
                    bm->SetIsVideo (bms->IsVideo ());

                    emit dataChanged (index (pos), index (pos));

                    break;
                }
                }

                bmss.takeAt (i)->deleteLater ();
            }
        }

        beginInsertRows (QModelIndex (), rowCount (),
                rowCount () + bmss.count () - 1);
        Bookmarks_.append (bmss);
        endInsertRows ();
    }

    void BookmarksModel::MarkBookmarkAsFavorite (const QString& id, bool favorite)
    {
        for (int i = 0, size = Bookmarks_.count (); i < size; ++i)
        {
            const auto& bm = Bookmarks_ [i];
            if (bm->GetID () == id)
            {
                bm->SetIsFavorite (favorite);
                emit dataChanged (index (i, 0), index (i, 0));
                break;
            }
        }
    }

    void BookmarksModel::MarkBookmarkAsRead (const QString& id, bool read)
    {
        for (int i = 0, size = Bookmarks_.count (); i < size; ++i)
        {
            const auto& bm = Bookmarks_ [i];
            if (bm->GetID () == id)
            {
                bm->SetIsRead (read);
                emit dataChanged (index (i, 0), index (i, 0));
                break;
            }
        }
    }

    Bookmarks_t BookmarksModel::GetBookmarks () const
    {
        return Bookmarks_;
    }

    Bookmark* BookmarksModel::GetBookmark (const QString& id) const
    {
        auto it = std::find_if (Bookmarks_.begin (), Bookmarks_.end (),
                [id] (decltype (Bookmarks_.front()) bookmark)
                {
                    return bookmark->GetID () == id;
                });
        if (it == Bookmarks_.end ())
            return 0;

        return *it;
    }
} // namespace LinksBag
