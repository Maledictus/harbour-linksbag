#pragma once

#include <QObject>
#include <QHostAddress>
#include <QPointer>

class QTcpServer;
class QTcpSocket;

namespace LinksBag
{
class AuthServer : public QObject
{
    Q_OBJECT

    QTcpServer *m_AuthServer;
    QPointer<QTcpSocket> m_AuthSocket;
public:
    explicit AuthServer(QObject *parent = 0);

    bool StartListening(const QHostAddress& address, int port);
    void StopListening();
    void SendAnswer(const QString& answer);
private slots:
    void handleNewConnection();
    void handleSocketReadReady();

signals:
    void gotAuthAnswer(const QString& data);
};

} // namespace LinksBag
