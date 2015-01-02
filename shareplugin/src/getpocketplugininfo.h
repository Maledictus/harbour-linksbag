#pragma once

#include <TransferEngine-qt5/transferplugininfo.h>
#include <TransferEngine-qt5/transfermethodinfo.h>

class LinksBagPluginInfo : public TransferPluginInfo
{
    Q_OBJECT

    bool Ready_;
    QList<TransferMethodInfo> InfoList_;

public:
    LinksBagPluginInfo ();
    ~LinksBagPluginInfo ();

    QList<TransferMethodInfo> info () const;
    void query ();
    bool ready () const;
};
