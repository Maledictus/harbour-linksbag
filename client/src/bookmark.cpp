#include "bookmark.h"
#include <QtDebug>

namespace LinksBag
{
    Bookmark::Bookmark (QObject *parent)
    : QObject (parent)
    , Favorite_ (false)
    , Read_ (false)
    , Status_ (Bookmark::SNoStatus)
    {
    }

    QString Bookmark::GetID() const
    {
        return ID_;
    }

    void Bookmark::SetID (const QString &id)
    {
        ID_ = id;
    }

    QUrl Bookmark::GetUrl () const
    {
        return Url_;
    }

    void Bookmark::SetUrl (const QUrl &url)
    {
        Url_ = url;
    }

    QString Bookmark::GetTitle () const
    {
        return  Title_;
    }

    void Bookmark::SetTitle (const QString& title)
    {
        Title_ = title;
    }

    QString Bookmark::GetDescription () const
    {
        return Description_;
    }

    void Bookmark::SetDescription (const QString& desc)
    {
        Description_ = desc;
    }

    QUrl Bookmark::GetImageUrl () const
    {
        return ImageUrl_;
    }

    void Bookmark::SetImageUrl (const QUrl& url)
    {
        ImageUrl_ = url;
    }

    QStringList Bookmark::GetTags () const
    {
        return Tags_;
    }

    void Bookmark::SetTags (const QStringList &tags)
    {
        Tags_ = tags;
        emit tagsChanged ();
    }

    bool Bookmark::IsFavorite () const
    {
        return Favorite_;
    }

    void Bookmark::SetIsFavorite (bool favorite)
    {
        Favorite_ = favorite;
        emit favoriteChanged ();
    }

    bool Bookmark::IsRead () const
    {
        return Read_;
    }

    void Bookmark::SetIsRead (bool read)
    {
        Read_ = read;
        emit readChanged ();
    }

    QDateTime Bookmark::GetAddTime () const
    {
        return AddTime_;
    }

    void Bookmark::SetAddTime (const QDateTime& dt)
    {
        AddTime_ = dt;
    }

    QDateTime Bookmark::GetUpdateTime () const
    {
        return UpdateTime_;
    }

    void Bookmark::SetUpdateTime (const QDateTime& dt)
    {
        UpdateTime_ = dt;
    }

    Bookmark::Status Bookmark::GetStatus () const
    {
        return Status_;
    }

    void Bookmark::SetStatus (Bookmark::Status status)
    {
        Status_ = status;
    }

    QByteArray Bookmark::Serialize () const
    {
        quint16 ver = 1;
        QByteArray result;
        {
            QDataStream ostr (&result, QIODevice::WriteOnly);
            ostr << ver
                    << ID_
                    << Url_
                    << Title_
                    << Description_
                    << ImageUrl_
                    << Favorite_
                    << Read_
                    << Tags_
                    << AddTime_
                    << UpdateTime_
                    << Status_;
        }

        return result;
    }

    Bookmark *Bookmark::Deserialize (const QByteArray& data, QObject *parent)
    {
        quint16 ver = 0;
        QDataStream in (data);
        in >> ver;

        if (ver != 1)
        {
            qWarning () << Q_FUNC_INFO
                    << "unknown version"
                    << ver;
            return 0;
        }

        Bookmark *result = new Bookmark (parent);
        int status = 0;
        in >> result->ID_
                >> result->Url_
                >> result->Title_
                >> result->Description_
                >> result->ImageUrl_
                >> result->Favorite_
                >> result->Read_
                >> result->Tags_
                >> result->AddTime_
                >> result->UpdateTime_
                >> status;
        result->SetStatus (static_cast<Status> (status));

        return result;
    }
} // namespace LinksBag
