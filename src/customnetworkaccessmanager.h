#pragma once

#include <QNetworkAccessManager>
#include <QtNetwork>

namespace LinksBag
{
    class CustomNetworkAccessManager : public QNetworkAccessManager
    {
        Q_OBJECT

        QString  UserAgent_;
    public:
        explicit CustomNetworkAccessManager (QObject *parent = 0);

    protected:
        QNetworkReply* createRequest (Operation op, const QNetworkRequest& req,
                QIODevice *outgoingData = 0);
    };
}
