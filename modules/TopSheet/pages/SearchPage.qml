import "../../../components"
import "../../../config"
import "../../../services"
import "../../Launcher"
import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    property bool open: false

    signal requestClose()

    implicitHeight: content.implicitHeight

    // seleção via teclado — sempre apontando para um índice válido da lista
    property int selectedIndex: 0
    readonly property int resultCount: appModel.apps.length
    readonly property bool searching: appModel.query.trim().length > 0

    readonly property string glyphSearch: ""   // lupa

    onResultCountChanged: {
        if (root.selectedIndex >= root.resultCount)
            root.selectedIndex = Math.max(0, root.resultCount - 1);
    }

    onOpenChanged: {
        if (root.open) {
            searchInput.text = "";
            root.selectedIndex = 0;
            searchInput.forceActiveFocus();
        }
    }

    function launchApp(app) {
        if (!app || !app.desktopEntry)
            return;

        // "me leve até o app": se já houver janela aberta, foca em vez de
        // relançar; senão, abre normalmente.
        if (!Hyprland.raiseByClass(app.classHints))
            app.desktopEntry.execute();

        root.requestClose();
    }

    function launchSelected() {
        if (root.resultCount === 0)
            return;

        root.launchApp(appModel.apps[Math.min(root.selectedIndex, root.resultCount - 1)]);
    }

    DesktopAppModel {
        id: appModel
        limit: 6
        query: searchInput.text
    }

    Column {
        id: content
        width: root.width
        spacing: Theme.gap

        // ---- campo de busca (sem pill dentro do input) ----
        Rectangle {
            id: searchField
            width: parent.width
            height: 64
            radius: 32
            antialiasing: true
            color: Theme.card
            border.width: 1
            border.color: searchInput.activeFocus ? Theme.strokeStrong : Theme.stroke

            TapHandler {
                onTapped: searchInput.forceActiveFocus()
            }

            HoverHandler {
                cursorShape: Qt.IBeamCursor
            }

            Text {
                id: searchGlyph
                anchors.left: parent.left
                anchors.leftMargin: Theme.pad + 8
                anchors.verticalCenter: parent.verticalCenter
                text: root.glyphSearch
                font.family: Theme.iconFont
                font.pixelSize: 18
                color: searchInput.activeFocus ? Theme.accent : Theme.textDim
            }

            TextInput {
                id: searchInput
                anchors.left: searchGlyph.right
                anchors.leftMargin: Theme.pad
                anchors.right: parent.right
                anchors.rightMargin: Theme.pad + 8
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                font.pixelSize: Theme.fsTitle
                clip: true
                selectionColor: Theme.accentSoft
                selectedTextColor: Theme.text
                renderType: Text.NativeRendering
                verticalAlignment: Text.AlignVCenter

                onTextChanged: root.selectedIndex = 0

                Keys.onReturnPressed: root.launchSelected()
                Keys.onEnterPressed: root.launchSelected()
                Keys.onDownPressed: {
                    if (root.resultCount > 0)
                        root.selectedIndex = Math.min(root.selectedIndex + 1, root.resultCount - 1);
                }
                Keys.onUpPressed: {
                    if (root.resultCount > 0)
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1);
                }
                Keys.onEscapePressed: {
                    if (searchInput.text.length > 0)
                        searchInput.text = "";
                    else
                        root.requestClose();
                }

                Component.onCompleted: {
                    if (root.open)
                        forceActiveFocus();
                }

                // placeholder ancorado ao próprio input — nunca por cima do texto
                Text {
                    visible: searchInput.text.length === 0
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Buscar aplicativos, ações e atalhos…"
                    font.pixelSize: Theme.fsTitle
                    color: Theme.textFaint
                }
            }
        }

        // ---- resultados ----
        Rectangle {
            width: parent.width
            implicitHeight: resultList.implicitHeight + Theme.pad * 2
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true
            clip: true

            Column {
                id: resultList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.pad
                spacing: Theme.gap

                // cabeçalho da seção: título à esquerda, dica de teclado à direita
                Item {
                    width: parent.width
                    height: sectionTitle.implicitHeight

                    Text {
                        id: sectionTitle
                        anchors.left: parent.left
                        text: root.searching ? "Resultados" : "Favoritos e frequentes"
                        font.pixelSize: Theme.fsLabel
                        color: Theme.textDim
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "↑ ↓ navegam  ·  Enter abre  ·  Esc fecha"
                        font.pixelSize: Theme.fsCaption
                        color: Theme.textFaint
                    }
                }

                Repeater {
                    model: appModel.apps

                    delegate: Rectangle {
                        id: resultRow

                        required property var modelData
                        required property int index

                        readonly property bool selected: index === root.selectedIndex

                        width: parent.width
                        height: 58
                        radius: Theme.radius
                        antialiasing: true
                        color: resultRow.selected ? Theme.accentSoft : Theme.accentTrack
                        border.width: 1
                        border.color: resultRow.selected ? Theme.strokeStrong : Theme.stroke

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler {
                            cursorShape: Qt.PointingHandCursor
                            onHoveredChanged: {
                                if (hovered)
                                    root.selectedIndex = resultRow.index;
                            }
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.launchApp(resultRow.modelData)
                        }

                        Rectangle {
                            id: rowIcon
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.gap
                            anchors.verticalCenter: parent.verticalCenter
                            width: 38
                            height: 38
                            radius: 19
                            antialiasing: true
                            color: Theme.card

                            // ícone real do app; cai para a inicial quando o
                            // tema de ícones não resolve.
                            readonly property string resolvedIcon: resultRow.modelData.icon
                                ? Quickshell.iconPath(resultRow.modelData.icon, "")
                                : ""

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: 24
                                source: rowIcon.resolvedIcon
                                visible: rowIcon.resolvedIcon.length > 0
                                asynchronous: true
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: rowIcon.resolvedIcon.length === 0
                                text: resultRow.modelData.initial
                                font.pixelSize: Theme.fsTitle
                                font.bold: true
                                color: Theme.accent
                            }
                        }

                        Rectangle {
                            id: openPill
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.gap
                            anchors.verticalCenter: parent.verticalCenter
                            width: openLabel.implicitWidth + 22
                            height: 28
                            radius: 14
                            antialiasing: true
                            color: Theme.card
                            opacity: resultRow.selected ? 1 : 0
                            visible: opacity > 0.01

                            Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                            Text {
                                id: openLabel
                                anchors.centerIn: parent
                                text: "Abrir ↵"
                                font.pixelSize: Theme.fsCaption
                                color: Theme.textDim
                            }
                        }

                        Column {
                            anchors.left: rowIcon.right
                            anchors.leftMargin: Theme.pad
                            anchors.right: openPill.left
                            anchors.rightMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: resultRow.modelData.name
                                font.pixelSize: Theme.fsLabel
                                color: Theme.text
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                visible: resultRow.modelData.subtitle.length > 0
                                text: resultRow.modelData.subtitle
                                font.pixelSize: Theme.fsBody
                                color: Theme.textDim
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // estado vazio
                Column {
                    visible: root.resultCount === 0
                    width: parent.width
                    spacing: Theme.gap
                    topPadding: Theme.pad
                    bottomPadding: Theme.pad

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 52
                        height: 52
                        radius: 26
                        antialiasing: true
                        color: Theme.accentSoft

                        Text {
                            anchors.centerIn: parent
                            text: root.glyphSearch
                            font.family: Theme.iconFont
                            font.pixelSize: 20
                            color: Theme.accent
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.searching
                            ? "Nenhum resultado para \"" + appModel.query.trim() + "\""
                            : "Os apps favoritos do índice local aparecem aqui."
                        font.pixelSize: Theme.fsBodyLg
                        color: Theme.textDim
                    }

                    Text {
                        visible: root.searching
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Tente outro termo ou Esc para limpar."
                        font.pixelSize: Theme.fsBody
                        color: Theme.textFaint
                    }
                }
            }
        }
    }
}
