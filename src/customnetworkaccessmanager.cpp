#include "customnetworkaccessmanager.h"

namespace LinksBag
{
    CustomNetworkAccessManager::CustomNetworkAccessManager (QObject *parent)
    : QNetworkAccessManager (parent)
    , UserAgent_ ("Mozilla/5.0 (Linux; U; Jolla; Sailfish; Mobile; rv:20.0)"
            " Gecko/20.0 Firefox/20.0 LinksBag 0.1+")
    {
    }

    QNetworkReply* CustomNetworkAccessManager::createRequest (QNetworkAccessManager::Operation op,
            const QNetworkRequest& req, QIODevice *outgoingData)
    {
        QNetworkRequest newRequest (req);
        newRequest.setRawHeader("User-Agent", UserAgent_.toLatin1 ());
        QNetworkReply *reply = QNetworkAccessManager::createRequest (op, newRequest, outgoingData);
        return reply;
    }
}
