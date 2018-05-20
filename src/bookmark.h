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

#pragma once

#include <memory>

#include <QDateTime>
#include <QObject>
#include <QStringList>
#include <QVariantMap>
#include <QUrl>

namespace LinksBag
{
class Bookmark : public QObject
{
    Q_OBJECT

    QString m_ID;
    QUrl m_Url;
    QString m_Title;
    QString m_Description;
    QUrl m_ImageUrl;
    QStringList m_Tags;
    bool m_Favorite;
    bool m_Read;
    QDateTime m_AddTime;
    QDateTime m_UpdateTime;
    QList<QUrl> m_Images;
    QList<QUrl> m_Videos;

public:
    enum Status
    {
        SNoStatus = 0,
        SArchived,
        SDeleted
    };

    enum ContentType
    {
        CTNoType,
        CTArticle,
        CTImage,
        CTVideo
    };

private:
    Status m_Status;
    ContentType m_ContentType;

    Q_PROPERTY(QString id READ GetID NOTIFY idChanged)
    Q_PROPERTY(QUrl url READ GetUrl NOTIFY urlChanged)
    Q_PROPERTY(QString title READ GetTitle NOTIFY titleChanged)
    Q_PROPERTY(QString description READ GetDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QUrl imageUrl READ GetImageUrl NOTIFY imageUrlChanged)
    Q_PROPERTY(QString tags READ GetTagsString NOTIFY tagsChanged)
    Q_PROPERTY(bool favorite READ IsFavorite NOTIFY favoriteChanged)
    Q_PROPERTY(bool read READ IsRead NOTIFY readChanged)
    Q_PROPERTY(QDateTime addDate READ GetAddTime NOTIFY addTimeChanged)
    Q_PROPERTY(QDateTime updateDate READ GetUpdateTime  NOTIFY updateTimeChanged)
    Q_PROPERTY(QVariantList images READ GetImagesVar NOTIFY imagesChanged)
    Q_PROPERTY(QVariantList videos READ GetVideosVar NOTIFY videosChanged)
    Q_PROPERTY(Status status READ GetStatus NOTIFY statusChanged)
    Q_PROPERTY(ContentType contentTyp READ GetContentType NOTIFY contentTypeChanged)
    Q_PROPERTY(bool hasContent READ HasContent NOTIFY hasContentChanged)
    Q_PROPERTY(QUrl coverImage READ GetCoverImage NOTIFY coverImageChanged)

public:
    explicit Bookmark(QObject *parent = nullptr);

    QString GetID() const;
    void SetID(const QString& id);
    QUrl GetUrl() const;
    void SetUrl(const QUrl& url);
    QString GetTitle() const;
    void SetTitle(const QString& title);
    QString GetDescription() const;
    void SetDescription(const QString& title);
    QUrl GetCoverImageUrl();
    QUrl GetImageUrl() const;
    void SetImageUrl(const QUrl& url);
    QStringList GetTags() const;
    QString GetTagsString() const;
    void SetTags(const QStringList& tags);
    bool IsFavorite() const;
    void SetIsFavorite(bool favorite);
    bool IsRead() const;
    void SetIsRead(bool read);
    QDateTime GetAddTime() const;
    void SetAddTime(const QDateTime& dt);
    QDateTime GetUpdateTime() const;
    void SetUpdateTime(const QDateTime& dt);
    QList<QUrl> GetImages() const;
    QVariantList GetImagesVar() const;
    void SetImages(const QList<QUrl>& urls);
    QList<QUrl> GetVideos() const;
    QVariantList GetVideosVar() const;
    void SetVideos(const QList<QUrl>& urls);
    Status GetStatus() const;
    void SetStatus(Status status);
    ContentType GetContentType() const;
    void SetContentType(ContentType contentType);
    QUrl GetCoverImage() const;

    bool HasContent();
    QString GetThumbnail();

    QByteArray Serialize() const;
    static std::shared_ptr<Bookmark> Deserialize(const QByteArray& data);

    bool IsValid() const;

signals:
    void idChanged();
    void urlChanged();
    void titleChanged();
    void descriptionChanged();
    void imageUrlChanged();
    void tagsChanged();
    void favoriteChanged();
    void readChanged();
    void addTimeChanged();
    void updateTimeChanged();
    void imagesChanged();
    void videosChanged();
    void statusChanged();
    void contentTypeChanged();
    void hasContentChanged();
    void coverImageChanged();
};

typedef QList<std::shared_ptr<Bookmark>> Bookmarks_t;
} // namespace LinksBag
