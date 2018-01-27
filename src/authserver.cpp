/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "authserver.h"

#include <QDateTime>
#include <QDebug>
#include <QTcpServer>
#include <QTcpSocket>

namespace LinksBag
{
AuthServer::AuthServer(QObject *parent)
: QObject(parent)
, m_AuthServer(new QTcpServer(this))
{
    connect(m_AuthServer, &QTcpServer::newConnection,
            this, &AuthServer::handleNewConnection);
}

bool AuthServer::StartListening(const QHostAddress& address, int port)
{
    if (!m_AuthServer)
    {
        qWarning() << Q_FUNC_INFO << "Auth server is not initialized";
        return false;
    }

    if (!m_AuthServer->listen(address, port))
    {
        qWarning() << Q_FUNC_INFO << "Unable to start auth server listening";
        return false;
    }

    return true;
}

void AuthServer::StopListening()
{
    if (m_AuthServer)
    {
        m_AuthServer->close();
    }
}

void AuthServer::SendAnswer(const QString& answer)
{
    if (m_AuthSocket && m_AuthSocket->isWritable())
    {
        QTextStream os(m_AuthSocket);
        os.setAutoDetectUnicode(true);
        os << "HTTP/1.0 200 Ok\r\n"
                    "Content-Type: text/html; charset=\"utf-8\"\r\n"
                    "\r\n"
                    "<html><body><h1>" + answer + "</h1></body></html>\n"
                << QDateTime::currentDateTime().toString() << "\n";
        qDebug() << m_AuthSocket->readAll();
        m_AuthSocket->close();
    }
}

void AuthServer::handleNewConnection()
{
    if (!m_AuthServer)
    {
        qWarning() << Q_FUNC_INFO << "Auth server is not initialized";
        return;
    }

    if (m_AuthSocket = m_AuthServer->nextPendingConnection())
    {
        connect(m_AuthSocket.data(), &QTcpSocket::readyRead,
                this, &AuthServer::handleSocketReadReady);
        connect(m_AuthSocket.data(), &QTcpSocket::disconnected,
                m_AuthSocket.data(), &QTcpSocket::deleteLater);
    }
}

void AuthServer::handleSocketReadReady()
{
    QTcpSocket *socket = qobject_cast<QTcpSocket*>(sender());
    if (!socket)
    {
        return;
    }

    if (socket->isReadable())
    {
        emit gotAuthAnswer(socket->readAll());
    }
}
} // namespace LinksBag
