import QtQuick 2.4
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Neverbore 1.0 as NB

Rectangle {
    id: root

    property var level

    QtObject {
        id: d
        property real margin: units.gu(3)
        property int numHorizontalBlocks: level.columns + (level.finished ? 0 : level.rowHintsDepth)
        property int numVerticalBlocks: level.rows + (level.finished ? 0 : level.columnHintsDepth)
    }

    color: "transparent"

    function blockSizeForSize(width, height) {
        return Math.min(units.gu(6),
                        Math.min((width - d.margin * 2) / d.numHorizontalBlocks,
                                 (height - d.margin * 2) / d.numVerticalBlocks));
    }
    function widthForBlockSize(blockSize) {
        return blockSize * d.numHorizontalBlocks + d.margin * 2;
    }
    function heightForBlockSize(blockSize) {
        return blockSize * d.numVerticalBlocks + d.margin * 2;
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: root.width
        contentHeight: root.height

        PinchArea {
            width: Math.max(flick.contentWidth, flick.width)
            height: Math.max(flick.contentHeight, flick.height)

            property real initialWidth
            property real initialHeight
            onPinchStarted: {
                initialWidth = flick.contentWidth;
                initialHeight = flick.contentHeight;
            }

            onPinchUpdated: {
                // adjust content pos due to drag
                flick.contentX += pinch.previousCenter.x - pinch.center.x;
                flick.contentY += pinch.previousCenter.y - pinch.center.y;

                // resize content
                var targetWidth = initialWidth * pinch.scale;
                var targetHeight = initialHeight * pinch.scale;
                var targetBlockSize = blockSizeForSize(targetWidth, targetHeight);
                var origTWidth = targetWidth;
                var origTHeight = targetHeight;
                targetWidth = Math.min(targetWidth, widthForBlockSize(targetBlockSize))
                targetHeight = Math.min(targetHeight, heightForBlockSize(targetBlockSize))
                targetWidth = Math.max(targetWidth, root.width)
                targetHeight = Math.max(targetHeight, root.height)

                flick.resizeContent(targetWidth, targetHeight, pinch.center);
            }

            onPinchFinished: {
                // Move its content within bounds.
                flick.returnToBounds();
            }

            Item {
                id: board
                width: flick.contentWidth
                height: flick.contentHeight
                property real blockSize: blockSizeForSize(width, height)

                Item {
                    anchors.centerIn: parent
                    width: d.numHorizontalBlocks * board.blockSize
                    height: d.numVerticalBlocks * board.blockSize

                    HintsHeader {
                        id: columnHints
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: rowHints.width
                        level: root.level
                        blockSize: board.blockSize
                        isColumns: true
                    }

                    HintsHeader {
                        id: rowHints
                        anchors.top: columnHints.bottom
                        anchors.left: parent.left
                        level: root.level
                        blockSize: board.blockSize
                    }

                    GameGrid {
                        id: grid
                        anchors.top: columnHints.bottom
                        anchors.left: rowHints.right
                        gameData: root.level
                        blockSize: board.blockSize
                        enabled: !level.finished
                    }
                }
            }
        }
    }
}
