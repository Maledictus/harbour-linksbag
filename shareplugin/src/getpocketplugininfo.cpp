#include "getpocketplugininfo.h"
#include <QSettings>

LinksBagPluginInfo::LinksBagPluginInfo ()
: Ready_ (false)
{
}

LinksBagPluginInfo::~LinksBagPluginInfo ()
{
}

QList<TransferMethodInfo> LinksBagPluginInfo::info () const
{
    return InfoList_;
}

void LinksBagPluginInfo::query ()
{
    QSettings settings (QStandardPaths::writableLocation (QStandardPaths::ConfigLocation) + "/harbour-linksbag/harbour-linksbag.conf",
            QSettings::NativeFormat);
    const QString& userName = settings.value ("username").toString ();
    const QString& accessToken = settings.value ("access_token").toString ();

    if (userName.isEmpty () || accessToken.isEmpty ())
    {
        emit infoError (tr ("LinksBag not authorized"));
        return;
    }

    TransferMethodInfo info;

    QStringList capabilities;
    capabilities << QLatin1String ("text/x-url");

    info.displayName = QLatin1String ("LinksBag");
    info.userName = userName;
    info.methodId = QLatin1String ("LinksBagSharePlugin");
    info.shareUIPath = QLatin1String ("/usr/share/harbour-linksbag/qml/ShareUi.qml");
    info.capabilitities = capabilities;

    InfoList_.clear ();
    InfoList_ << info;

    Ready_ = true;
    emit infoReady ();
}

bool LinksBagPluginInfo::ready () const
{
    return Ready_;
}
