import "../config"
import QtQuick

// Aba do drawer do topo: glyph + label, com sublinhado clay animado no ativo.
Item {
    id: root

    property string glyph: ""
    property string label: ""
    property bool active: false
    signal clicked()

    readonly property bool hovered: hover.hovered
    implicitWidth: Math.max(96, col.implicitWidth + Theme.pad * 2)
    implicitHeight: 58

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 3
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.glyph
            font.family: Theme.iconFont
            font.pixelSize: 18
            color: (root.active || root.hovered) ? Theme.accent : Theme.textDim
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.pixelSize: 12
            font.bold: root.active
            color: root.active ? Theme.text
                 : root.hovered ? Theme.text
                 : Theme.textDim
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }
    }

    // sublinhado ativo
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.active ? 26 : 0
        height: 3
        radius: 2
        antialiasing: true
        color: Theme.accent
        Behavior on width { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }
    }

    HoverHandler { id: hover }
    TapHandler { onTapped: root.clicked() }
}
