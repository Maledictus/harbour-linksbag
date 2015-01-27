#pragma once

#include <QObject>
#include <QDateTime>
#include <QStringList>
#include <QUrl>

namespace LinksBag
{
    class Bookmark : public QObject
    {
        Q_OBJECT

        QString ID_;
        QUrl Url_;
        QString Title_;
        QString Description_;
        QUrl ImageUrl_;
        QStringList Tags_;
        bool Favorite_;
        bool Read_;
        QDateTime AddTime_;
        QDateTime UpdateTime_;
        bool IsArticle_;
        bool IsImage_;
        bool IsVideo_;

    public:
        enum Status
        {
            SNoStatus = 0,
            SArchived,
            SDeleted
        };

    private:
        Status Status_;

        Q_PROPERTY (QString id READ GetID)
        Q_PROPERTY (QUrl url READ GetUrl)
        Q_PROPERTY (QString title READ GetTitle)
        Q_PROPERTY (QString description READ GetDescription)
        Q_PROPERTY (QUrl imageUrl READ GetImageUrl)
        Q_PROPERTY (QStringList tags READ GetTags NOTIFY tagsChanged)
        Q_PROPERTY (bool favorite READ IsFavorite NOTIFY favoriteChanged)
        Q_PROPERTY (bool read READ IsRead NOTIFY readChanged)
        Q_PROPERTY (QDateTime addTime READ GetAddTime)
        Q_PROPERTY (QDateTime updateTime READ GetUpdateTime)
        Q_PROPERTY (bool isArticle READ IsArticle)
        Q_PROPERTY (bool isImage READ IsImage)
        Q_PROPERTY (bool isVideo READ IsVideo)

    public:
        explicit Bookmark(QObject *parent = 0);

        QString GetID () const;
        void SetID (const QString& id);
        QUrl GetUrl () const;
        void SetUrl (const QUrl& url);
        QString GetTitle () const;
        void SetTitle (const QString& title);
        QString GetDescription () const;
        void SetDescription (const QString& title);
        QUrl GetImageUrl () const;
        void SetImageUrl (const QUrl& url);
        QStringList GetTags () const;
        void SetTags (const QStringList& tags);
        bool IsFavorite () const;
        void SetIsFavorite (bool favorite);
        bool IsRead () const;
        void SetIsRead (bool read);
        QDateTime GetAddTime () const;
        void SetAddTime (const QDateTime& dt);
        QDateTime GetUpdateTime () const;
        void SetUpdateTime (const QDateTime& dt);
        Status GetStatus () const;
        void SetStatus (Status status);
        bool IsArticle () const;
        void SetIsArticle (bool article);
        bool IsImage () const;
        void SetIsImage (bool image);
        bool IsVideo () const;
        void SetIsVideo (bool video);

        QByteArray Serialize () const;
        static Bookmark* Deserialize (const QByteArray& data, QObject *parent);

    signals:
        void tagsChanged ();
        void favoriteChanged ();
        void readChanged ();
    };

    typedef QList<Bookmark*> Bookmarks_t;
} // namespace LinksBag
