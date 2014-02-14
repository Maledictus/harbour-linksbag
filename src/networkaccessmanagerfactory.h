#pragma once

#include <QtNetwork>
#include <QQmlNetworkAccessManagerFactory>
#include "customnetworkaccessmanager.h"

namespace LinksBag
{
    class NetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory
    {
    public:
        explicit NetworkAccessManagerFactory ();

        QNetworkAccessManager* create (QObject* parent)
        {
            CustomNetworkAccessManager* manager = new CustomNetworkAccessManager (parent);
            return manager;
        }

    };
}
