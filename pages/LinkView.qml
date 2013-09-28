import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page
{
	id: page

    property int itemId;

	IconButton
	{
		id: readButton
		anchors.right: page.right
		icon.source: pocketModel.IsRead (itemId) ?
            "image://Theme/icon-m-certificates":
            "image://Theme/icon-m-mail";
		onClicked:
			pocketManager.setRead (itemId, !pocketModel.IsRead (itemId));
	}

	IconButton
	{
		id: favoriteButton
		icon.source: pocketModel.IsFavorite (itemId) ?
            "image://Theme/icon-m-favorite-selected":
            "image://Theme/icon-m-favorite";
		anchors.right: readButton.left

		onClicked:
			pocketManager.setFavorite (itemId, !pocketModel.IsFavorite (itemId))
	}

	SilicaFlickable
	{
		clip: true
		anchors.top: readButton.bottom
		anchors.bottom: parent.bottom
		anchors.left: parent.left;
		anchors.right: parent.right
		contentWidth: view.width
		contentHeight: view.height

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
}
