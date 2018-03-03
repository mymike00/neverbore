import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    title: i18n.tr("How to Play")
    head.actions: [
        muteAction
    ]
    property bool playMusic: true

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("graphics/paper.png")
        fillMode: Image.Tile
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: border.height

        Rectangle {
            id: border
            color: "white"
            width: parent.width
            height: childrenRect.height

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: units.gu(2)
                y: units.gu(2)
                height: childrenRect.height + units.gu(2) * 2
                spacing: units.gu(2)

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: i18n.tr("Picross games are grid logic puzzles where you must determine which of the grid squares are filled in.")
                    wrapMode: Text.Wrap
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: i18n.tr("Each row and column have a set of number hints. Each number indicates a sequence of filled squares in that row or column. For example, a row with \"4 2\" means that row has a run of 4 filled squares and a run of 2 filled squares to its right, separated by one or more empty squares.")
                    wrapMode: Text.Wrap
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: i18n.tr("If you want to experiment with what the board would look like <em>if</em> a square were filled, try clicking the ghost icon at the top of the screen. This enters ghost mode and all changes to the board can be either kept or discarded when you leave ghost mode.")
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
