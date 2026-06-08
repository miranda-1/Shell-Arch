import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Rectangle {
            width: parent.width
            implicitHeight: 288
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true

            Row {
                anchors.fill: parent
                anchors.margins: Theme.pad + 4
                spacing: Theme.pad + 4

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 180
                    height: 180
                    radius: 90
                    antialiasing: true
                    color: Theme.accentSoft

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: Theme.iconFont
                        font.pixelSize: 54
                        color: Theme.accentActive
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 232
                    spacing: 10

                    MarqueeText {
                        text: Media.displayTitle
                        maxWidth: parent.width
                        pixelSize: 26
                        bold: true
                        color: Theme.text
                    }

                    MarqueeText {
                        text: Media.displaySubtitle
                        maxWidth: parent.width
                        pixelSize: Theme.fsLabel
                        color: Theme.textDim
                    }

                    Row {
                        spacing: 8

                        Rectangle {
                            width: statusText.implicitWidth + 18
                            height: 28
                            radius: 14
                            color: Media.isPlaying ? Theme.accentSoft : Theme.accentTrack

                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: Media.statusText
                                font.pixelSize: 11
                                color: Media.isPlaying ? Theme.accentActive : Theme.textDim
                            }
                        }

                        Rectangle {
                            visible: Media.available
                            width: playerText.implicitWidth + 18
                            height: 28
                            radius: 14
                            color: Theme.accentTrack

                            Text {
                                id: playerText
                                anchors.centerIn: parent
                                text: Media.activePlayerName
                                font.pixelSize: 11
                                color: Theme.textDim
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 10
                        radius: 5
                        color: Theme.accentTrack
                        antialiasing: true

                        Rectangle {
                            width: Math.max(height, parent.width * Media.progress)
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accentActive
                            antialiasing: true
                        }
                    }

                    Row {
                        width: parent.width

                        Text {
                            text: Media.positionText
                            font.pixelSize: Theme.fsBody
                            color: Theme.textDim
                        }

                        Item { width: parent.width - positionTextWidth.implicitWidth - lengthTextWidth.implicitWidth }

                        Text {
                            id: positionTextWidth
                            visible: false
                            text: Media.positionText
                        }

                        Text {
                            id: lengthTextWidth
                            visible: false
                            text: Media.lengthText
                        }

                        Text {
                            text: Media.lengthText
                            font.pixelSize: Theme.fsBody
                            color: Theme.textDim
                        }
                    }

                    Row {
                        spacing: Theme.pad + 10

                        Repeater {
                            model: [
                                { glyph: "", enabled: Media.canPrevious, action: function() { Media.previous(); } },
                                { glyph: Media.isPlaying ? "" : "", enabled: Media.canPlayPause, action: function() { Media.playPause(); } },
                                { glyph: "", enabled: Media.canNext, action: function() { Media.next(); } }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                width: modelData.glyph === (Media.isPlaying ? "" : "") ? 54 : 46
                                height: width
                                radius: width / 2
                                color: modelData.enabled ? Theme.cardHover : Theme.accentTrack
                                opacity: modelData.enabled ? 1 : 0.5
                                antialiasing: true

                                HoverHandler {
                                    id: mediaHover
                                    enabled: modelData.enabled
                                    cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                }

                                TapHandler {
                                    acceptedButtons: Qt.LeftButton
                                    enabled: modelData.enabled
                                    onTapped: modelData.action()
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.glyph
                                    font.family: Theme.iconFont
                                    font.pixelSize: modelData.glyph === (Media.isPlaying ? "" : "") ? 22 : 18
                                    color: modelData.enabled ? Theme.accentActive : Theme.textDim
                                }
                            }
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: "󰓇"
                title: "Fonte"
                value: Media.available ? Media.activePlayerName : "Nenhuma"
                subtitle: Media.available ? Media.playbackStatus : "Sem sessão MPRIS elegível"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Players"
                value: Media.detectedPlayerCount + ""
                subtitle: Media.playerCount + " com estado ativo ou pausado"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Fallback"
                value: Media.available ? "Pronto" : "Aguardando"
                subtitle: "A UI não quebra quando o player omite título ou artista."
            }
        }
    }
}
