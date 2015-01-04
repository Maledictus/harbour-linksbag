#pragma once

#include <QObject>
#include "linksbagmanager.h"

namespace LinksBag
{
	class EnumsProxy : public QObject
	{
		Q_OBJECT
        Q_ENUMS (NotifyTypeProxy)
	public:
        enum NotifyTypeProxy
		{
            Erorr = LinksBagManager::NTError,
            Info = LinksBagManager::NTInfo
		};
	};
}
