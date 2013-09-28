import QtQuick 2.0
import Sailfish.Silica 1.0

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
				text: pocketManager.authorized ?
					"GetPocket: " + pocketManager.login :
					"Authorize";
				onClicked:
				{
					if (!pocketManager.authorized)
						pocketManager.authorize ();
				}
			}

			MenuItem
			{
				text: "Refresh";
				visible: pocketManager.authorized
				onClicked: pocketManager.refresh ();
			}
		}

		delegate: BackgroundItem
		{
			width: listView.width
			Label
			{
				id: title
				text: entryTitle
				elide: Text.ElideRight
                color: parent.down ? Theme.highlightColor : Theme.primaryColor
				anchors.verticalCenter: parent.verticalCenter
                x: Theme.paddingLarge
                font.bold: false

                width: parent.width - Theme.paddingLarge
			}
			onClicked: pageStack.push (Qt.resolvedUrl ("LinkView.qml"),
                    { "itemId" : entryId })
		}
		VerticalScrollDecorator {}
	}
}


