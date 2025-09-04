import QtQuick 2.4
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Neverbore 1.0 as NB

Page {
    id: packsPage

    title: i18n.tr("Puzzles")
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
        source: Qt.resolvedUrl("graphics/paper.png")
        fillMode: Image.Tile
    }

    ListView {
        id: view
        anchors.fill: parent
        displayMarginBeginning: units.gu(3)
        displayMarginEnd: units.gu(3)
        model: NB.Levels.count
        delegate: LevelListItem {
            id: packDelegate
            pack: NB.Levels.getPack(index)
            level: pack.count == 1 ? pack.getLevel(0) : null
            onView: {
                mainView.currentPackIndex = index;
                if (level) {
                    mainView.currentLevelIndex = 0;
                    nextPage = Qt.resolvedUrl("GamePage.qml");
                } else {
                    nextPage = Qt.resolvedUrl("LevelsPage.qml");
                }
            }
        }
    }
}
