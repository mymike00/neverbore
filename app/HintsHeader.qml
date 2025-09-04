import QtQuick 2.4
import Lomiri.Components 1.3

Rectangle {
    id: root
    property var level
    property bool isColumns: false
    property real blockSize: units.gu(1)

    color: "transparent"
    width: childrenRect.width
    height: childrenRect.height

    Grid {
        columns: isColumns ? level.columns : 0
        rows: isColumns ? 0 : level.rows
        flow: isColumns ? Grid.LeftToRight : Grid.TopToBottom
        verticalItemAlignment: Grid.AlignBottom
        horizontalItemAlignment: Grid.AlignRight
        Repeater {
            id: boxRepeater
            model: level.finished ? 0 : isColumns ? level.columns : level.rows
            Rectangle {
                id: hintBox
                width: Math.max(childrenRect.width, root.blockSize)
                height: Math.max(childrenRect.height, root.blockSize)
                color: "transparent"
                property bool isWrong: isColumns ? !root.level.columnStates[index] : !root.level.rowStates[index]
                property var hints: isColumns ? root.level.getColumnHints(index) : root.level.getRowHints(index)
                property var hintColors: isColumns ? root.level.getColumnHintColors(index) : root.level.getRowHintColors(index)
                Grid {
                    columns: isColumns ? 0 : hintBox.hints.length
                    rows: isColumns ? hintBox.hints.length: 0
                    flow: isColumns ? Grid.TopToBottom : Grid.LeftToRight
                    Repeater {
                        model: hintBox.hints.length
                        Rectangle {
                            height: blockSize
                            width: blockSize
                            color: hintBox.hintColors[index]
                            Label {
                                anchors.fill: parent
                                text: hintBox.hints[index]
                                fontSizeMode: Text.Fit
                                font.pixelSize: 100
                                color: hintBox.isWrong ? "red" : "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
