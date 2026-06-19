pragma Singleton

import Quickshell
import Quickshell.Services.SystemTray

// Adapter read-only do SystemTray (StatusNotifierItem / DBus). Apenas expõe os
// itens registrados por apps em background. A interação (activate /
// secondaryActivate / menu) acontece via a API typed do próprio item — nenhum
// Process/spawn externo é criado aqui.
Singleton {
    id: root

    // Applets que NÃO queremos na barra (ruído de bandeja). Casado por substring
    // contra id/title/tooltip do item, case-insensitive.
    readonly property var hiddenHints: [
        "blueman", "bluetooth",
        "nm-applet", "nm-tray", "networkmanager", "network",
        "udiskie"
    ]

    // Lista filtrada (array JS) usável direto num Repeater; cada delegate recebe
    // um SystemTrayItem como modelData. O binding relê quando .values muda e
    // também quando o id/title de um item resolve (leituras rastreadas).
    readonly property var items: root._filter(SystemTray.items ? SystemTray.items.values : [])
    readonly property int count: root.items.length
    readonly property bool hasItems: root.count > 0

    function _isHidden(item) {
        if (!item)
            return true;

        const hay = ((item.id || "") + " " + (item.title || "") + " " + (item.tooltipTitle || "")).toLowerCase();
        for (let i = 0; i < root.hiddenHints.length; i++) {
            if (hay.indexOf(root.hiddenHints[i]) >= 0)
                return true;
        }
        return false;
    }

    function _filter(values) {
        const out = [];
        for (let i = 0; i < values.length; i++) {
            if (!root._isHidden(values[i]))
                out.push(values[i]);
        }
        return out;
    }
}
