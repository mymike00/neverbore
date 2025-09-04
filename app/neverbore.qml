import QtMultimedia 5.0
import QtQuick 2.4
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Neverbore 1.0 as NB

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "neverbore.mterry"
    automaticOrientation: true
    focus: true

    width: units.gu(50)
    height: units.gu(75)

    Keys.onPressed: {
        if (event.matches(StandardKey.Quit)) {
            actionManager.quit();
        }
    }

    property bool muted
    Settings {
        property alias muted: mainView.muted
    }
    Action {
        id: muteAction
        text: mainView.muted ? i18n.tr("Unmute") : i18n.tr("Mute")
        iconName: mainView.muted ? "audio-speakers-muted-symbolic" : "audio-speakers-symbolic"
        onTriggered: mainView.muted = !mainView.muted
    }

    Binding {
        target: NB.Levels
        property: "folder"
        value: Qt.resolvedUrl("../levels")
    }

    Audio {
        source: Qt.resolvedUrl("sound/happy.mp3")
        loops: MediaPlayer.Infinite

        readonly property bool shouldPlay: pageStack.allowMusic
                                           && pageStack.currentPage.playMusic
                                           && !mainView.muted
                                           && Qt.application.active
        onShouldPlayChanged: update()
        Component.onCompleted: update()
        function update() {
            if (shouldPlay) {
                play();
            } else {
                pause();
            }
        }
    }

    PageStack {
        id: pageStack
        property bool allowMusic: true

        function load(page) {
            // Don't push yet...  If we are starting up with StateSaver content,
            // the nested page loads will actually complete in reverse order.
            // We'll start with FrontPage, which will then push a GamePage on, etc.
            // But the pages don't get added to the stack until they are done.  So
            // GamePage ends up below FrontPage.  Instead, add them in a sec.
            delayTimer.page = page;
            delayTimer.start();
        }

        function replace(page) {
            allowMusic = currentPage.playMusic;
            pop();
            push(page);
            allowMusic = true;
        }

        Timer {
            id: delayTimer
            property string page
            interval: 0
            onTriggered: pageStack.push(page)
        }

        Component.onCompleted: push(Qt.resolvedUrl("FrontPage.qml"))
    }

    property int currentPackIndex: -1
    property int currentLevelIndex: -1
    StateSaver.properties: "currentPackIndex, currentLevelIndex"
    onCurrentLevelIndexChanged: {
        if (currentPackIndex < 0 || currentLevelIndex < 0) {
            NB.Levels.currentLevel = null;
        } else {
            var level = NB.Levels.getPack(currentPackIndex).getLevel(currentLevelIndex);
            if (!level.finished) {
                NB.Levels.currentLevel = level;
            }
        }
    }
}
