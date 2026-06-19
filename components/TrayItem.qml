import "../config"
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

// Um ícone do SystemTray na EdgeLeft. Esquerda = activate (abrir/focar o app),
// meio = secondaryActivate, direita = pedir o menu de contexto (DBus) ao pai.
Item {
    id: root

    required property var modelData   // SystemTrayItem

    // Emitido no clique direito (ou esquerdo quando o item só tem menu); o pai
    // (EdgeLeft) abre o menu ancorado ao `source` (este próprio delegate).
    signal menuRequested(var item, var source)

    implicitWidth: Theme.barW
    implicitHeight: 30

    readonly property bool hovered: hover.hovered
    readonly property string tipLabel: root.modelData.tooltipTitle
        || root.modelData.title
        || root.modelData.id

    Rectangle {
        anchors.centerIn: parent
        width: Theme.iconSize + 12
        height: Theme.iconSize + 12
        radius: Theme.radiusSm
        antialiasing: true
        color: mouse.pressed ? Theme.accentPressed
             : root.hovered ? Theme.accentSoft
             : Qt.rgba(Theme.accentSoft.r, Theme.accentSoft.g, Theme.accentSoft.b, 0)
        scale: mouse.pressed ? 0.92 : root.hovered ? 1.08 : 1.0

        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }

    IconImage {
        anchors.centerIn: parent
        implicitSize: Theme.iconSize
        source: root.modelData.icon
        asynchronous: true
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: (ev) => {
            if (ev.button === Qt.LeftButton) {
                if (root.modelData.onlyMenu)
                    root.menuRequested(root.modelData, root);
                else
                    root.modelData.activate();
            } else if (ev.button === Qt.MiddleButton) {
                root.modelData.secondaryActivate();
            } else if (ev.button === Qt.RightButton) {
                root.menuRequested(root.modelData, root);
            }
        }
    }

    // Tooltip à direita da barra (mesma linguagem dos outros botões da EdgeLeft).
    Item {
        id: tip
        visible: opacity > 0 && root.tipLabel.length > 0
        opacity: root.hovered && root.tipLabel.length > 0 ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        x: root.width + Theme.gap + (root.hovered ? 0 : -6)
        width: tipBg.width
        height: tipBg.height

        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on x { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }

        Rectangle {
            id: tipBg
            width: Math.min(tipText.implicitWidth, 240) + Theme.pad * 2
            height: tipText.implicitHeight + Theme.gap * 2
            radius: Theme.radiusSm
            antialiasing: true
            color: Theme.accentActive
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.14)

            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.tipLabel
                color: Theme.textOnAccent
                font.pixelSize: 13
                width: Math.min(implicitWidth, 240)
                wrapMode: Text.Wrap
            }
        }
    }
}
