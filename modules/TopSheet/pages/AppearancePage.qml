import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        // ---------- Tema ----------
        Text {
            text: "Tema"
            font.pixelSize: Theme.fsLabel
            color: Theme.textDim
        }

        Flow {
            width: parent.width
            spacing: Theme.gap

            Repeater {
                model: Appearance.themes

                delegate: Rectangle {
                    required property var modelData

                    width: tLabel.implicitWidth + 28
                    height: 40
                    radius: Theme.radiusSm
                    color: tHover.hovered ? Theme.accentActive : Theme.card
                    border.width: 1
                    border.color: Theme.stroke
                    antialiasing: true

                    Behavior on color { ColorAnimation { duration: Theme.tFast } }

                    HoverHandler { id: tHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: Appearance.setTheme(modelData) }

                    Text {
                        id: tLabel
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: Theme.fsBody
                        color: tHover.hovered ? Theme.textOnAccent : Theme.text
                    }
                }
            }
        }

        // ---------- Imagem de fundo ----------
        Text {
            text: "Imagem de fundo"
            font.pixelSize: Theme.fsLabel
            color: Theme.textDim
        }

        Row {
            width: parent.width
            spacing: Theme.gap

            Repeater {
                model: [
                    { label: "Anterior",  act: function() { Appearance.prevWallpaper(); } },
                    { label: "Próximo",   act: function() { Appearance.nextWallpaper(); } },
                    { label: "Aleatório", act: function() { Appearance.randomWallpaper(); } },
                    { label: "Escolher…", act: function() { Appearance.selectWallpaper(); } }
                ]

                delegate: Rectangle {
                    required property var modelData

                    width: (parent.width - Theme.gap * 3) / 4
                    height: 48
                    radius: Theme.radiusSm
                    color: wHover.hovered ? Theme.accentActive : Theme.card
                    border.width: 1
                    border.color: Theme.stroke
                    antialiasing: true

                    Behavior on color { ColorAnimation { duration: Theme.tFast } }

                    HoverHandler { id: wHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: modelData.act() }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: Theme.fsBody
                        color: wHover.hovered ? Theme.textOnAccent : Theme.text
                    }
                }
            }
        }

        Text {
            width: parent.width
            text: "Tema e wallpaper aplicam no HyDE real (via hyde-shell)."
            font.pixelSize: Theme.fsCaption
            color: Theme.textFaint
            wrapMode: Text.Wrap
        }
    }
}
