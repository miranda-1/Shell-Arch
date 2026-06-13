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
        spacing: Theme.gap

        Repeater {
            model: Keybinds.binds

            delegate: Rectangle {
                required property var modelData

                width: parent.width
                height: 46
                radius: Theme.radiusSm
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true

                Rectangle {
                    id: comboPill
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    width: comboText.implicitWidth + 20
                    height: 28
                    radius: 8
                    color: Theme.accentSoft
                    antialiasing: true

                    Text {
                        id: comboText
                        anchors.centerIn: parent
                        text: modelData.combo
                        font.pixelSize: Theme.fsCaption
                        font.bold: true
                        color: Theme.accentActive
                    }
                }

                Text {
                    anchors.left: comboPill.right
                    anchors.leftMargin: Theme.pad
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.desc
                    font.pixelSize: Theme.fsBody
                    color: Theme.text
                    elide: Text.ElideRight
                }
            }
        }

        Text {
            visible: Keybinds.binds.length === 0
            width: parent.width
            text: "Não foi possível ler ~/.config/hypr/keybindings.conf."
            font.pixelSize: Theme.fsBody
            color: Theme.textDim
            wrapMode: Text.Wrap
        }
    }
}
