import QtQuick 2.4
import QtMultimedia 5.0
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.1
import Neverbore 1.0 as NB

Page {
    id: gamePage

    property bool playMusic: false
    property var pack: NB.Levels.getPack(mainView.currentPackIndex)
    property var level: pack.getLevel(mainView.currentLevelIndex)

    flickable: null
    title: level.name
    head.actions: [
        ghostAction,
        checkAction,
        muteAction
    ]

    property bool hasSeenGhosts
    Settings {
        property alias hasSeenGhosts: gamePage.hasSeenGhosts
    }

    Action {
        id: checkAction
        text: i18n.tr("Check")
        iconName: "ok"
        visible: level.allGuessed && !level.finished
        onTriggered: level.checkGuesses()
    }
    Action {
        id: ghostAction
        text: i18n.tr("Ghost Mode")
        iconSource: level.ghostMode ? Qt.resolvedUrl("graphics/ghost-filled.svg") : Qt.resolvedUrl("graphics/ghost.svg")
        visible: !level.allGuessed && !level.finished
        onTriggered: {
            if (level.ghostMode) {
                if (level.hasGhostGuesses) {
                    PopupUtils.open(ghostExitDialog);
                } else {
                    level.exitGhostMode(true);
                }
            } else {
                if (!hasSeenGhosts) {
                    PopupUtils.open(ghostInfoDialog);
                    hasSeenGhosts = true;
                }
                level.enterGhostMode();
            }
        }
    }

    Image {
        anchors.fill: parent
        source: mainView.dark ? Qt.resolvedUrl("graphics/paperDark.png") : Qt.resolvedUrl("graphics/paper.png")
        fillMode: Image.Tile
    }

    SoundEffect {
        id: success
        muted: mainView.muted
        source: Qt.resolvedUrl("sound/positive.wav")
        volume: 0.5
    }
    SoundEffect {
        id: failure
        muted: mainView.muted
        source: Qt.resolvedUrl("sound/negative.wav")
        volume: 0.5
    }

    GameBoard {
        id: board
        anchors.fill: parent
        clip: true
        level: gamePage.level
    }

    Connections {
        target: gamePage.level
        onFinishedChanged: {
            if (gamePage.level.finished) {
                var index = pack.getLevelIndex(level);
                if (index >= 0 && index < pack.count - 1) {
                    nextButton.nextLevel = index + 1;
                    nextButton.visible = true;
                }
                success.play();
            } else {
                failure.play();
            }
        }
    }

    RowLayout {
      anchors {
         right: parent.right
         left: parent.left
         bottom: parent.bottom
         margins: units.gu(1)
      }
      Item { Layout.fillWidth: true }
      Button {
         id: nextButton
         property int nextLevel
         visible: false
         enabled: visible
         text: i18n.tr("Next puzzle")
         onTriggered: {
            visible = false;
            mainView.currentLevelIndex = nextLevel;
            pageStack.replace(Qt.resolvedUrl("GamePage.qml"));
         }
         // iconName: "next"
         // iconPosition: "right"
      }
   }

    Component {
         id: ghostInfoDialog
         Dialog {
             id: dialog
             title: i18n.tr("Entering ghost mode")
             text: i18n.tr("You are now making temporary guesses that you can choose to either keep or discard when you are done with ghost mode.")
             Button {
                 text: i18n.tr("Got it")
                 color: UbuntuColors.orange
                 onClicked: PopupUtils.close(dialog)
             }
         }
    }

    Component {
         id: ghostExitDialog
         Dialog {
             id: dialog
             title: i18n.tr("Leaving ghost mode")
             text: i18n.tr("Would you like to keep or discard your temporary guesses?")
             Button {
                 text: i18n.tr("Keep guesses")
                 color: UbuntuColors.green
                 onClicked: {
                     level.exitGhostMode(true);
                     PopupUtils.close(dialog);
                 }
             }
             Button {
                 text: i18n.tr("Discard guesses")
                 color: UbuntuColors.red
                 onClicked: {
                     level.exitGhostMode(false);
                     PopupUtils.close(dialog);
                 }
             }
             Button {
                 text: i18n.tr("Stay in ghost mode")
                 color: theme.palette.normal.overlaySecondaryText
                 onClicked: PopupUtils.close(dialog)
             }
         }
    }
}
