import "../../../components"
import "../../../config"
import "../../../services"
import Quickshell
import QtQuick

Item {
    id: root

    required property var screenRef

    readonly property string userName: Quickshell.env("USER") || "user"
    readonly property string hostName: Quickshell.env("HOSTNAME") || Hyprland.monitorNameForScreen(root.screenRef)

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Row {
            id: profileRow
            width: parent.width
            spacing: Theme.gap

            Rectangle {
                id: identityCard
                width: parent.width * 0.38
                implicitHeight: 250
                radius: Theme.radius
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.pad
                    spacing: Theme.pad

                    Rectangle {
                        width: 70
                        height: 70
                        radius: 35
                        color: Theme.accentSoft
                        antialiasing: true

                        Text {
                            anchors.centerIn: parent
                            text: root.userName.length > 0 ? root.userName.charAt(0).toUpperCase() : "U"
                            font.pixelSize: 28
                            font.bold: true
                            color: Theme.accentActive
                        }
                    }

                    Text {
                        text: root.userName
                        font.pixelSize: Theme.fsHeadline
                        font.bold: true
                        color: Theme.text
                    }

                    Text {
                        text: root.hostName
                        font.pixelSize: Theme.fsBodyLg
                        color: Theme.textDim
                    }

                    Text {
                        text: System.wm || "Sessão atual"
                        font.pixelSize: Theme.fsBody
                        color: Theme.textDim
                    }
                }
            }

            Column {
                width: profileRow.width - identityCard.width - Theme.gap
                spacing: Theme.gap

                MetricCard {
                    width: parent.width
                    glyph: ""
                    title: "Perfil de energia"
                    value: Battery.profileText
                    subtitle: Battery.available ? Battery.statusText : "Sem bateria ou perfil exposto"
                }

                MetricCard {
                    width: parent.width
                    glyph: ""
                    title: "Workspace atual"
                    value: Hyprland.activeWorkspaceLabel
                    subtitle: Hyprland.workspaceWindowSummary(Hyprland.activeWorkspaceForScreen(root.screenRef))
                }

                MetricCard {
                    width: parent.width
                    glyph: ""
                    title: "Janela ativa"
                    value: Hyprland.activeWindowClass
                    subtitle: Hyprland.activeWindowTitle
                }
            }
        }

        Row {
            width: parent.width
            spacing: Theme.gap

            Repeater {
                model: [
                    { glyph: "", label: "Bloquear", subtitle: "Placeholder visual" },
                    { glyph: "", label: "Logout", subtitle: "Sem ação real nesta fase" },
                    { glyph: "", label: "Reiniciar", subtitle: "Desabilitado" },
                    { glyph: "", label: "Desligar", subtitle: "Desabilitado" }
                ]
                delegate: QuickToggle {
                    required property var modelData
                    width: (parent.width - Theme.gap * 3) / 4
                    glyph: modelData.glyph
                    title: modelData.label
                    subtitle: modelData.subtitle
                    checked: false
                    live: false
                }
            }
        }
    }
}
