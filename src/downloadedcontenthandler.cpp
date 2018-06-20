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

#include "downloadedcontenthandler.h"

#include <QFile>
#include <QtDebug>
#include <QTextStream>

#include "application.h"
#include "bookmarksmodel.h"

namespace LinksBag
{
DownloadedContentHandler::DownloadedContentHandler(QString id, QString article, BookmarksModel *model)
: m_Id(id)
, m_ArticleContent(article)
, m_Model(model)
{
}

DownloadedContentHandler::DownloadedContentHandler(QString id, QImage image, BookmarksModel *model)
: m_Id(id)
, m_ImageContent(image)
, m_Model(model)
{
}

void DownloadedContentHandler::run()
{
    if (!m_ArticleContent.isEmpty())
    {
        QFile file(Application::GetPath(Application::ArticleCacheDirectory) + m_Id);
        if (file.open(QIODevice::WriteOnly))
        {
            QTextStream stream(&file);
            stream << m_ArticleContent;
        }
        else
        {
            qWarning() << "Can't save file: " << file.errorString();
        }
        file.close();
        if (m_Model)
        {
            m_Model->RefreshBookmark(m_Id);
        }
    }
    else if (!m_ImageContent.isNull())
    {
        m_ImageContent.save(Application::GetPath(Application::ArticleCacheDirectory) + m_Id, "PNG");
    }

    if (m_Model)
    {
        m_Model->RefreshBookmark(m_Id);
    }
}

} // namespace LinksBag
