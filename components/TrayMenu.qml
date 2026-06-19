import "../config"
import QtQuick
import Quickshell

// Conteúdo de um menu de contexto de tray (DBusMenu) renderizado no tema da
// shell (P&B). Navega submenus por uma pilha simples e emite `closed()` quando
// um item é acionado. Sem Process: tudo via a API typed do Quickshell.
Item {
    id: root

    // DBusMenuHandle do item (modelData.menu).
    property var menuHandle: null
    signal closed()

    // Pilha de navegação de submenus; o topo (ou a raiz) é o handle ativo.
    property var navStack: []
    readonly property var activeHandle: root.navStack.length > 0
        ? root.navStack[root.navStack.length - 1]
        : root.menuHandle
    readonly property bool inSubMenu: root.navStack.length > 0

    // Volta à raiz sempre que o handle de origem muda (menu reaberto).
    onMenuHandleChanged: root.navStack = []

    readonly property int menuWidth: 240
    implicitWidth: menuWidth
    implicitHeight: layout.implicitHeight + Theme.gap

    QsMenuOpener {
        id: opener
        menu: root.activeHandle
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusSm
        color: Theme.surfaceStrong
        border.width: 1
        border.color: Theme.strokeStrong
    }

    Column {
        id: layout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: Theme.gap / 2
            topMargin: Theme.gap / 2
        }
        spacing: 1

        // Linha "Voltar" quando dentro de um submenu.
        MenuRow {
            visible: root.inSubMenu
            label: "Voltar"
            leadingGlyph: ""
            onActivated: root.navStack = root.navStack.slice(0, -1)
        }

        Repeater {
            model: opener.children

            Loader {
                id: entryLoader
                required property var modelData
                width: parent ? parent.width : 0
                sourceComponent: entryLoader.modelData.isSeparator ? sepComp : rowComp

                Component {
                    id: sepComp
                    Item {
                        width: entryLoader.width
                        height: 7
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width - Theme.gap
                            height: 1
                            color: Theme.stroke
                        }
                    }
                }

                Component {
                    id: rowComp
                    MenuRow {
                        width: entryLoader.width
                        label: entryLoader.modelData.text
                        enabled: entryLoader.modelData.enabled
                        hasChildren: entryLoader.modelData.hasChildren
                        // glyph de marcação p/ checkbox/radio marcado (Qt.Checked === 2)
                        leadingGlyph: entryLoader.modelData.checkState === 2 ? "" : ""
                        onActivated: {
                            const entry = entryLoader.modelData;
                            if (entry.hasChildren) {
                                root.navStack = root.navStack.concat([entry]);
                            } else {
                                entry.triggered();
                                root.closed();
                            }
                        }
                    }
                }
            }
        }
    }

    // Linha reutilizável do menu.
    component MenuRow: Item {
        id: menuRow

        property string label: ""
        property string leadingGlyph: ""
        property bool hasChildren: false
        // usa o `enabled` nativo do Item: quando false, os handlers abaixo já
        // ficam inertes e o item de menu desabilitado não responde a clique.

        signal activated()

        width: 100
        implicitWidth: 100
        height: 30

        readonly property bool hovered: rowHover.hovered && menuRow.enabled

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.radiusSm - 4
            color: rowTap.pressed && menuRow.enabled ? Theme.accentPressed
                 : menuRow.hovered ? Theme.accentSoft
                 : "transparent"

            Behavior on color { ColorAnimation { duration: Theme.tFast } }
        }

        Text {
            id: lead
            anchors {
                left: parent.left
                leftMargin: Theme.gap
                verticalCenter: parent.verticalCenter
            }
            visible: menuRow.leadingGlyph.length > 0
            text: menuRow.leadingGlyph
            font.family: Theme.iconFont
            font.pixelSize: Theme.glyphSm
            color: Theme.textDim
        }

        Text {
            anchors {
                left: lead.visible ? lead.right : parent.left
                leftMargin: lead.visible ? 6 : Theme.gap
                right: chevron.visible ? chevron.left : parent.right
                rightMargin: 6
                verticalCenter: parent.verticalCenter
            }
            text: menuRow.label
            color: menuRow.enabled ? Theme.text : Theme.textFaint
            font.pixelSize: Theme.fsBodyLg
            elide: Text.ElideRight
        }

        Text {
            id: chevron
            anchors {
                right: parent.right
                rightMargin: Theme.gap
                verticalCenter: parent.verticalCenter
            }
            visible: menuRow.hasChildren
            text: ""
            font.family: Theme.iconFont
            font.pixelSize: Theme.glyphSm
            color: Theme.textDim
        }

        HoverHandler {
            id: rowHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            id: rowTap
            acceptedButtons: Qt.LeftButton
            onTapped: menuRow.activated()
        }
    }
}
