import QtMultimedia 5.0
import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root
    property var gameData
    property real blockSize: units.gu(1)

    /*SoundEffect {
        id: pop2
        muted: mainView.muted
        source: Qt.resolvedUrl("sound/pop2.wav")
    }

    SoundEffect {
        id: pop3
        muted: mainView.muted
        source: Qt.resolvedUrl("sound/pop3.wav")
    }*/

    Grid {
        id: grid
        columns: root.gameData.columns
        property var modes: root.gameData.modes
        property int lastMode: 0
        Repeater {
            id: boxRepeater
            model: root.gameData.columns * root.gameData.rows

            Box {
                id: box
                height: blockSize
                width: blockSize
                level: root.gameData
                n: index

                Rectangle {
                    property bool isThick: index % 5 == 0 || index % root.gameData.columns == 0
                    width: units.dp(isThick ? 2 : 1)
                    anchors.left: parent.left
                    anchors.leftMargin: isThick ? -units.dp(1) : 0
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "black"
                    visible: !root.gameData.finished
                }
                Rectangle {
                    property bool isThick: index % (root.gameData.columns * 5) < root.gameData.columns
                    height: units.dp(isThick ? 2 : 1)
                    anchors.top: parent.top
                    anchors.topMargin: isThick ? -units.dp(1) : 0
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: "black"
                    visible: !root.gameData.finished
                }

                function setGuess(g) {
                    level.setGuess(n, g);
                }

                MouseArea {
                    anchors.fill: parent
                    property var startMode
                    enabled: !level.ghostMode || !box.isRealGuess
                    onClicked: {
                        /*if (guess == "") {
                            pop3.play();
                        } else {
                            pop2.play();
                        }*/

                        // 1/5 haptics, but it tends to feel like normal haptics anyway...
                        Haptics.play({attackTime: 10, fadeTime: 10, duration: 2, intensity: 0.2});

                        if (guess == "") {
                            box.setGuess(grid.modes[grid.lastMode]);
                            startMode = grid.lastMode;
                        } else {
                            for (var i = 0; i < grid.modes.length - 1; i++) {
                                var modeIndex = (i + startMode) % grid.modes.length;
                                if (guess == grid.modes[modeIndex]) {
                                    var nextMode = (modeIndex + 1) % grid.modes.length;
                                    box.setGuess(grid.modes[nextMode]);
                                    grid.lastMode = nextMode;
                                    break;
                                }
                            }
                            if (i == grid.modes.length - 1) {
                                box.setGuess("");
                                grid.lastMode = 0;
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: units.dp(2)
        anchors.right: grid.right
        anchors.top: grid.top
        anchors.bottom: grid.bottom
        color: "black"
        visible: !root.gameData.finished
    }
    Rectangle {
        height: units.dp(2)
        anchors.bottom: grid.bottom
        anchors.left: grid.left
        anchors.right: grid.right
        color: "black"
        visible: !root.gameData.finished
    }
}
