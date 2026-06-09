import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    required property var screenRef

    implicitHeight: content.implicitHeight

    readonly property bool wide: root.width > 980
    readonly property var activeWs: Hyprland.activeWorkspaceForScreen(root.screenRef)

    // pt-BR retorna o dia minúsculo ("segunda-feira"); capitaliza para exibição
    readonly property string weekdayFull: {
        const wd = Clock.now.toLocaleDateString(Qt.locale("pt_BR"), "dddd");
        return wd.length > 0 ? wd[0].toUpperCase() + wd.slice(1) : wd;
    }
    readonly property string fullDate: Clock.currentDay + " de " + Clock.monthName + " de " + Clock.currentYear
    readonly property string monthAbbrev: Clock.monthName.slice(0, 3).toUpperCase()

    // glyphs Nerd Font (BMP) — escapes explícitos para não depender do
    // encoding do arquivo
    readonly property string glyphWindow: ""   // janela
    readonly property string glyphWifi: ""     // wi-fi
    readonly property string glyphBolt: ""     // energia
    readonly property string glyphMusic: ""    // nota musical

    // linha 2 com altura uniforme: o card mais alto define a dos demais
    readonly property real metricRowHeight: Math.max(
        netCard.implicitHeight, powerCard.implicitHeight, 132)

    // grade de 4 unidades na linha 2 (Rede 1u + Energia 1u + Mídia 2u)
    readonly property real unitWidth: root.wide
        ? (root.width - Theme.gap * 3) / 4
        : (root.width - Theme.gap) / 2

    Column {
        id: content
        width: root.width
        spacing: Theme.gap

        // ---- linha 1: data/hora em destaque + janela ativa ----
        Grid {
            width: parent.width
            columns: root.wide ? 2 : 1
            columnSpacing: Theme.gap
            rowSpacing: Theme.gap

            Rectangle {
                id: heroCard
                width: root.wide ? (parent.width - Theme.gap) / 2 : parent.width
                height: 212
                radius: Theme.radius
                color: Theme.accentActive
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)
                antialiasing: true

                Item {
                    anchors.fill: parent
                    anchors.margins: Theme.pad + 4

                    Column {
                        anchors.left: parent.left
                        anchors.right: dayTile.left
                        anchors.rightMargin: Theme.pad
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: "HOJE"
                            font.pixelSize: Theme.fsCaption
                            font.letterSpacing: 2
                            color: Qt.rgba(1, 1, 1, 0.55)
                        }

                        Text {
                            text: Clock.timeText
                            font.pixelSize: Theme.fsHero
                            font.bold: true
                            color: Theme.textOnAccent
                        }

                        Text {
                            width: parent.width
                            text: root.weekdayFull
                            font.pixelSize: Theme.fsTitleLg
                            color: Qt.rgba(1, 1, 1, 0.9)
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: root.fullDate
                            font.pixelSize: Theme.fsBodyLg
                            color: Qt.rgba(1, 1, 1, 0.65)
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        id: dayTile
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 96
                        height: 108
                        radius: Theme.radius
                        color: Qt.rgba(1, 1, 1, 0.12)
                        antialiasing: true

                        Column {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Clock.currentDay
                                font.pixelSize: Theme.fsDisplay
                                font.bold: true
                                color: Theme.textOnAccent
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.monthAbbrev
                                font.pixelSize: Theme.fsCaption
                                font.letterSpacing: 2
                                color: Qt.rgba(1, 1, 1, 0.7)
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: windowCard
                width: root.wide ? (parent.width - Theme.gap) / 2 : parent.width
                height: 212
                radius: Theme.radius
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.pad
                    spacing: Theme.gap

                    Row {
                        spacing: Theme.gap

                        Rectangle {
                            width: 34
                            height: 34
                            radius: 17
                            antialiasing: true
                            color: Theme.accentSoft

                            Text {
                                anchors.centerIn: parent
                                text: root.glyphWindow
                                font.family: Theme.iconFont
                                font.pixelSize: 16
                                color: Theme.accent
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Janela ativa"
                            font.pixelSize: Theme.fsBody
                            color: Theme.textDim
                        }
                    }

                    MarqueeText {
                        text: Hyprland.activeWindowTitle
                        maxWidth: parent.width
                        pixelSize: Theme.fsTitleLg
                        bold: true
                        color: Theme.text
                    }

                    Text {
                        width: parent.width
                        text: Hyprland.activeWindowClass
                        font.pixelSize: Theme.fsBodyLg
                        color: Theme.textDim
                        elide: Text.ElideRight
                    }

                    Flow {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: [
                                "WS " + Hyprland.workspaceLabel(root.activeWs),
                                Hyprland.monitorNameForScreen(root.screenRef),
                                Hyprland.workspaceWindowSummary(root.activeWs)
                            ]

                            delegate: Pill {
                                required property string modelData

                                height: 26
                                width: Math.min(chipLabel.implicitWidth + 20, parent.width)

                                Text {
                                    id: chipLabel
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    width: parent.width - 20
                                    text: modelData
                                    font.pixelSize: Theme.fsCaption
                                    color: Theme.text
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---- linha 2: rede + energia + mídia integrada ----
        Flow {
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                id: netCard
                width: root.unitWidth
                height: root.metricRowHeight
                glyph: root.glyphWifi
                title: "Rede"
                value: Network.statusText
                subtitle: Network.available ? (Network.connected ? "Conectado" : "Sem conexão ativa") : "Backend indisponível"
            }

            MetricCard {
                id: powerCard
                width: root.unitWidth
                height: root.metricRowHeight
                glyph: root.glyphBolt
                title: "Energia"
                value: Battery.available ? Battery.statusText : "Sem bateria"
                subtitle: Battery.available
                    ? Battery.profileText + (Battery.timeText ? " • " + Battery.timeText : "")
                    : "Desktop ou dispositivo não exposto"
            }

            Rectangle {
                id: mediaCard
                width: root.wide ? root.unitWidth * 2 + Theme.gap : parent.width
                height: root.metricRowHeight
                radius: Theme.radius
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true
                clip: true

                Item {
                    anchors.fill: parent
                    anchors.margins: Theme.pad

                    Rectangle {
                        id: mediaGlyph
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 64
                        height: 64
                        radius: 32
                        antialiasing: true
                        color: Media.isPlaying ? Theme.accentActive : Theme.accentSoft

                        Text {
                            anchors.centerIn: parent
                            text: root.glyphMusic
                            font.family: Theme.iconFont
                            font.pixelSize: 24
                            color: Media.isPlaying ? Theme.textOnAccent : Theme.accentActive
                        }
                    }

                    Column {
                        anchors.left: mediaGlyph.right
                        anchors.leftMargin: Theme.pad
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            text: "Mídia"
                            font.pixelSize: Theme.fsBody
                            color: Theme.textDim
                        }

                        MarqueeText {
                            text: Media.displayTitle
                            maxWidth: parent.width
                            pixelSize: Theme.fsTitleLg
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
                            width: parent.width
                            text: Media.available
                                ? Media.statusText + " • " + Media.activePlayerName
                                : "Sem player ativo"
                            font.pixelSize: Theme.fsCaption
                            color: Theme.textFaint
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
