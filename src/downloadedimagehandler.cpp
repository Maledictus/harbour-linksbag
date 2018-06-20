/*
The MIT License (MIT)

Copyright (c) 2017-2018 Maciej Janiszewski <chleb@krojony.pl>

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

#include "downloadedimagehandler.h"

#include <QImage>
#include <QNetworkReply>

#include "application.h"
#include "bookmarksmodel.h"

namespace LinksBag
{
DownloadedImageHandler::DownloadedImageHandler(QNetworkReply *reply, QString id,
        BookmarksModel *model)
: m_Reply(reply)
, m_Id(id)
, m_Model(model)
{
}

void DownloadedImageHandler::run()
{
    if (!m_Reply)
    {
        return;
    }

    QImage downloadedImage = QImage::fromData(m_Reply->readAll());
    if (!downloadedImage.isNull())
    {
        downloadedImage.save(Application::GetPath(Application::CoverCacheDirectory) + m_Id + ".jpg");
        downloadedImage
                .scaled(720, 400, Qt::KeepAspectRatioByExpanding)
                .copy(0, 0, 720, 400)
                .save(Application::GetPath(Application::ThumbnailCacheDirectory) + m_Id + ".jpg");
        if (m_Model)
        {
            m_Model->RefreshBookmark(m_Id);
        }
    }
}
}
