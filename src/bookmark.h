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

#pragma once

#include <QDateTime>
#include <QStringList>
#include <QVariantMap>
#include <QUrl>

namespace LinksBag
{
class Bookmark
{
    QString m_ID;
    QUrl m_Url;
    QString m_Title;
    QString m_Description;
    QString m_Content;
    QUrl m_ImageUrl;
    QStringList m_Tags;
    bool m_Favorite;
    bool m_Read;
    QDateTime m_AddTime;
    QDateTime m_UpdateTime;

public:
    enum Status
    {
        SNoStatus = 0,
        SArchived,
        SDeleted
    };

private:
    Status m_Status;

public:
    explicit Bookmark();

    QString GetID() const;
    void SetID(const QString& id);
    QUrl GetUrl() const;
    void SetUrl(const QUrl& url);
    QString GetTitle() const;
    void SetTitle(const QString& title);
    QString GetDescription() const;
    void SetDescription(const QString& title);
    QUrl GetImageUrl() const;
    void SetImageUrl(const QUrl& url);
    QStringList GetTags() const;
    void SetTags(const QStringList& tags);
    bool IsFavorite() const;
    void SetIsFavorite(bool favorite);
    bool IsRead() const;
    void SetIsRead(bool read);
    QDateTime GetAddTime() const;
    void SetAddTime(const QDateTime& dt);
    QDateTime GetUpdateTime() const;
    void SetUpdateTime(const QDateTime& dt);
    Status GetStatus() const;
    void SetStatus(Status status);

    QString GetContent() const;
    void SetContent(const QString& content);

    QByteArray Serialize() const;
    static Bookmark Deserialize(const QByteArray& data);

    QVariantMap ToMap() const;

    bool IsValid() const;
};

typedef QList<Bookmark> Bookmarks_t;
} // namespace LinksBag
