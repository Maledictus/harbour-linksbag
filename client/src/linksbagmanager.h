#pragma once

#include <QObject>

namespace LinksBag
{
    class BookmarksModel;
    class FilterProxyModel;
    class GetPocketApi;

    class LinksBagManager : public QObject
    {
        Q_OBJECT

        GetPocketApi *Api_;

        QString RequesToken_;
        QString UserName_;
        QString Filter_;
        bool Authorized_;
        BookmarksModel *BookmarksModel_;
        FilterProxyModel *FilterProxyModel_;
        Q_PROPERTY (QString requestToken READ GetRequestToken NOTIFY requestTokenChanged)
        Q_PROPERTY (bool authorized READ IsAuthorized NOTIFY authorizationChanged)
        Q_PROPERTY (QObject* bookmarksModel READ GetBookmarksModel NOTIFY bookmarksModelChanged)
        Q_PROPERTY (QString filter READ GetFilter NOTIFY filterChanged)
	Q_PROPERTY (bool searchFieldVisible READ GetSearchFieldVisibility WRITE SetSearchFieldVisibility NOTIFY searchFieldVisibilityChanged)

    public:
        enum NotifyType
        {
            NTError = 0,
            NTInfo
        };


        explicit LinksBagManager (QObject *parent = 0);

        QString GetRequestToken () const;
        bool IsAuthorized () const;
        QObject* GetBookmarksModel () const;
        QString GetFilter () const;
	bool GetSearchFieldVisibility () const;
        void SetSearchFieldVisibility (bool visible);
        Q_INVOKABLE QObject* GetBookmark (const QString& id) const;
    private:
        void SaveBookmarks ();
        void LoadBookmarksFromStorage ();

    public slots:
        void obtainRequestToken ();
        void requestAccessToken ();

        void filterBookmarks (const QString& text);
        void setFilter (const QString& filter);

        void loadBookmarks ();
        void refreshBookmarks ();
        void removeBookmark (const QString& id);
        void markAsFavorite (const QString& id, bool favorite);
        void markAsRead (const QString& id, bool read);
    signals:
        void requestTokenChanged ();
        void credentialsChanged ();
        void authorizationChanged ();
        void filterChanged ();
        void bookmarksModelChanged ();
        void requestFinished ();
	void searchFieldVisibilityChanged ();

        void notify (int type, const QString& message);
    };
} // namespace LinskBag
