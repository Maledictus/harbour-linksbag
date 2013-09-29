#pragma once

#include <QObject>
#include "filtermodel.h"

namespace LinksBag
{
	class EnumsProxy : public QObject
	{
		Q_OBJECT
		Q_ENUMS (ItemTypeProxy);
	public:
		enum ItemTypeProxy
		{
            All = FilterType::All,
            Archive = FilterType::Archive,
            Favorite = FilterType::Favorite
		};
	};
}
