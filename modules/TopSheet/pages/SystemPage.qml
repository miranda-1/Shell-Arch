import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    required property var screenRef

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Row {
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Sistema"
                value: System.osName || "Linux"
                subtitle: "Leitura direta de /etc/os-release"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Sessão"
                value: System.wm || "Sessão atual"
                subtitle: Hyprland.monitorNameForScreen(root.screenRef)
            }

            MetricCard {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Uptime"
                value: System.uptimeText || "Indisponível"
                subtitle: "Leitura local de /proc/uptime"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 3) / 4
                glyph: ""
                title: "Energia"
                value: Battery.available ? Battery.statusText : "Sem bateria"
                subtitle: Battery.available ? Battery.profileText : "Sem power profile exposto"
            }
        }

    }
}