#pragma once

#include <TransferEngine-qt5/mediatransferinterface.h>
#include <TransferEngine-qt5/mediaitem.h>

#include <QString>
#include <QUrl>


class LinksBagMediaTransfer : public MediaTransferInterface
{
    Q_OBJECT

public:
    LinksBagMediaTransfer (QObject * parent = 0);
    ~LinksBagMediaTransfer ();

    bool cancelEnabled () const;
    QString	displayName () const;
    bool restartEnabled () const;
    QUrl serviceIcon () const;

public slots:
    void cancel ();
    void start ();

};
