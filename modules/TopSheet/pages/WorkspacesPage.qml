import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

// Visão "alt-tab": grade de janelas abertas com preview ao vivo. Clique foca a
// janela (Windows.focus → activate() typed). Sem cards de texto.
Item {
    id: root

    property var screenRef

    // pede o fechamento do painel após focar uma janela (ver a janela).
    signal requestClose()

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Flow {
            id: grid
            width: parent.width
            spacing: Theme.gap
            visible: Windows.hasWindows

            readonly property int cols: root.width > 1040 ? 3 : 2
            readonly property real cellW: (width - Theme.gap * (cols - 1)) / cols

            Repeater {
                model: Windows.windowList
                delegate: WindowThumb {
                    required property var modelData
                    toplevel: modelData
                    width: grid.cellW
                    height: grid.cellW * 0.62
                    onActivated: {
                        Windows.focus(modelData);
                        root.requestClose();
                    }
                }
            }
        }

        // estado vazio
        Rectangle {
            width: parent.width
            height: 120
            radius: Theme.radius
            color: Theme.card
            visible: !Windows.hasWindows

            Text {
                anchors.centerIn: parent
                text: "Nenhuma janela aberta."
                font.pixelSize: Theme.fsLabel
                color: Theme.textDim
            }
        }
    }
}
