#include "getpockettransferiface.h"
#include "getpocketplugininfo.h"
#include "getpocketmediatransfer.h"

#include <QtPlugin>

LinksBagSharePlugin::LinksBagSharePlugin ()
{

}

LinksBagSharePlugin::~LinksBagSharePlugin ()
{

}

QString LinksBagSharePlugin::pluginId () const
{
    return QLatin1String ("LinksBagSharePlugin");
}

bool LinksBagSharePlugin::enabled () const
{
    return true;
}

TransferPluginInfo* LinksBagSharePlugin::infoObject ()
{
    return new LinksBagPluginInfo;
}

MediaTransferInterface* LinksBagSharePlugin::transferObject ()
{
    return new LinksBagMediaTransfer;
}
