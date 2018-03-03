import QtQuick 2.4
import Ubuntu.Components 1.3

MenuListItem {
    id: listItem

    property var level: null
    property var pack: null
    signal view()

    text: level ? level.name : pack.name
    progression: true

    trailingActions: level ? d.actions : null
    onClicked: view()

    QtObject {
        id: d

        property var actions: ListItemActions {
            actions: [
                Action {
                    visible: level ? level.anyGuessed : false
                    iconName: "reset"
                    onTriggered: {
                        Haptics.play();
                        level.clearGuesses();
                    }
                }
            ]
        }
    }

    Label {
        text: level ? level.rows + "×" + level.columns : ""
        opacity: 0.5
        anchors.right: star.left
        anchors.rightMargin: units.gu(2)
        anchors.verticalCenter: parent.verticalCenter
    }

    Icon {
        id: star
        visible: level ? level.finished : pack.finished
        name: "starred"
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1.5)
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(3)
        height: width
    }
}
