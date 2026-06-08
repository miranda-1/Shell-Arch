import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    required property var screenRef

    readonly property var workspaceList: {
        const list = Hyprland.workspacesForScreen(root.screenRef);
        return list.length > 0 ? list : Hyprland.workspaceList;
    }

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Row {
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Tela"
                value: Hyprland.monitorNameForScreen(root.screenRef)
                subtitle: "Página restrita ao contexto deste monitor"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Workspace ativo"
                value: Hyprland.activeWorkspaceLabel
                subtitle: Hyprland.workspaceWindowSummary(Hyprland.activeWorkspaceForScreen(root.screenRef))
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Janela ativa"
                value: Hyprland.activeWindowClass
                subtitle: Hyprland.activeWindowTitle
            }
        }

        Flow {
            width: parent.width
            spacing: Theme.gap

            Repeater {
                model: root.workspaceList
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool activatable: Hyprland.canActivateWorkspace(modelData)
                    readonly property bool focused: Hyprland.isWorkspaceFocused(modelData)
                    readonly property bool active: Hyprland.isWorkspaceActive(modelData)
                    width: root.width > 1040 ? (parent.width - Theme.gap * 2) / 3 : (parent.width - Theme.gap) / 2
                    height: 154
                    radius: Theme.radius
                    antialiasing: true
                    color: focused ? Theme.accentActive : active ? Theme.accentSoft : Theme.card
                    border.width: 1
                    border.color: focused ? Qt.rgba(1, 1, 1, 0.08) : active ? Theme.strokeStrong : Theme.stroke

                    HoverHandler {
                        id: wsHover
                        cursorShape: activatable ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        enabled: activatable
                        onTapped: Hyprland.activateWorkspace(modelData)
                    }

                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.pad
                        spacing: 8

                        Row {
                            width: parent.width

                            Text {
                                text: "WS " + Hyprland.workspaceLabel(modelData)
                                font.pixelSize: Theme.fsTitle
                                font.bold: true
                                color: focused ? Theme.textOnAccent : Theme.text
                            }

                            Item { width: parent.width - badge.width - 72 }

                            Rectangle {
                                id: badge
                                width: badgeText.implicitWidth + 18
                                height: 28
                                radius: 14
                                color: focused ? Qt.rgba(1, 1, 1, 0.14) : active ? Theme.card : Theme.accentTrack

                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: Hyprland.workspaceStatusLabel(modelData)
                                    font.pixelSize: 11
                                    color: focused ? Theme.textOnAccent : Theme.textDim
                                }
                            }
                        }

                        Text {
                            text: Hyprland.workspaceWindowSummary(modelData)
                            font.pixelSize: Theme.fsLabel
                            color: focused ? Qt.rgba(1, 1, 1, 0.82) : Theme.text
                            wrapMode: Text.Wrap
                        }

                        Text {
                            text: Hyprland.workspaceWindowCount(modelData) + " janela(s)"
                            font.pixelSize: Theme.fsBody
                            color: focused ? Qt.rgba(1, 1, 1, 0.72) : Theme.textDim
                        }

                        Text {
                            text: activatable ? "Clique para focar este workspace." : "Já está ativo nesta tela."
                            font.pixelSize: Theme.fsBody
                            color: focused ? Qt.rgba(1, 1, 1, 0.72) : Theme.textDim
                        }
                    }
                }
            }
        }
    }
}
