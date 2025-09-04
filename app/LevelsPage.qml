import QtQuick 2.4
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Neverbore 1.0 as NB

Page {
    id: levelPage

    property var pack: NB.Levels.getPack(mainView.currentPackIndex)

    title: pack.name
    head.actions: [
        muteAction
    ]

    property bool playMusic: true

    property string nextPage
    StateSaver.properties: "nextPage"
    onNextPageChanged: if (nextPage) pageStack.load(nextPage)
    property bool wasInactive: false
    onActiveChanged: {
        if (wasInactive && active) {
            nextPage = ""
        } else {
            wasInactive = true;
        }
    }

    Image {
        anchors.fill: parent
        source: mainView.dark ? Qt.resolvedUrl("graphics/paperDark.png") : Qt.resolvedUrl("graphics/paper.png")
        fillMode: Image.Tile
    }

    ListView {
        id: view
        anchors.fill: parent
        displayMarginBeginning: units.gu(3)
        displayMarginEnd: units.gu(3)
        model: pack.count
        delegate: LevelListItem {
            id: levelDelegate
            level: levelPage.pack.getLevel(index)
            onView: {
                mainView.currentLevelIndex = index;
                nextPage = Qt.resolvedUrl("GamePage.qml");
            }
        }
    }
}
