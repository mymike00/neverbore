import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root

    property var level
    property int n
    readonly property alias guess: d.guess
    readonly property alias isRealGuess: d.isRealGuess
    color: "transparent"

    QtObject {
        id: d
        property string guess
        property bool isRealGuess
        function updateGuesses() {
            // I should really make this binding better
            guess = level.guess(n);
            isRealGuess = level.realGuess(n) != "";
        }
    }
    Component.onCompleted: d.updateGuesses()
    Connections {
        target: level
        onGuessesChanged: d.updateGuesses()
        onGhostModeChanged: d.updateGuesses()
    }

    Rectangle {
        anchors.fill: parent
        visible: guess != "blank" && guess != ""
        color: guess
        opacity: isRealGuess ? 1 : 0.5
    }
    Image {
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: guess == "blank" && !level.finished
        source: Qt.resolvedUrl("graphics/cross.svg")
        opacity: isRealGuess ? 1 : 0.5
    }
}
