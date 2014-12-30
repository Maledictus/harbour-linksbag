#pragma once

#include <QSortFilterProxyModel>

namespace LinksBag
{
    class FilterProxyModel : public QSortFilterProxyModel
    {
        Q_OBJECT

        QString Filter_;
    public:
        explicit FilterProxyModel(QObject *parent = 0);

        void SetFilter (const QString& filter);

        virtual bool filterAcceptsRow (int sourceRow, const QModelIndex& sourceParent) const;
        virtual bool lessThan (const QModelIndex& left, const QModelIndex& right) const;
    };
} // namespace LinksBag
