import QtQuick 2.0
import Sailfish.Silica 1.0
import org.LinksBag 1.0

Page
{
	id: page

	SilicaListView
	{
		id: listView
		anchors.fill: parent
		model: pocketModel
		header: SearchField {
			width: parent.width
			placeholderText: "Search"

			onTextChanged: {
			   pocketModel.handleSearchTextChanged (text);
			}
		}

		PullDownMenu
		{
			MenuItem
			{
				text: "Authorize";
				visible: !pocketManager.authorized
				onClicked:
					if (!pocketManager.authorized)
						pocketManager.authorize ();
			}

			MenuItem
			{
				text: "Refresh";
				visible: pocketManager.authorized
				onClicked: pocketManager.refresh ();
			}

			MenuItem
			{
				text: "All";
				visible: pocketManager.authorized
				onClicked: pocketModel.filter (LinksBag.All);
			}

			MenuItem
			{
				text: "Favorite";
				visible: pocketManager.authorized
				onClicked: pocketModel.filter (LinksBag.Favorite)
			}

			MenuItem
			{
				text: "Archive";
				visible: pocketManager.authorized
				onClicked: pocketModel.filter (LinksBag.Archive)
			}
		}

		delegate: BackgroundItem
		{
			width: listView.width

			Column
			{
				Label
				{
					id: title
					text: entryTitle
					elide: Text.ElideRight
					color: parent.down ? Theme.highlightColor : Theme.primaryColor
					font.bold: false
					font.family: Theme.fontFamilyHeading
					font.pixelSize:  Theme.fontSizeMedium
				}
				Label
				{
					id: tags
					text: entryTags
					elide: Text.ElideRight
					color: parent.down ? Theme.highlightColor : Theme.primaryColor
					font.italic: true
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSizeTiny
				}
				width: parent.width - Theme.paddingSmall
				x: Theme.paddingSmall
			}

			onClicked:
				pageStack.push (Qt.resolvedUrl ("LinkView.qml"),
					{ "itemId" : entryId })
		}
		VerticalScrollDecorator {}
	}
}


