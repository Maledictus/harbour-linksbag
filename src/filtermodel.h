#pragma once

#include <QSortFilterProxyModel>
#include <QUrl>

namespace LinksBag
{
    class FilterModel : public QSortFilterProxyModel
    {
        Q_OBJECT
    public:
        explicit FilterModel (QObject *parent = 0);
        bool filterAcceptsRow (int sourceRow, const QModelIndex& sourceParent) const;

        QHash<int, QByteArray> roleNames () const;

        void RestoreItems ();

        Q_INVOKABLE bool IsRead (qint64 id) const;
        Q_INVOKABLE bool IsFavorite (qint64 id) const;
        Q_INVOKABLE QUrl GetUrl (qint64 id) const;
        Q_INVOKABLE QString GetTitle (qint64 id) const;

    public slots:
        void handleFavoriteStateChanged (qint64 id);
        void handleReadStateChanged (qint64 id);
        void handleItemDeleted (qint64 id);
        void handleSearchTextChanged (const QString& text);
    };
}
