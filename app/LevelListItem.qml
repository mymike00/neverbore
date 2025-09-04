import QtQuick 2.4
import Lomiri.Components 1.3

MenuListItem {
   id: listItem

   property var level: null
   property var pack: null
   signal view()

   title.text: level ? level.name : pack.name
   progression: true
   iconName: level ? (level.finished ? "starred" : (level.anyGuessed ? "non-starred" : "next")) : (pack ? (pack.finished ? "starred" : "next") : "next")

   trailingActions: level ? d.actions : null
   onClicked: view()

   QtObject {
      id: d

      property var actions: ListItemActions {
         actions: [
         Action {
            visible: level ? level.anyGuessed : false
            iconName: "reset"
            onTriggered: {
               Haptics.play();
               level.clearGuesses();
            }
         }
         ]
      }
   }

   Label {
      text: level ? level.rows + "×" + level.columns : ""
      opacity: 0.5
      SlotsLayout.position: SlotsLayout.Trailing
   }
}
