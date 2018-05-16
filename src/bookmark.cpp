/*
The MIT License (MIT)

Copyright (c) 2014-2018 Oleg Linkin <maledictusdemagog@gmail.com>
Copyright (c) 2018 Maciej Janiszewski <chleb@krojony.pl>

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

#include "bookmark.h"
#include "application.h"
#include <QtDebug>
#include <QDataStream>
#include <QFile>

namespace LinksBag
{
Bookmark::Bookmark()
: m_Favorite(false)
, m_Read(false)
, m_Status(Bookmark::SNoStatus)
{
}

QString Bookmark::GetID() const
{
    return m_ID;
}

void Bookmark::SetID(const QString &id)
{
    m_ID = id;
}

QUrl Bookmark::GetUrl() const
{
    return m_Url;
}

void Bookmark::SetUrl(const QUrl &url)
{
    m_Url = url;
}

QString Bookmark::GetTitle() const
{
    return  m_Title;
}

void Bookmark::SetTitle(const QString& title)
{
    m_Title = title;
}

QString Bookmark::GetDescription() const
{
    return m_Description;
}

void Bookmark::SetDescription(const QString& desc)
{
    m_Description = desc;
}

QUrl Bookmark::GetImageUrl() const
{
    return m_ImageUrl;
}

QUrl Bookmark::GetCoverImageUrl()
{
    QString cachedPath = Application::GetPath(Application::CoverCacheDirectory) + m_ID + ".jpg";
    if (QFile::exists(cachedPath)) {
        return cachedPath;
    } else return m_ImageUrl;
}

void Bookmark::SetImageUrl(const QUrl& url)
{
    m_ImageUrl = url;
}

QStringList Bookmark::GetTags() const
{
    return m_Tags;
}

void Bookmark::SetTags(const QStringList &tags)
{
    m_Tags = tags;
}

bool Bookmark::IsFavorite() const
{
    return m_Favorite;
}

void Bookmark::SetIsFavorite(bool favorite)
{
    m_Favorite = favorite;
}

bool Bookmark::IsRead() const
{
    return m_Read;
}

void Bookmark::SetIsRead(bool read)
{
    m_Read = read;
}

QDateTime Bookmark::GetAddTime() const
{
    return m_AddTime;
}

void Bookmark::SetAddTime(const QDateTime& dt)
{
    m_AddTime = dt;
}

QDateTime Bookmark::GetUpdateTime() const
{
    return m_UpdateTime;
}

void Bookmark::SetUpdateTime(const QDateTime& dt)
{
    m_UpdateTime = dt;
}

QList<QUrl> Bookmark::GetImages() const
{
    return m_Images;
}

void Bookmark::SetImages(const QList<QUrl>& urls)
{
    m_Images = urls;
}

QList<QUrl> Bookmark::GetVideos() const
{
    return m_Videos;
}

void Bookmark::SetVideos(const QList<QUrl>& urls)
{
    m_Videos = urls;
}

Bookmark::Status Bookmark::GetStatus() const
{
    return m_Status;
}

void Bookmark::SetStatus(Bookmark::Status status)
{
    m_Status = status;
}

Bookmark::ContentType Bookmark::GetContentType() const
{
    return m_ContentType;
}

void Bookmark::SetContentType(Bookmark::ContentType contentType)
{
    m_ContentType = contentType;
}

QString Bookmark::GetThumbnail()
{
    QString path = Application::GetPath(Application::ThumbnailCacheDirectory) + m_ID + ".jpg";
    if (QFile(path).exists())
        return path;
    return "";
}

bool Bookmark::HasContent()
{
    return QFile::exists(Application::GetPath(Application::ArticleCacheDirectory) + m_ID + ".html");
}

QByteArray Bookmark::Serialize() const
{
    quint16 ver = 4;
    QByteArray result;
    {
        QDataStream ostr(&result, QIODevice::WriteOnly);
        ostr << ver
                << m_ID
                << m_Url
                << m_Title
                << m_Description
                << m_ImageUrl
                << m_Favorite
                << m_Read
                << m_Tags
                << m_AddTime
                << m_UpdateTime
                << m_Status
                << m_ContentType
                << m_Images
                << m_Videos;
    }

    return result;
}

Bookmark Bookmark::Deserialize(const QByteArray& data)
{
    quint16 ver = 0;
    QDataStream in(data);
    in >> ver;

    if(ver > 4)
    {
        qWarning() << Q_FUNC_INFO
                << "unknown version"
                << ver;
        return Bookmark();
    }

    Bookmark result;
    int status = 0;
    in >> result.m_ID
            >> result.m_Url
            >> result.m_Title
            >> result.m_Description
            >> result.m_ImageUrl
            >> result.m_Favorite
            >> result.m_Read
            >> result.m_Tags
            >> result.m_AddTime
            >> result.m_UpdateTime
            >> status;
    result.SetStatus(static_cast<Status>(status));

    if (ver == 4)
    {
        int content = 0;
        in >> content
                >> result.m_Images
                >> result.m_Videos;
        result.SetContentType(static_cast<Bookmark::ContentType>(content));
    }

    return result;
}

QVariantMap Bookmark::ToMap() const
{
    QVariantMap map;
    map["bookmarkID"] = m_ID;
    map["bookmarkUrl"] = m_Url;
    map["bookmarkTitle"] = m_Title;
    map["bookmarkDescription"] = m_Description;
    map["bookmarkImageUrl"] = m_ImageUrl;
    map["bookmarkFavorite"] = m_Favorite;
    map["bookmarkRead"] = m_Read;
    map["bookmarkTags"] = m_Tags;
    map["bookmarkAddTime"] = m_AddTime;
    map["bookmarkUpdateTime"] = m_UpdateTime;
    map["bookmarkStatus"] = m_Status;
    map["bookmarkHasContent"] = QFile::exists(Application::GetPath(Application::ArticleCacheDirectory) + m_ID + ".html");

    QString cachedPath = Application::GetPath(Application::CoverCacheDirectory) + m_ID + ".jpg";
    map["bookmarkCoverImage"] = QFile::exists(cachedPath) ? cachedPath : m_ImageUrl;

    map["bookmarkContentType"] = m_ContentType;
    QVariantList images;
    images.reserve(m_Images.size());
    std::copy(m_Images.begin(), m_Images.end(), images.begin());
    map["bookmarkImages"] = images;

    QVariantList videos;
    videos.reserve(m_Videos.size());
    std::copy(m_Videos.begin(), m_Videos.end(), videos.begin());
    map["bookmarkVideos"] = videos;

    return map;
}

bool Bookmark::IsValid() const
{
    return !m_ID.isEmpty();
}
} // namespace LinksBag
