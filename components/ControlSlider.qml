import "../config"
import QtQuick

Rectangle {
    id: root

    property string glyph: ""
    property string label: ""
    property real value: 0
    property string detail: ""
    property bool live: false

    radius: Theme.radius
    color: Theme.card
    border.width: 1
    border.color: Theme.stroke
    antialiasing: true
    implicitHeight: 96

    Column {
        anchors.fill: parent
        anchors.margins: Theme.pad
        spacing: Theme.gap

        Row {
            width: parent.width
            spacing: Theme.gap

            Text {
                text: root.glyph
                font.family: Theme.iconFont
                font.pixelSize: 16
                color: root.live ? Theme.accent : Theme.textDim
            }

            Text {
                text: root.label
                font.pixelSize: Theme.fsLabel
                color: Theme.text
            }

            Item { width: Math.max(0, parent.width - percentBadge.width - 120); height: 1 }

            Rectangle {
                id: percentBadge
                width: percentText.implicitWidth + 16
                height: 24
                radius: 12
                color: root.live ? Theme.accentSoft : Theme.accentTrack

                Text {
                    id: percentText
                    anchors.centerIn: parent
                    text: Math.round(Math.max(0, Math.min(1, root.value)) * 100) + "%"
                    font.pixelSize: 11
                    color: root.live ? Theme.accentActive : Theme.textDim
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 12
            radius: 6
            color: Theme.accentTrack
            antialiasing: true

            Rectangle {
                width: Math.max(height, parent.width * Math.max(0, Math.min(1, root.value)))
                height: parent.height
                radius: parent.radius
                color: root.live ? Theme.accentActive : Theme.accent
                opacity: root.live ? 1 : 0.5
                antialiasing: true
                Behavior on width { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            visible: root.detail.length > 0
            text: root.detail
            font.pixelSize: Theme.fsBody
            color: Theme.textDim
            wrapMode: Text.Wrap
        }
    }
}
