#include "getpocketmediatransfer.h"
#include <QFile>
#include <QMap>
#include <QSettings>
#include <QStandardPaths>
#include "getpocketapi.h"

LinksBagMediaTransfer::LinksBagMediaTransfer (QObject *parent)
: MediaTransferInterface (parent)
{
}

LinksBagMediaTransfer::~LinksBagMediaTransfer ()
{
}

void LinksBagMediaTransfer::BookmarkAdded (bool success)
{
    success ?
        setStatus (MediaTransferInterface::TransferFinished) :
        setStatus (MediaTransferInterface::TransferInterrupted);

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
    const auto& map = mediaItem ()->value (MediaItem::UserData).toMap ();
    QStringList tags = map ["tags"].toString ().split (",");
    for (auto& tag : tags)
        tag = tag.trimmed ();

    GetPocketApi *api = new GetPocketApi;
    connect (api,
        &GetPocketApi::bookmarkAdded,
        this,
        [this, api] ()
        {
            BookmarkAdded (true);
            api->deleteLater ();
        });
    connect (api,
        &GetPocketApi::addingBookmarkFailed,
        this,
        [this, api] ()
        {
            BookmarkAdded (false);
            api->deleteLater ();
        });
    api->AddBookmark (map ["link"].toUrl (), tags);
}
