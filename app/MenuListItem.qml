import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    property alias text: label.text
    property bool progression
    property bool active: true

    onClicked: Haptics.play()

    color: "#fff"
    highlightColor: "#ddd"

    Label {
        id: label
        anchors.fill: parent
        anchors.margins: units.gu(2)
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        opacity: active ? 1 : 0.5
    }

    Icon {
        visible: progression
        name: "next"
        anchors.right: parent.right
        anchors.rightMargin: units.gu(1.5)
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(2)
        height: width
        opacity: active ? 1 : 0.5
    }
}
