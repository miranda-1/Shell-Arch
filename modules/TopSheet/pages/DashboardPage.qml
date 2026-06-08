import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    required property var screenRef

    implicitHeight: content.implicitHeight

    Grid {
        id: content
        width: root.width
        columns: width > 980 ? 4 : 2
        rowSpacing: Theme.gap
        columnSpacing: Theme.gap

        MetricCard {
            width: (content.width - Theme.gap * (content.columns - 1)) / content.columns
            implicitHeight: 170
            glyph: ""
            title: "Agora"
            value: Clock.timeText
            subtitle: Clock.dateText
            emphasized: true
        }

        MetricCard {
            width: (content.width - Theme.gap * (content.columns - 1)) / content.columns
            glyph: ""
            title: "Janela ativa"
            value: Hyprland.activeWindowTitle
            subtitle: Hyprland.activeWindowClass
        }

        MetricCard {
            width: (content.width - Theme.gap * (content.columns - 1)) / content.columns
            glyph: ""
            title: "Rede"
            value: Network.statusText
            subtitle: Network.available ? (Network.connected ? "Conectado" : "Sem conexão ativa") : "Backend indisponível"
        }

        MetricCard {
            width: (content.width - Theme.gap * (content.columns - 1)) / content.columns
            glyph: ""
            title: "Energia"
            value: Battery.available ? Battery.statusText : "Sem bateria"
            subtitle: Battery.available ? Battery.profileText : "Desktop ou dispositivo não exposto"
        }

        Rectangle {
            width: content.columns > 2
                ? ((content.width - Theme.gap * (content.columns - 1)) / content.columns) * 2 + Theme.gap
                : content.width
            implicitHeight: 210
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true

            Column {
                anchors.fill: parent
                anchors.margins: Theme.pad
                spacing: Theme.pad

                Text {
                    text: "Contexto atual"
                    font.pixelSize: Theme.fsLabel
                    color: Theme.textDim
                }

                Row {
                    width: parent.width
                    spacing: Theme.pad

                    MetricCard {
                        width: (parent.width - Theme.pad) / 2
                        implicitHeight: 128
                        glyph: ""
                        title: "Workspace"
                        value: Hyprland.workspaceLabel(Hyprland.activeWorkspaceForScreen(root.screenRef))
                        subtitle: Hyprland.workspaceWindowSummary(Hyprland.activeWorkspaceForScreen(root.screenRef))
                    }

                    MetricCard {
                        width: (parent.width - Theme.pad) / 2
                        implicitHeight: 128
                        glyph: ""
                        title: "Sistema"
                        value: System.osName || "Linux"
                        subtitle: (System.wm || "Sessão") + " • " + (System.uptimeText || "uptime indisponível")
                    }
                }
            }
        }

        Rectangle {
            width: content.columns > 2
                ? ((content.width - Theme.gap * (content.columns - 1)) / content.columns) * 2 + Theme.gap
                : content.width
            implicitHeight: 210
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true

            Column {
                anchors.fill: parent
                anchors.margins: Theme.pad
                spacing: Theme.gap

                Text {
                    text: "Mídia resumida"
                    font.pixelSize: Theme.fsLabel
                    color: Theme.textDim
                }

                Rectangle {
                    width: 64
                    height: 64
                    radius: 32
                    antialiasing: true
                    color: Theme.accentSoft

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.iconFont
                        font.pixelSize: 24
                        color: Theme.accentActive
                    }
                }

                MarqueeText {
                    text: Media.displayTitle
                    maxWidth: parent.width
                    pixelSize: Theme.fsTitle
                    bold: true
                    color: Theme.text
                }

                MarqueeText {
                    text: Media.displaySubtitle
                    maxWidth: parent.width
                    pixelSize: Theme.fsBodyLg
                    color: Theme.textDim
                }

                Text {
                    text: Media.available ? Media.statusText + " • " + Media.activePlayerName : "Sem mídia ativa no momento"
                    font.pixelSize: Theme.fsBody
                    color: Theme.textDim
                }
            }
        }
    }
}
