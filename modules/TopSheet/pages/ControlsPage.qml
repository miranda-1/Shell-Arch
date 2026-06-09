import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    // seções expansíveis (uma por vez)
    property bool wifiExpanded: false
    property bool btExpanded: false

    // glyphs Nerd Font (BMP) — escapes explícitos
    readonly property string glyphWifi: ""
    readonly property string glyphBluetooth: ""
    readonly property string glyphBolt: ""
    readonly property string glyphBattery: ""
    readonly property string glyphVolume: ""
    readonly property string glyphVolumeMuted: ""
    readonly property string glyphSun: ""
    readonly property string glyphLock: ""
    readonly property string glyphCheck: ""

    // escaneia redes só enquanto esta página existe
    Component.onCompleted: Network.setScanning(true)
    Component.onDestruction: Network.setScanning(false)

    function signalPercent(net) {
        const s = (net && net.signalStrength) || 0;
        return s > 1 ? Math.round(s) : Math.round(s * 100);
    }

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        // ---- linha de toggles funcionais ----
        Row {
            width: parent.width
            spacing: Theme.gap

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: root.glyphWifi
                title: "Rede"
                subtitle: Network.statusText + (Network.hasWifiDevice ? " • toque para ver redes" : "")
                checked: Network.wifiEnabled
                live: Network.available
                interactive: Network.available
                onToggled: Network.setWifiEnabled(!Network.wifiEnabled)
                onActivated: {
                    root.wifiExpanded = !root.wifiExpanded;
                    if (root.wifiExpanded)
                        root.btExpanded = false;
                }
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: root.glyphBluetooth
                title: "Bluetooth"
                subtitle: Bluez.statusText + (Bluez.available ? " • toque para ver dispositivos" : "")
                checked: Bluez.enabled
                live: Bluez.available
                interactive: Bluez.available
                onToggled: Bluez.setEnabled(!Bluez.enabled)
                onActivated: {
                    root.btExpanded = !root.btExpanded;
                    if (root.btExpanded)
                        root.wifiExpanded = false;
                }
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: root.glyphBolt
                title: "Perfil"
                subtitle: Battery.profileText + " • toque para alternar"
                checked: Battery.profileText === "Performance"
                live: true
                interactive: true
                onToggled: Battery.cycleProfile()
                onActivated: Battery.cycleProfile()
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: root.glyphBattery
                title: "Bateria"
                subtitle: Battery.available ? Battery.statusText : "Sem bateria exposta"
                checked: Battery.available && !Battery.onBattery
                live: Battery.available
            }
        }

        // ---- redes Wi-Fi visíveis ----
        Rectangle {
            visible: root.wifiExpanded
            width: parent.width
            implicitHeight: wifiList.implicitHeight + Theme.pad * 2
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true
            clip: true

            Column {
                id: wifiList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.pad
                spacing: Theme.gap

                Item {
                    width: parent.width
                    height: wifiTitle.implicitHeight

                    Text {
                        id: wifiTitle
                        anchors.left: parent.left
                        text: "Redes Wi-Fi"
                        font.pixelSize: Theme.fsLabel
                        color: Theme.textDim
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "toque conecta em rede salva"
                        font.pixelSize: Theme.fsCaption
                        color: Theme.textFaint
                    }
                }

                Repeater {
                    model: Network.wifiNetworks.slice(0, 8)

                    delegate: Rectangle {
                        id: netRow

                        required property var modelData

                        readonly property bool clickable: Network.canConnect(netRow.modelData)

                        width: parent.width
                        height: 52
                        radius: Theme.radiusSm
                        antialiasing: true
                        color: netRow.modelData.connected ? Theme.accentSoft
                             : netHover.hovered && netRow.clickable ? Theme.accentSoft
                             : Theme.accentTrack
                        border.width: 1
                        border.color: netRow.modelData.connected ? Theme.strokeStrong : Theme.stroke

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler {
                            id: netHover
                            cursorShape: netRow.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            enabled: netRow.clickable
                            onTapped: Network.connectToNetwork(netRow.modelData)
                        }

                        Text {
                            id: netGlyph
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.glyphWifi
                            font.family: Theme.iconFont
                            font.pixelSize: 15
                            color: Theme.accent
                            opacity: 0.35 + 0.65 * Math.min(1, root.signalPercent(netRow.modelData) / 100)
                        }

                        Text {
                            id: netBadge
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            text: netRow.modelData.connected
                                ? root.glyphCheck + "  conectada"
                                : root.signalPercent(netRow.modelData) + "%"
                                    + (Network.isSecured(netRow.modelData) ? "  " + root.glyphLock : "")
                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fsCaption
                            color: netRow.modelData.connected ? Theme.accentActive : Theme.textDim
                        }

                        Column {
                            anchors.left: netGlyph.right
                            anchors.leftMargin: Theme.pad
                            anchors.right: netBadge.left
                            anchors.rightMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: netRow.modelData.name || "Rede oculta"
                                font.pixelSize: Theme.fsBodyLg
                                color: Theme.text
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: netRow.modelData.connected ? "Conectada"
                                    : netRow.modelData.known ? "Salva — toque para conectar"
                                    : "Desconhecida (conecte pelo NetworkManager)"
                                font.pixelSize: Theme.fsCaption
                                color: Theme.textDim
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Text {
                    visible: Network.wifiNetworks.length === 0
                    width: parent.width
                    text: !Network.hasWifiDevice ? "Sem adaptador Wi-Fi nesta máquina."
                        : !Network.wifiEnabled ? "Wi-Fi desligado — use o switch acima."
                        : "Procurando redes…"
                    font.pixelSize: Theme.fsBodyLg
                    color: Theme.textDim
                    wrapMode: Text.Wrap
                }
            }
        }

        // ---- dispositivos Bluetooth pareados ----
        Rectangle {
            visible: root.btExpanded
            width: parent.width
            implicitHeight: btList.implicitHeight + Theme.pad * 2
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true
            clip: true

            Column {
                id: btList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.pad
                spacing: Theme.gap

                Item {
                    width: parent.width
                    height: btTitle.implicitHeight

                    Text {
                        id: btTitle
                        anchors.left: parent.left
                        text: "Dispositivos pareados"
                        font.pixelSize: Theme.fsLabel
                        color: Theme.textDim
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "toque conecta/desconecta"
                        font.pixelSize: Theme.fsCaption
                        color: Theme.textFaint
                    }
                }

                Repeater {
                    model: Bluez.pairedDevices

                    delegate: Rectangle {
                        id: btRow

                        required property var modelData

                        width: parent.width
                        height: 52
                        radius: Theme.radiusSm
                        antialiasing: true
                        color: btRow.modelData.connected ? Theme.accentSoft
                             : btHover.hovered ? Theme.accentSoft
                             : Theme.accentTrack
                        border.width: 1
                        border.color: btRow.modelData.connected ? Theme.strokeStrong : Theme.stroke

                        Behavior on color { ColorAnimation { duration: Theme.tFast } }

                        HoverHandler {
                            id: btHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: Bluez.toggleDevice(btRow.modelData)
                        }

                        Text {
                            id: btGlyph
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.glyphBluetooth
                            font.family: Theme.iconFont
                            font.pixelSize: 15
                            color: btRow.modelData.connected ? Theme.accentActive : Theme.textDim
                        }

                        Text {
                            id: btBadge
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            text: btRow.modelData.connected
                                ? root.glyphCheck + "  conectado"
                                : "pareado"
                            font.family: Theme.iconFont
                            font.pixelSize: Theme.fsCaption
                            color: btRow.modelData.connected ? Theme.accentActive : Theme.textDim
                        }

                        Column {
                            anchors.left: btGlyph.right
                            anchors.leftMargin: Theme.pad
                            anchors.right: btBadge.left
                            anchors.rightMargin: Theme.pad
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                width: parent.width
                                text: btRow.modelData.name || "Dispositivo"
                                font.pixelSize: Theme.fsBodyLg
                                color: Theme.text
                                elide: Text.ElideRight
                            }

                            Text {
                                width: parent.width
                                text: btRow.modelData.batteryAvailable
                                    ? "Bateria " + Math.round(btRow.modelData.battery * 100) + "%"
                                    : (btRow.modelData.connected ? "Conectado" : "Toque para conectar")
                                font.pixelSize: Theme.fsCaption
                                color: Theme.textDim
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                Text {
                    visible: Bluez.pairedDevices.length === 0
                    width: parent.width
                    text: !Bluez.available ? "Sem adaptador Bluetooth nesta máquina."
                        : !Bluez.enabled ? "Bluetooth desligado — use o switch acima."
                        : "Nenhum dispositivo pareado. Pareie pelo gerenciador do sistema."
                    font.pixelSize: Theme.fsBodyLg
                    color: Theme.textDim
                    wrapMode: Text.Wrap
                }
            }
        }

        // ---- sliders ----
        Row {
            width: parent.width
            spacing: Theme.gap

            ControlSlider {
                width: (parent.width - Theme.gap) / 2
                glyph: Audio.muted ? root.glyphVolumeMuted : root.glyphVolume
                label: "Volume"
                value: Math.min(1, Audio.volume)
                live: Audio.available && !Audio.muted
                interactive: Audio.available
                detail: Audio.available
                    ? (Audio.muted ? "Mudo — clique no % para reativar." : Audio.deviceName)
                    : "Pipewire indisponível nesta sessão."
                onMoved: (newValue) => Audio.setVolume(newValue)
                onBadgeClicked: Audio.toggleMute()
            }

            ControlSlider {
                width: (parent.width - Theme.gap) / 2
                glyph: root.glyphSun
                label: "Brilho"
                value: 0.74
                live: false
                detail: "Sem backend seguro para brilho (monitor externo exige DDC). Mantido como placeholder."
            }
        }
    }
}
