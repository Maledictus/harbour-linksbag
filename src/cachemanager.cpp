/*
    Copyright (c) 2014 Oleg Linkin <MaledictusDeMagog@gmail.com>

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

#include "cachemanager.h"
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QSettings>
#include <QStandardPaths>
#include <QtDebug>

namespace LinksBag
{
    CacheManager::CacheManager (QObject *parent)
    : QObject (parent)
    {
    }

    QVariantList CacheManager::GetNewBookmarks () const
    {
        const QString bookmarksPath = "/home/nemo/.local/share/org.sailfishos/sailfish-browser/bookmarks.json";
        QFile file (bookmarksPath);
        if (!file.open (QIODevice::ReadOnly))
        {
            qDebug () << "Unable to open file with bookmarks: "
                    << file.errorString ();
            return QVariantList ();
        }

        const QByteArray& ba = file.readAll ();
        QJsonDocument doc = QJsonDocument::fromJson (ba);
        QJsonArray bookmarks = doc.array ();

        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::DataLocation));
        QVariantList addedBookmarks = settings.value ("bookmarks").toList ();
        QVariantList result;
        for (int i = 0, size = bookmarks.size (); i < size; ++i)
        {
            const QJsonObject& object = bookmarks.at (i).toObject ();
            if (!addedBookmarks.contains (object ["url"].toString ()))
            {
                result << object.toVariantMap ();
            }
            addedBookmarks << bookmarks.at (i).toObject () ["url"].toString ();
        }

        settings.setValue ("bookmarks", addedBookmarks);

        return result;
    }

    void CacheManager::SaveItems (const QVariant& items)
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::DataLocation));
        settings.setValue ("items", items.toList());
        qDebug () << "items saved: " << items.toList().count();
    }

    QVariantList CacheManager::GetSavedItems () const
    {
        QSettings settings (QStandardPaths::writableLocation (QStandardPaths::DataLocation));
        return settings.value ("items").toList ();
    }
}
