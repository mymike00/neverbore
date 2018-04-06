import QtQuick 2.4
import Ubuntu.Components 1.3
import Neverbore 1.0 as NB

Page {
   id: frontPage

   title: "Neverbore Picross"
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

   Column {
      anchors.fill: parent

      MenuListItem {
         title.text: name ? i18n.tr("Continue <i>%1</i>").arg(name) : i18n.tr("Continue current puzzle")
         progression: true
         enabled: NB.Levels.currentLevel != null && !NB.Levels.currentLevel.finished
         active: enabled
         property string name: NB.Levels.currentLevel ? NB.Levels.currentLevel.name : ""

         onClicked: {
            var pack = NB.Levels.currentLevel.pack;
            mainView.currentPackIndex = NB.Levels.getPackIndex(pack);
            mainView.currentLevelIndex = pack.getLevelIndex(NB.Levels.currentLevel);
            nextPage = Qt.resolvedUrl("GamePage.qml");
         }
      }

      MenuListItem {
         title.text: i18n.tr("All puzzles")
         progression: true
         onClicked: nextPage = Qt.resolvedUrl("PacksPage.qml")
      }

      MenuListItem {
         title.text: i18n.tr("How to Play")
         progression: true
         onClicked: nextPage = Qt.resolvedUrl("HowToPage.qml")
      }

      MenuListItem {
         title.text: i18n.tr("Credits")
         progression: true
         onClicked: nextPage = Qt.resolvedUrl("CreditsPage.qml")
      }
   }
}
