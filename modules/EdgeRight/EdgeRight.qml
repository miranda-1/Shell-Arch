import "../../config"
import "../../components"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Borda direita: tabs/pílulas clay espiando na borda. Hover na rail desliza um
// card para a esquerda com sliders FAKE (volume/brilho) + pílulas de estado.
// Glyphs Nerd Font via escapes \uXXXX.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors { right: true; top: true; bottom: true }
    exclusiveZone: 0
    implicitWidth: 380
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top

    readonly property int railW: 34
    readonly property int handleHotspotW: 18
    readonly property int handleLen: 72
    // Hover unificado: um único HoverHandler cobre a janela e a MÁSCARA define a
    // área interativa. Em repouso = só o hotspot do puxador; aberto = do card até
    // a borda direita (puxador + corredor + card formam UMA região contígua, sem
    // vão morto). Abrir tem atraso (anti-acidental); fechar tem atraso (segura o
    // painel enquanto o mouse cruza do puxador para dentro).
    property bool hovering: hover.hovered
    property bool open: false
    Timer { id: openTimer; interval: Theme.tHoverOpen; onTriggered: root.open = true }
    Timer { id: closeTimer; interval: Theme.tHoverClose; onTriggered: root.open = false }
    onHoveringChanged: {
        if (root.hovering) { closeTimer.stop(); openTimer.start() }
        else { openTimer.stop(); closeTimer.start() }
    }

    mask: Region {
        x: root.open ? Math.round(card.x) : (root.width - root.handleHotspotW)
        y: root.open ? Math.round(card.y) : Math.round((root.height - root.handleLen) / 2)
        width: root.open ? Math.ceil(root.width - card.x) : root.handleHotspotW
        height: root.open ? Math.ceil(card.height) : root.handleLen
    }

    // HoverHandler único — recebe eventos só dentro da máscara, então acompanha
    // exatamente a região contígua acima.
    Item { anchors.fill: parent; HoverHandler { id: hover } }

    // puxador vertical autônomo — único elemento em repouso. Os controles de
    // som/brilho NÃO se repetem aqui fora: vivem só no card aberto (sem redundância).
    Rectangle {
        id: handle
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        width: Theme.gripThickness
        height: root.handleLen
        radius: width / 2
        antialiasing: true
        color: hover.hovered ? Theme.gripHover : Theme.gripColor
        opacity: root.open ? 0 : 1
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
    }

    // card que desliza para a esquerda
    Card {
        id: card
        width: 300
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: root.open ? (root.railW + Theme.gap) : -(width + 30)
        opacity: root.open ? 1 : 0
        height: col.implicitHeight + Theme.pad * 2

        Behavior on anchors.rightMargin { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        Column {
            id: col
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: Theme.pad }
            spacing: Theme.pad

            SectionHeader { text: "CONTROLES" }

            SliderPill { width: parent.width; glyph: ""; value: 0.62 }   // volume
            SliderPill { width: parent.width; glyph: ""; value: 0.80 }   // brilho

            Row {
                spacing: Theme.gap
                Pill {
                    width: pillWifi.implicitWidth + Theme.pad * 2; height: 34
                    color: Theme.accentSoft
                    Row {
                        id: pillWifi
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: ""; font.family: Theme.iconFont; font.pixelSize: 13; color: Theme.accent }
                        Text { text: "SHJJJ_WLAN"; font.pixelSize: 12; color: Theme.text }
                    }
                }
                Pill {
                    width: pillBt.implicitWidth + Theme.pad * 2; height: 34
                    color: Theme.accentSoft
                    Row {
                        id: pillBt
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: ""; font.family: Theme.iconFont; font.pixelSize: 13; color: Theme.accent }
                        Text { text: "On"; font.pixelSize: 12; color: Theme.text }
                    }
                }
            }
        }
    }
}
