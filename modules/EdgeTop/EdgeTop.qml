import "../../config"
import "../../components"
import "../Dashboard"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Borda superior: faixa de hover no topo-centro abre um drawer (overlay) que
// desce com slide-down + fade. Abas Dashboard/Media/Performance/Workspaces.
// Não reserva espaço (exclusiveZone 0); máscara restrita à faixa/drawer.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    exclusiveZone: 0
    implicitHeight: 640
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top

    // faixa de gatilho estreita, perto do puxador visível — não a meia-tela toda,
    // pra não abrir o drawer ao mirar a área central por outros motivos.
    readonly property int stripW: 260
    property int tab: 0
    // hover com atraso: evita abrir o drawer só ao passar o mouse no topo
    property bool hovering: stripHover.hovered || drawerHover.hovered
    property bool open: false
    Timer { id: openTimer; interval: Theme.tHoverOpen; onTriggered: root.open = true }
    onHoveringChanged: {
        if (root.hovering) openTimer.start()
        else { openTimer.stop(); root.open = false }
    }

    mask: Region {
        x: root.open ? Math.round(drawer.x) : Math.round((root.width - root.stripW) / 2)
        y: 0
        width: root.open ? Math.ceil(drawer.width) : root.stripW
        height: root.open ? Math.ceil(drawer.height) : 14
    }

    // faixa de hover (topo-centro) — invisível e um pouco mais alta p/ mira fácil
    Item {
        id: strip
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: root.stripW
        height: 14
        HoverHandler { id: stripHover }
    }

    // puxador autônomo: discreto, sem depender de moldura contínua
    Rectangle {
        id: grip
        anchors { top: parent.top; topMargin: 7; horizontalCenter: parent.horizontalCenter }
        width: Theme.gripLen
        height: Theme.gripThickness
        radius: height / 2
        antialiasing: true
        color: root.open ? Theme.gripHover : Theme.gripColor
        opacity: root.open ? 0 : 1
        scale: stripHover.hovered ? 1.04 : 1.0
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }

    // drawer
    Card {
        id: drawer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 880
        height: 470
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: Theme.radiusLg
        bottomRightRadius: Theme.radiusLg
        y: root.open ? 0 : -height - 16
        opacity: root.open ? 1 : 0

        HoverHandler { id: drawerHover }
        Behavior on y { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        // abas
        Row {
            id: tabbar
            anchors { top: parent.top; topMargin: Theme.gap; horizontalCenter: parent.horizontalCenter }
            spacing: Theme.pad
            TabButton { glyph: ""; label: "Dashboard";   active: root.tab === 0; onClicked: root.tab = 0 }
            TabButton { glyph: ""; label: "Media";       active: root.tab === 1; onClicked: root.tab = 1 }
            TabButton { glyph: ""; label: "Performance"; active: root.tab === 2; onClicked: root.tab = 2 }
            TabButton { glyph: ""; label: "Workspaces";  active: root.tab === 3; onClicked: root.tab = 3 }
        }

        Divider {
            id: divider
            // mesmas medidas do divisor inline anterior: recuo de Theme.pad nos
            // dois lados (largura = parent - 2*pad, centralizado → esquerda em pad).
            anchors { top: tabbar.bottom; topMargin: Theme.gap / 2; horizontalCenter: parent.horizontalCenter }
            width: parent.width - Theme.pad * 2
            height: 1
        }

        // conteúdo das abas
        Item {
            id: content
            anchors { top: divider.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: Theme.pad }

            // 0 — Dashboard
            Dashboard {
                anchors.centerIn: parent
                visible: opacity > 0
                opacity: root.tab === 0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
            }

            // 1 — Media
            Row {
                anchors.centerIn: parent
                spacing: 44
                visible: opacity > 0
                opacity: root.tab === 1 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 160; height: 160; radius: 80
                    antialiasing: true
                    color: Theme.accentSoft
                    Text { anchors.centerIn: parent; text: ""; font.family: Theme.iconFont; font.pixelSize: 60; color: Theme.accent }  // nota
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Text { text: "Bad Apple!! feat. nomico"; font.pixelSize: 22; color: Theme.text }
                    Text { text: "THE GAME"; font.pixelSize: 14; color: Theme.textDim }
                    Text { text: "Alstroemeria Records"; font.pixelSize: 14; color: Theme.textDim }
                    Row {
                        spacing: Theme.pad + 6
                        topPadding: 6
                        Text { text: ""; font.family: Theme.iconFont; font.pixelSize: 22; color: Theme.textDim }  // prev
                        Text { text: ""; font.family: Theme.iconFont; font.pixelSize: 28; color: Theme.accent }   // play
                        Text { text: ""; font.family: Theme.iconFont; font.pixelSize: 22; color: Theme.textDim }  // next
                    }
                    Row {
                        spacing: Theme.gap
                        topPadding: 6
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "0:10"; font.pixelSize: 12; color: Theme.textDim }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 280; height: 5; radius: 3; color: Theme.accentTrack
                            Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: parent.width * 0.03; radius: 3; color: Theme.accent }
                        }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: "5:17"; font.pixelSize: 12; color: Theme.textDim }
                    }
                }
            }

            // 2 — Performance
            Row {
                anchors.centerIn: parent
                spacing: 40
                visible: opacity > 0
                opacity: root.tab === 2 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                RingMeter { value: 0.54; big: "54°C"; sub: "GPU temp" }
                RingMeter { value: 0.41; big: "41°C"; sub: "CPU temp" }
                RingMeter { value: 0.23; big: "5.4GiB"; sub: "Memory" }
            }

            // 3 — Workspaces
            Grid {
                anchors.centerIn: parent
                columns: 5
                rowSpacing: Theme.gap
                columnSpacing: Theme.gap
                visible: opacity > 0
                opacity: root.tab === 3 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                Repeater {
                    model: 10
                    delegate: Rectangle {
                        required property int index
                        width: 140; height: 84; radius: Theme.radiusSm
                        antialiasing: true
                        color: index === 0 ? Theme.accentSoft : Theme.card
                        border.width: index === 0 ? 2 : 1
                        border.color: index === 0 ? Theme.accent : Theme.stroke
                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            font.pixelSize: 18
                            color: index === 0 ? Theme.accent : Theme.textDim
                        }
                    }
                }
            }
        }
    }
}
