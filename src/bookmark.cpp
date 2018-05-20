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
Bookmark::Bookmark(QObject *parent)
: QObject(parent)
, m_Favorite(false)
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
    if (m_ID != id) {
        m_ID = id;
        emit idChanged();
    }
}

QUrl Bookmark::GetUrl() const
{
    return m_Url;
}

void Bookmark::SetUrl(const QUrl& url)
{
    if (m_Url != url) {
        m_Url = url;
        emit urlChanged();
    }
}

QString Bookmark::GetTitle() const
{
    return  m_Title;
}

void Bookmark::SetTitle(const QString& title)
{
    if (m_Title != title) {
        m_Title = title;
        emit titleChanged();
    }
}

QString Bookmark::GetDescription() const
{
    return m_Description;
}

void Bookmark::SetDescription(const QString& desc)
{
    if (m_Description != desc) {
        m_Description = desc;
        emit descriptionChanged();
    }
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
    if (m_ImageUrl != url) {
        m_ImageUrl = url;
        emit imageUrlChanged();
    }
}

QStringList Bookmark::GetTags() const
{
    return m_Tags;
}

QString Bookmark::GetTagsString() const
{
    return m_Tags.join(",");
}

void Bookmark::SetTags(const QStringList& tags)
{
    if (m_Tags != tags) {
        m_Tags = tags;
        emit tagsChanged();
    }
}

bool Bookmark::IsFavorite() const
{
    return m_Favorite;
}

void Bookmark::SetIsFavorite(bool favorite)
{
    if (m_Favorite != favorite) {
        m_Favorite = favorite;
        emit favoriteChanged();
    }
}

bool Bookmark::IsRead() const
{
    return m_Read;
}

void Bookmark::SetIsRead(bool read)
{
    if (m_Read != read) {
        m_Read = read;
        emit readChanged();
    }
}

QDateTime Bookmark::GetAddTime() const
{
    return m_AddTime;
}

void Bookmark::SetAddTime(const QDateTime& dt)
{
    if (m_AddTime != dt) {
        m_AddTime = dt;
        emit addTimeChanged();
    }
}

QDateTime Bookmark::GetUpdateTime() const
{
    return m_UpdateTime;
}

void Bookmark::SetUpdateTime(const QDateTime& dt)
{
    if (m_UpdateTime != dt) {
        m_UpdateTime = dt;
        emit updateTimeChanged();
    }
}

QVariantList Bookmark::GetImagesVar() const
{
    QVariantList result;
    result.reserve(m_Images.size());
    std::copy(m_Images.begin(), m_Images.end(), result.begin());
    return result;
}

QList<QUrl> Bookmark::GetImages() const
{
    return m_Images;
}

void Bookmark::SetImages(const QList<QUrl>& urls)
{
    if (m_Images != urls) {
        m_Images = urls;
        emit imagesChanged();
    }
}

QVariantList Bookmark::GetVideosVar() const
{
    QVariantList result;
    result.reserve(m_Videos.size());
    std::copy(m_Videos.begin(), m_Videos.end(), result.begin());
    return result;
}

QList<QUrl> Bookmark::GetVideos() const
{
    return m_Videos;
}

void Bookmark::SetVideos(const QList<QUrl>& urls)
{
    if (m_Videos != urls) {
        m_Videos = urls;
        emit videosChanged();
    }
}

Bookmark::Status Bookmark::GetStatus() const
{
    return m_Status;
}

void Bookmark::SetStatus(Bookmark::Status status)
{
    if (m_Status != status) {
        m_Status = status;
        emit statusChanged();
    }
}

Bookmark::ContentType Bookmark::GetContentType() const
{
    return m_ContentType;
}

void Bookmark::SetContentType(Bookmark::ContentType contentType)
{
    if (m_ContentType != contentType) {
        m_ContentType = contentType;
        emit contentTypeChanged();
    }
}

QUrl Bookmark::GetCoverImage() const
{
    const auto cachedPath = Application::GetPath(Application::CoverCacheDirectory) + m_ID + ".jpg";
    return QFile::exists(cachedPath) ? QUrl::fromLocalFile(cachedPath) : m_ImageUrl;
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

std::shared_ptr<Bookmark> Bookmark::Deserialize(const QByteArray& data)
{
    quint16 ver = 0;
    QDataStream in(data);
    in >> ver;

    auto result = std::make_shared<Bookmark>();
    if(ver > 4)
    {
        qWarning() << Q_FUNC_INFO
                << "unknown version"
                << ver;
        return result;
    }

    int status = 0;
    in >> result->m_ID
            >> result->m_Url
            >> result->m_Title
            >> result->m_Description
            >> result->m_ImageUrl
            >> result->m_Favorite
            >> result->m_Read
            >> result->m_Tags
            >> result->m_AddTime
            >> result->m_UpdateTime
            >> status;
    result->SetStatus(static_cast<Status>(status));

    if (ver == 4)
    {
        int content = 0;
        in >> content
                >> result->m_Images
                >> result->m_Videos;
        result->SetContentType(static_cast<Bookmark::ContentType>(content));
    }

    return result;
}

bool Bookmark::IsValid() const
{
    return !m_ID.isEmpty();
}
} // namespace LinksBag
