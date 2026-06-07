pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Serviço read-only de informações do sistema (Fase 5). Fontes:
//  - /etc/os-release  → nome do SO  (leitura de arquivo via FileView)
//  - XDG_CURRENT_DESKTOP / HYPRLAND_INSTANCE_SIGNATURE → WM (variável de ambiente)
//  - /proc/uptime     → tempo ligado (leitura de arquivo via FileView)
//
// IMPORTANTE: NÃO executa comando externo. `FileView` apenas LÊ arquivos do
// sistema (pseudo-arquivos /proc e config /etc), sem efeitos colaterais e sem
// alterar nada. Tudo somente leitura.
Singleton {
    id: root

    // ---- SO: /etc/os-release (estático, leitura única bloqueante) ----
    FileView {
        id: osRelease
        path: "/etc/os-release"
        preload: true
        blockLoading: true
    }
    readonly property string osName: {
        const t = osRelease.text();
        if (!t)
            return "";
        const pretty = t.match(/^PRETTY_NAME="?([^"\n]+)"?/m);
        if (pretty)
            return pretty[1];
        const name = t.match(/^NAME="?([^"\n]+)"?/m);
        return name ? name[1] : "";
    }

    // ---- WM: variável de ambiente da sessão ----
    readonly property string wm: {
        const xdg = Quickshell.env("XDG_CURRENT_DESKTOP");
        if (xdg)
            return xdg;
        return Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "Hyprland" : "";
    }

    // ---- uptime: /proc/uptime (lido uma vez; valor "vivo" = base + decorrido) ----
    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        preload: true
        blockLoading: true
    }
    property double _baseUptime: -1   // segundos lidos do /proc/uptime
    property double _baseEpoch: 0      // Date.now() no momento da leitura
    property int _tick: 0              // hook de atualização (1×/min)

    Component.onCompleted: {
        const t = uptimeFile.text();
        const s = t ? parseFloat(t.split(/\s+/)[0]) : NaN;
        if (s > 0) {
            root._baseUptime = s;
            root._baseEpoch = Date.now();
        }
    }

    Timer { interval: 60000; running: true; repeat: true; onTriggered: root._tick++ }

    readonly property string uptimeText: {
        root._tick;   // dependência para reavaliar a cada minuto
        if (root._baseUptime < 0)
            return "";
        const secs = root._baseUptime + (Date.now() - root._baseEpoch) / 1000;
        const d = Math.floor(secs / 86400);
        const h = Math.floor((secs % 86400) / 3600);
        const m = Math.floor((secs % 3600) / 60);
        const parts = [];
        if (d > 0)
            parts.push(d + (d === 1 ? " dia" : " dias"));
        if (h > 0)
            parts.push(h + "h");
        parts.push(m + "min");
        return "ligado há " + parts.join(" ");
    }
}
