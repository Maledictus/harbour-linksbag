#include "getpocketmediatransfer.h"

LinksBagMediaTransfer::LinksBagMediaTransfer (QObject *parent)
: MediaTransferInterface (parent)
{
}

LinksBagMediaTransfer::~LinksBagMediaTransfer ()
{
}

bool LinksBagMediaTransfer::cancelEnabled () const
{
    return false;
}

QString LinksBagMediaTransfer::displayName () const
{
    return QString ("LinksBag");
}

bool LinksBagMediaTransfer::restartEnabled () const
{
    return false;
}

QUrl LinksBagMediaTransfer::serviceIcon () const
{
    return QUrl::fromLocalFile ("/usr/share/harbour-linksbag/images/linksbag.png");
}

void LinksBagMediaTransfer::cancel ()
{
    setStatus (MediaTransferInterface::TransferCanceled);
}

void LinksBagMediaTransfer::start ()
{

}
