#pragma once

#include <QObject>
#include <QUrl>
#include <QNetworkReply>

class QNetworkAccessManager;

class GetPocketApi : public QObject
{
    Q_OBJECT
    const QString ConsumerKey_;

    QNetworkAccessManager *NAM_;

public:
    explicit GetPocketApi (QObject *parent = 0);

    void AddBookmark (const QUrl& url, const QStringList& tags);

private slots:
    void handleAddBookmark ();
    void handleNetworkError (QNetworkReply::NetworkError error);

signals:
    void bookmarkAdded ();
    void addingBookmarkFailed ();
};
