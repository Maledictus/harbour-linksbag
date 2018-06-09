import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"
import "models"

Page {
    allowedOrientations: defaultAllowedOrientations

    SilicaListView {
        anchors.fill: parent
        model: TranslatorsModel { }

        header: PageHeader {
            title: qsTr("Translations")
        }

        PullDownMenu {
            MenuItem {
                text: "Transifex"
                onClicked: Qt.openUrlExternally("https://www.transifex.com/maledictus/harbour-linksbag")
            }
        }

        delegate: Item {
            width: parent.width
            height: column.height + Theme.paddingLarge

            Column {
                id: column
                x: Theme.horizontalPageMargin
                width: parent.width - Theme.horizontalPageMargin * 2
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.paddingSmall

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Qt.AlignHCenter
                    color: Theme.highlightColor
                    text: {
                        var l = Qt.locale(locale)
                        var res = l.nativeLanguageName
                        res = res.charAt(0).toUpperCase() + res.slice(1)
                        if (locale.length > 2) {
                            res += " (%0)".arg(l.nativeCountryName)
                        }
                        return res
                    }
                }

                ParticipantsDelegate {
                    title: qsTr("Coordinators")
                    model: coordinators
                }

                ParticipantsDelegate {
                    title: qsTr("Translators")
                    model: translators
                }

                ParticipantsDelegate {
                    title: qsTr("Reviewers")
                    model: reviewers
                }
            }
        }

        VerticalScrollDecorator {}
    }
}

