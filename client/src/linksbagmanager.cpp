#include "linksbagmanager.h"
#include <QSettings>
#include <QStandardPaths>
#include "bookmarksmodel.h"
#include "filterproxymodel.h"
#include "getpocketapi.h"

namespace LinksBag
{
    LinksBagManager::LinksBagManager (QObject *parent)
    : QObject (parent)
    , Api_ (new GetPocketApi (this))
    , Authorized_ (false)
    , BookmarksModel_ (new BookmarksModel (this))
    , FilterProxyModel_ (new FilterProxyModel (this))
    {
        FilterProxyModel_->setSourceModel (BookmarksModel_);

        connect (Api_,
                &GetPocketApi::requestTokenChanged,
                this,
                &LinksBagManager::requestTokenChanged);

        connect (Api_,
                &GetPocketApi::applicationAuthorized,
                this,
                [this] ()
                {
                    const auto& token = Api_->GetAccessToken ();
                    UserName_ = Api_->GetUserName ();

                    QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) + "/harbour-linksbag/harbour-linksbag.conf",
                            QSettings::NativeFormat);
                    settings.setValue ("username", UserName_);
                    settings.setValue ("access_token", token.toUtf8 ().toHex ().toBase64 ());

                    Authorized_ = true;

                    emit authorizationChanged ();
        });

        connect (Api_,
                &GetPocketApi::gotBookmarks,
                this,
                [this] (const Bookmarks_t& bookmarks, quint64 since)
                {
                    BookmarksModel_->AddBookmarks (bookmarks);
                    FilterProxyModel_->sort (0, Qt::DescendingOrder);

                    QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                            "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
                    settings.setValue ("lastUpdate", since);
                    settings.sync ();

                    SaveBookmarks ();

                    emit requestFinished ();
                    emit notify (NTInfo, tr ("Bookmarks updated"));
                });

        connect (Api_,
                &GetPocketApi::bookmarkRemoved,
                this,
                [this] (const QString& id)
                {
                   BookmarksModel_->RemoveBookmark (id);
                   SaveBookmarks ();
                   emit requestFinished ();
                   emit notify (NTInfo, tr ("Bookmark removed"));
                });

        connect (Api_,
                &GetPocketApi::bookmarkMarkedAsFavorite,
                [this] (const QString& id, bool favorite)
                {
                    BookmarksModel_->MarkBookmarkAsFavorite (id, favorite);
                    SaveBookmarks ();
                    emit requestFinished ();
                    emit notify (NTInfo, tr ("Bookmark marked as favorite"));
                });

        connect (Api_,
                &GetPocketApi::bookmarkMarkedAsRead,
                [this] (const QString& id, bool read)
                {
                    BookmarksModel_->MarkBookmarkAsRead (id, read);
                    SaveBookmarks ();
                    emit requestFinished ();
                    emit notify (NTInfo, tr ("Bookmark marked as read"));
                });

        connect (Api_,
                &GetPocketApi::error,
                this,
                [this] (const QString& msg)
                {
                    emit notify (NTError, msg);
                    emit requestFinished ();
                });

        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        Authorized_ = !settings.value ("username").isNull () &&
                !settings.value ("access_token").isNull ();
        emit authorizationChanged ();
        setFilter (settings.value ("filter", "all").toString ());
        emit filterChanged ();
    }

    void LinksBagManager::SetSearchFieldVisibility (bool visible)
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        settings.setValue ("search_field_visibility", visible);
        settings.sync ();
        emit searchFieldVisibilityChanged ();
    }

    bool LinksBagManager::GetSearchFieldVisibility () const
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        return settings.value ("search_field_visibility", true).toBool ();
    }
    
    QObject* LinksBagManager::GetBookmark (const QString& id) const
    {
        return BookmarksModel_->GetBookmark (id);
    }

    QString LinksBagManager::GetFilter () const
    {
        return Filter_.isEmpty () ? "all" : Filter_;
    }

    void LinksBagManager::SaveBookmarks ()
    {
        const auto& bookmarks = BookmarksModel_->GetBookmarks ();
        if (bookmarks.isEmpty ())
            return;

        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::DataLocation) +
                "/bookmarks", QSettings::NativeFormat);
        settings.beginWriteArray ("Bookmarks");
        for (int i = 0, size = bookmarks.size (); i < size; ++i)
        {
            settings.setArrayIndex (i);
            settings.setValue ("SerializedData",
                    bookmarks.at (i)->Serialize ());
        }
        settings.endArray ();
        settings.sync ();
    }

    void LinksBagManager::LoadBookmarksFromStorage ()
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::DataLocation) +
                "/bookmarks", QSettings::NativeFormat);
        int size = settings.beginReadArray ("Bookmarks");
        Bookmarks_t bookmarks;
        for (int i = 0; i < size; ++i)
        {
            settings.setArrayIndex (i);
            QByteArray data = settings.value ("SerializedData").toByteArray ();
            Bookmark *bm = Bookmark::Deserialize (data, 0);
            if (!bm)
            {
                qWarning () << Q_FUNC_INFO
                        << "unserializable entry"
                        << i;
                continue;
            }
            bookmarks << bm;
        }
        settings.endArray ();

        BookmarksModel_->Clear ();
        BookmarksModel_->AddBookmarks (bookmarks);
        FilterProxyModel_->sort (0, Qt::DescendingOrder);
    }

    QObject* LinksBagManager::GetBookmarksModel () const
    {
        return FilterProxyModel_;
    }

    bool LinksBagManager::IsAuthorized () const
    {
        return Authorized_;
    }

    QString LinksBagManager::GetRequestToken () const
    {
        return Api_->GetRequestToken ();
    }

    void LinksBagManager::obtainRequestToken ()
    {
        Api_->ObtainRequestToken ();
    }

    void LinksBagManager::requestAccessToken ()
    {
        Api_->RequestAccessToken ();
    }

    void LinksBagManager::filterBookmarks (const QString &text)
    {
        FilterProxyModel_->setFilterRegExp (text);
    }

    void LinksBagManager::setFilter (const QString& filter)
    {
        Filter_ = filter;
        FilterProxyModel_->SetFilter (Filter_);
        FilterProxyModel_->sort (0, Qt::DescendingOrder);
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        settings.setValue ("filter", Filter_);
        settings.sync ();
    }

    void LinksBagManager::loadBookmarks ()
    {
        LoadBookmarksFromStorage ();
        emit requestFinished ();
    }

    void LinksBagManager::refreshBookmarks ()
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) +
                "/harbour-linksbag/harbour-linksbag.conf", QSettings::NativeFormat);
        const int lastUpdate = settings.value ("lastUpdate", 0).toInt ();
        Api_->LoadBookmarks (lastUpdate);
    }

    void LinksBagManager::removeBookmark (const QString& id)
    {
        Api_->RemoveBookmark (id);
    }

    void LinksBagManager::markAsFavorite(const QString& id, bool favorite)
    {
        Api_->MarkBookmarkAsFavorite (id, favorite);
    }

    void LinksBagManager::markAsRead (const QString& id, bool read)
    {
        Api_->MarkBookmarkAsRead (id, read);
    }

} // namespace LinskBag
