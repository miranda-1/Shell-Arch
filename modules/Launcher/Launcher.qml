import "../../config"
import "../../components"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Launcher: faixa de hover no rodapé-centro faz um painel SUBIR (slide-up +
// fade). Campo de busca + lista de apps — tudo FAKE, nada executa.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors { bottom: true; left: true; right: true }
    exclusiveZone: 0
    implicitHeight: 540
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top

    readonly property int sliverW: 220
    // hover com pequeno atraso: evita abrir o launcher só ao passar no rodapé
    property bool hovering: sliverHover.hovered || cardHover.hovered
    property bool open: false
    Timer { id: openTimer; interval: 110; onTriggered: root.open = true }
    onHoveringChanged: {
        if (root.hovering) openTimer.start()
        else { openTimer.stop(); root.open = false }
    }

    mask: Region {
        x: root.open ? Math.round(card.x) : Math.round((root.width - root.sliverW) / 2)
        y: root.open ? Math.round(card.y) : (root.height - 14)
        width: root.open ? Math.ceil(card.width) : root.sliverW
        height: root.open ? Math.ceil(card.height) : 14
    }

    // faixa de hover (rodapé-centro) — invisível, levemente maior p/ mira fácil
    Item {
        id: sliver
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: root.sliverW
        height: 14
        HoverHandler { id: sliverHover }
    }

    // puxador autônomo: discreto, sem depender de moldura contínua
    Rectangle {
        id: grip
        anchors { bottom: parent.bottom; bottomMargin: 7; horizontalCenter: parent.horizontalCenter }
        width: Theme.gripLen
        height: Theme.gripThickness
        radius: height / 2
        antialiasing: true
        color: root.open ? Theme.gripHover : Theme.gripColor
        opacity: root.open ? 0 : 1
        scale: sliverHover.hovered ? 1.04 : 1.0
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }

    Card {
        id: card
        width: 680
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.open ? Theme.gap : -(height + 30)
        opacity: root.open ? 1 : 0
        height: col.implicitHeight + Theme.pad * 2

        HoverHandler { id: cardHover }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.pad }
            spacing: Theme.gap

            // resultados (fake)
            Repeater {
                model: [
                    { glyph: "", title: "Wallpaper", sub: "Change the current wallpaper" },
                    { glyph: "", title: "Files", sub: "Browse your files" },
                    { glyph: "", title: "Terminal", sub: "Open a terminal session" },
                    { glyph: "", title: "Settings", sub: "System configuration" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: parent.width
                    height: 58
                    radius: Theme.radiusSm
                    antialiasing: true
                    color: rowHover.hovered ? Theme.accentSoft : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.tFast } }

                    HoverHandler { id: rowHover }

                    Row {
                        anchors { left: parent.left; leftMargin: Theme.pad; verticalCenter: parent.verticalCenter }
                        spacing: Theme.pad
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 38; height: 38; radius: Theme.radiusSm
                            antialiasing: true
                            color: Theme.card
                            Text { anchors.centerIn: parent; text: modelData.glyph; font.family: Theme.iconFont; font.pixelSize: 18; color: Theme.accent }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text { text: modelData.title; font.pixelSize: 15; color: Theme.text }
                            Text { text: modelData.sub; font.pixelSize: 12; color: Theme.textDim }
                        }
                    }
                }
            }

            // campo de busca (fake)
            Rectangle {
                width: parent.width
                height: 50
                radius: height / 2
                antialiasing: true
                color: Theme.accentTrack
                Row {
                    anchors { left: parent.left; leftMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                    spacing: Theme.gap
                    Text { anchors.verticalCenter: parent.verticalCenter; text: ""; font.family: Theme.iconFont; font.pixelSize: 16; color: Theme.textDim }  // lupa
                    Text { anchors.verticalCenter: parent.verticalCenter; text: ">wa"; font.pixelSize: 15; color: Theme.text }
                }
                Text {
                    anchors { right: parent.right; rightMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                    text: ""   // x
                    font.family: Theme.iconFont
                    font.pixelSize: 14
                    color: Theme.textDim
                }
            }
        }
    }
}
