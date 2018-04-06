import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    title: i18n.tr("Credits")
    head.actions: [
        muteAction
    ]
    property bool playMusic: true

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("graphics/paper.png")
        fillMode: Image.Tile
    }

    ListView {
        anchors.fill: parent

        model: [
            i18n.tr("Programming by %1").arg("<b>Michael Terry</b>"),
            i18n.tr("Now maintained by %1").arg("<b>Michele Castellazzi</b>"),
            i18n.tr("Music by %1").arg('<b>Przemysław "Rezoner" Sikorski</b>'),
            i18n.tr("Art by %1").arg('<b>Sasha Goldberg</b>'),
            i18n.tr("Testing by %1").arg('<b>Sasha Goldberg</b>'),
            i18n.tr("Puzzles by %1").arg('<b>Michael Terry</b>')
        ]

        delegate: MenuListItem {
            enabled: false
            title.text: modelData
        }
    }
}
