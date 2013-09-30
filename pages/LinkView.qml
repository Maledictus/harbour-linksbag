import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page
{
	id: page

	property int itemId;

	RemorsePopup { id: remorse }


	SilicaFlickable
	{
		anchors.fill: parent

		PullDownMenu
		{
			MenuItem
			{
				text: "Delete";
				onClicked: remorse.execute ("Deleting", function () { pocketManager.deleteItem (itemId) })
			}

			MenuItem
			{
				id: readItem
				text: pocketModel.IsRead (itemId) ? "Set unread" : "Set read";
				onClicked: pocketManager.setRead (itemId, !pocketModel.IsRead (itemId));
			}

			MenuItem
			{
				id: favoriteItem
				text: pocketModel.IsFavorite (itemId) ? "Set unfavorite" : "Set favorite";
				onClicked: pocketManager.setFavorite (itemId, !pocketModel.IsFavorite (itemId))
			}
		}

		WebView
		{
			id: view
			url: pocketModel.GetUrl (itemId);
			height: page.height
			width: page.width
		}

		VerticalScrollDecorator {}
		HorizontalScrollDecorator {}
	}

	Connections
	{
		target: pocketModel
		onItemUpdated:
		{
			readItem.text = pocketModel.IsRead (itemId) ? "Set unread" : "Set read";
			favoriteItem.text = pocketModel.IsFavorite (itemId) ? "Set unfavorite" : "Set favorite";
		}
	}
}
