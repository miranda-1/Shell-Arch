import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

// Página "Telas": (a) escolher em qual monitor o shell aparece (config local,
// segura) e (b) trocar resolução/Hz/escala do monitor no Hyprland vivo, com
// revert automático. Toda a lógica perigosa vive em services/Monitors.qml.
Item {
    id: root

    implicitHeight: content.implicitHeight

    function isCurrentMode(m, mode) {
        return mode.w === m.w && mode.h === m.h && mode.hz === m.hz;
    }

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        // ---- banner de confirmação / revert ----
        Rectangle {
            visible: Monitors.hasPending
            width: parent.width
            implicitHeight: bannerCol.implicitHeight + Theme.pad * 2
            radius: Theme.radius
            color: Theme.accentSoft
            border.width: 1
            border.color: Theme.strokeStrong
            antialiasing: true

            Column {
                id: bannerCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Theme.pad
                spacing: Theme.gap

                Text {
                    width: parent.width
                    text: "Modo aplicado: " + Monitors.pendingDesc
                    font.pixelSize: Theme.fsBodyLg
                    color: Theme.text
                    wrapMode: Text.Wrap
                }

                Text {
                    width: parent.width
                    text: "Mantém este modo? Reverte sozinho em " + Monitors.pendingSeconds + "s se você não confirmar."
                    font.pixelSize: Theme.fsCaption
                    color: Theme.textDim
                    wrapMode: Text.Wrap
                }

                Row {
                    spacing: Theme.gap

                    Rectangle {
                        width: 120
                        height: 36
                        radius: Theme.radiusSm
                        color: keepHover.hovered ? Theme.accentActive : Theme.accent
                        antialiasing: true

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler { id: keepHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: Monitors.confirmApply() }

                        Text {
                            anchors.centerIn: parent
                            text: "Manter (" + Monitors.pendingSeconds + "s)"
                            font.pixelSize: Theme.fsBody
                            color: Theme.textOnAccent
                        }
                    }

                    Rectangle {
                        width: 120
                        height: 36
                        radius: Theme.radiusSm
                        color: revertHover.hovered ? Theme.accentSoft : Theme.card
                        border.width: 1
                        border.color: Theme.strokeStrong
                        antialiasing: true

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler { id: revertHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: Monitors.revertNow() }

                        Text {
                            anchors.centerIn: parent
                            text: "Reverter agora"
                            font.pixelSize: Theme.fsBody
                            color: Theme.text
                        }
                    }
                }
            }
        }

        // ---------- (a) tela do shell ----------
        SectionHeader { text: "TELA DO SHELL" }

        Text {
            width: parent.width
            text: "Em qual monitor o shell aparece. Config local da própria shell — não toca no sistema."
            font.pixelSize: Theme.fsCaption
            color: Theme.textFaint
            wrapMode: Text.Wrap
        }

        Flow {
            width: parent.width
            spacing: Theme.gap

            // chip "Todas" + um chip por monitor
            Repeater {
                model: [{ name: "", label: "Todas as telas" }].concat(
                    Monitors.monitors.map(function(m) {
                        return { name: m.name, label: m.name + (m.description ? " · " + m.description : "") };
                    }))

                delegate: Rectangle {
                    required property var modelData
                    readonly property bool selected: Monitors.shellMonitor === modelData.name

                    width: shellLabel.implicitWidth + 28
                    height: 40
                    radius: Theme.radiusSm
                    color: selected ? Theme.accentActive : shellHover.hovered ? Theme.accentSoft : Theme.card
                    border.width: 1
                    border.color: selected ? Theme.strokeStrong : Theme.stroke
                    antialiasing: true

                    Behavior on color { ColorAnimation { duration: Theme.tFast } }

                    HoverHandler { id: shellHover; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: Monitors.setShellMonitor(modelData.name) }

                    Text {
                        id: shellLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: Theme.fsBody
                        color: parent.selected ? Theme.textOnAccent : Theme.text
                    }
                }
            }
        }

        // ---------- (b) modos por monitor ----------
        SectionHeader { text: "RESOLUÇÃO, TAXA E ESCALA" }

        Text {
            visible: Monitors.count === 0
            width: parent.width
            text: "Nenhum monitor reportado pelo Hyprland nesta sessão."
            font.pixelSize: Theme.fsBodyLg
            color: Theme.textDim
            wrapMode: Text.Wrap
        }

        Repeater {
            model: Monitors.monitors

            delegate: Rectangle {
                id: monCard
                required property var modelData

                // resolução/taxa começa recolhida: só o modo atual aparece
                property bool modesOpen: false

                width: content.width
                implicitHeight: monCol.implicitHeight + Theme.pad * 2
                radius: Theme.radius
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                antialiasing: true

                Column {
                    id: monCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.pad
                    spacing: Theme.gap

                    // cabeçalho do monitor
                    Item {
                        width: parent.width
                        height: monName.implicitHeight

                        Text {
                            id: monName
                            anchors.left: parent.left
                            text: monCard.modelData.name
                                + (monCard.modelData.focused ? "  ·  foco" : "")
                            font.pixelSize: Theme.fsLabel
                            font.bold: true
                            color: Theme.text
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: monCard.modelData.scale + "x"
                            font.pixelSize: Theme.fsCaption
                            color: Theme.textDim
                        }
                    }

                    // seletor de resolução/taxa: recolhido mostra só o atual
                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: Theme.radiusSm
                        color: modeToggleHover.hovered ? Theme.accentSoft : Theme.accentTrack
                        border.width: 1
                        border.color: monCard.modesOpen ? Theme.strokeStrong : Theme.stroke
                        antialiasing: true

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler { id: modeToggleHover; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: monCard.modesOpen = !monCard.modesOpen }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 11
                            anchors.verticalCenter: parent.verticalCenter
                            text: monCard.modelData.w + "×" + monCard.modelData.h
                                + " · " + monCard.modelData.hz + " Hz"
                            font.pixelSize: Theme.fsBody
                            color: Theme.text
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 11
                            anchors.verticalCenter: parent.verticalCenter
                            text: monCard.modesOpen ? "▴" : "▾"
                            font.pixelSize: Theme.fsCaption
                            color: Theme.textDim
                        }
                    }

                    // modos disponíveis (resolução · Hz) — só quando expandido
                    Flow {
                        visible: monCard.modesOpen
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: monCard.modesOpen ? monCard.modelData.modes : []

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool selected: root.isCurrentMode(monCard.modelData, modelData)

                                width: modeLabel.implicitWidth + 22
                                height: 34
                                radius: Theme.radiusSm
                                color: selected ? Theme.accentActive : modeHover.hovered ? Theme.accentSoft : Theme.accentTrack
                                border.width: 1
                                border.color: selected ? Theme.strokeStrong : Theme.stroke
                                antialiasing: true

                                Behavior on color { ColorAnimation { duration: Theme.tFast } }

                                HoverHandler { id: modeHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler {
                                    enabled: !selected
                                    onTapped: {
                                        Monitors.applyMode(monCard.modelData.name, modelData.token, monCard.modelData.scale);
                                        monCard.modesOpen = false;
                                    }
                                }

                                Text {
                                    id: modeLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pixelSize: Theme.fsCaption
                                    color: parent.selected ? Theme.textOnAccent : Theme.text
                                }
                            }
                        }
                    }

                    // escala
                    Item {
                        width: parent.width
                        height: scaleTitle.implicitHeight

                        Text {
                            id: scaleTitle
                            anchors.left: parent.left
                            text: "Escala"
                            font.pixelSize: Theme.fsCaption
                            color: Theme.textDim
                        }
                    }

                    Flow {
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: Monitors.scaleOptions

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool selected: Math.abs(Number(modelData) - monCard.modelData.scale) < 0.001

                                width: scaleLabel.implicitWidth + 22
                                height: 34
                                radius: Theme.radiusSm
                                color: selected ? Theme.accentActive : scaleHover.hovered ? Theme.accentSoft : Theme.accentTrack
                                border.width: 1
                                border.color: selected ? Theme.strokeStrong : Theme.stroke
                                antialiasing: true

                                Behavior on color { ColorAnimation { duration: Theme.tFast } }

                                HoverHandler { id: scaleHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler {
                                    enabled: !selected
                                    onTapped: Monitors.applyMode(monCard.modelData.name, monCard.modelData.modeToken, Number(modelData))
                                }

                                Text {
                                    id: scaleLabel
                                    anchors.centerIn: parent
                                    text: modelData + "x"
                                    font.pixelSize: Theme.fsCaption
                                    color: parent.selected ? Theme.textOnAccent : Theme.text
                                }
                            }
                        }
                    }
                }
            }
        }

        Text {
            visible: Monitors.count > 0
            width: parent.width
            text: "Mudanças de modo aplicam no Hyprland vivo e revertem sozinhas se você não confirmar."
            font.pixelSize: Theme.fsCaption
            color: Theme.textFaint
            wrapMode: Text.Wrap
        }
    }

    // garante availableModes fresco ao abrir
    Component.onCompleted: Monitors.refresh()
}
