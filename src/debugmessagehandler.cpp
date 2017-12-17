/*
The MIT License (MIT)

Copyright (c) 2014-2017 Oleg Linkin <maledictusdemagog@gmail.com>

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

#include "debugmessagehandler.h"

#include <memory>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <cstdlib>

#include <unistd.h>

#include <QMutex>
#include <QMutexLocker>
#include <QStandardPaths>
#include <QThread>
#include <QDateTime>
#include <QDir>

QMutex G_DbgMutex;
uint Counter = 0;

namespace
{
    std::shared_ptr<std::ostream> GetOstream()
    {
        auto dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QDir dir(dataDir);
        if (!dir.exists())
        {
            dir.mkpath(dataDir);
        }
        const QString name = dataDir + "/linksbag.log";

        auto ostr = std::make_shared<std::ofstream>();
        ostr->open(QDir::toNativeSeparators(name).toStdString(), std::ios::app);
        return ostr;
    }
}

namespace DebugHandler
{
void Write(QtMsgType type, const QMessageLogContext& ctx, const QString& msg)
{
    const auto& ostr = GetOstream();

    QMutexLocker locker { &G_DbgMutex };
    switch (type)
    {
    case QtDebugMsg:
        *ostr << "[D] ";
        break;
    case QtWarningMsg:
        *ostr << "[W] ";
        break;
    case QtCriticalMsg:
        *ostr << "[C] ";
        break;
    case QtFatalMsg:
        *ostr << "[F] ";
        break;
    case QtInfoMsg:
        *ostr << "[I] ";
        break;
    }

    *ostr << "["
            << QDateTime::currentDateTime()
                    .toString("dd.MM.yyyy HH:mm:ss.zzz")
                    .toStdString()
            << "] ["
            << QThread::currentThread()
            << "] ["
            << std::setfill('0')
            << std::setw(3)
            << Counter++
            << "] "
            << msg.toStdString()
            << " ("
            << ctx.file
            << ":"
            << ctx.line
            << ") "
            << std::endl;
}
}
