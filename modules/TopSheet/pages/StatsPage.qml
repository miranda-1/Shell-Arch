import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    // glyphs preenchidos via script (PUA some no editor)
    property string glyphCpu: ""
    property string glyphMem: "󰍛"
    property string glyphTemp: ""

    Column {
        id: content
        width: root.width
        spacing: Theme.gap

        Repeater {
            model: [
                { glyph: root.glyphCpu,  label: "CPU",         value: Stats.cpuPercent,          text: Stats.cpuText },
                { glyph: root.glyphMem,  label: "Memória",     value: Stats.memPercent,          text: Stats.memText },
                { glyph: root.glyphTemp, label: "Temperatura", value: Math.min(100, Stats.tempC), text: Stats.tempText }
            ]

            delegate: Rectangle {
                required property var modelData

                width: parent.width
                height: 56
                radius: Theme.radius
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true

                Rectangle {
                    id: sGlyphBg
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    radius: 18
                    antialiasing: true
                    color: Theme.accentSoft

                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        font.family: Theme.iconFont
                        font.pixelSize: 16
                        color: Theme.accentActive
                    }
                }

                Column {
                    anchors.left: sGlyphBg.right
                    anchors.leftMargin: Theme.pad
                    anchors.right: sValue.left
                    anchors.rightMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5

                    Text {
                        text: modelData.label
                        font.pixelSize: Theme.fsCaption
                        color: Theme.textDim
                    }

                    Rectangle {
                        width: parent.width
                        height: 8
                        radius: 4
                        color: Theme.accentTrack
                        antialiasing: true

                        Rectangle {
                            width: Math.max(height, parent.width * Math.max(0, Math.min(1, modelData.value / 100)))
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accentActive
                            antialiasing: true

                            Behavior on width { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }
                        }
                    }
                }

                Text {
                    id: sValue
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.text
                    font.pixelSize: Theme.fsLabel
                    font.bold: true
                    color: Theme.text
                }
            }
        }
    }
}
