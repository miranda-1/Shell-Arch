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

        Row {
            width: parent.width
            spacing: Theme.gap

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Rede"
                subtitle: Network.statusText
                checked: Network.connected
                live: true
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Bluetooth"
                subtitle: "Placeholder visual até haver serviço seguro."
                checked: false
                live: false
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Perfil"
                subtitle: Battery.profileText
                checked: Battery.profileText === "Performance"
                live: true
            }

            QuickToggle {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Bateria"
                subtitle: Battery.available ? Battery.statusText : "Sem bateria exposta"
                checked: Battery.available && !Battery.onBattery
                live: Battery.available
            }
        }

        Row {
            width: parent.width
            spacing: Theme.gap

            ControlSlider {
                width: (parent.width - Theme.gap) / 2
                glyph: ""
                label: "Volume"
                value: 0.66
                detail: "Placeholder read-only nesta fase. O valor ainda não vem de um serviço seguro da shell."
                live: false
            }

            ControlSlider {
                width: (parent.width - Theme.gap) / 2
                glyph: ""
                label: "Brilho"
                value: 0.74
                detail: "Placeholder read-only. A arquitetura visual fica pronta sem adicionar mutação real nova."
                live: false
            }
        }
    }
}
