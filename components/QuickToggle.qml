import "../config"
import QtQuick

Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool checked: false
    property bool live: false
    // habilita os cliques: corpo emite activated(), switch emite toggled()
    property bool interactive: false

    signal toggled()
    signal activated()

    radius: Theme.radius
    color: bodyArea.containsMouse && root.interactive ? Theme.cardHover : Theme.card
    border.width: 1
    border.color: Theme.stroke
    antialiasing: true
    implicitHeight: 92

    Behavior on color { ColorAnimation { duration: Theme.tFast } }

    // corpo do card: expande/aciona a ação principal
    MouseArea {
        id: bodyArea
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.activated()
    }

    Row {
        anchors.fill: parent
        anchors.margins: Theme.pad
        spacing: Theme.pad

        Rectangle {
            width: 40
            height: 40
            radius: 20
            antialiasing: true
            color: root.checked ? Theme.accentSoft : Theme.accentTrack

            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.iconFont
                font.pixelSize: 17
                color: root.checked ? Theme.accentActive : Theme.textDim
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 108
            spacing: 3

            Text {
                width: parent.width
                text: root.title
                font.pixelSize: Theme.fsLabel
                color: Theme.text
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.subtitle
                font.pixelSize: Theme.fsBody
                color: Theme.textDim
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 42
            height: 24

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: root.checked ? Theme.accentActive : Theme.accentTrack
                opacity: root.live ? 1 : 0.7

                Behavior on color { ColorAnimation { duration: Theme.tFast } }
            }

            Rectangle {
                width: 18
                height: 18
                radius: 9
                y: 3
                x: root.checked ? 21 : 3
                color: root.checked ? Theme.textOnAccent : Theme.text
                Behavior on x { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
            }

            // o switch fica por cima do corpo: clique aqui só alterna
            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                enabled: root.interactive
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggled()
            }
        }
    }
}
