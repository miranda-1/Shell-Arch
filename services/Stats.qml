pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Métricas ao vivo do sistema — SOMENTE LEITURA via sysfs/proc (FileView).
// Sem comando externo. Usado pelo painel de stats e pelos ícones da EdgeLeft.
Singleton {
    id: root

    FileView { id: statFile;    path: "/proc/stat"; preload: true; blockLoading: true }
    FileView { id: memFile;     path: "/proc/meminfo"; preload: true; blockLoading: true }
    // x86_pkg_temp = temperatura do pacote da CPU (nome estável)
    FileView { id: tempFile;    path: "/sys/class/thermal/thermal_zone11/temp"; preload: true; blockLoading: true }
    // alienware_wmi temp2 = GPU (label confirmado em /sys/class/hwmon/hwmon6/temp2_label)
    FileView { id: gpuTempFile; path: "/sys/class/hwmon/hwmon6/temp2_input"; preload: true; blockLoading: true }

    property real cpuPercent: 0
    property real memPercent: 0
    property int  tempC: 0
    property int  gpuTempC: 0

    property real _prevTotal: -1
    property real _prevIdle: -1

    function _recompute() {
        // CPU: delta de ocupação entre amostras de /proc/stat
        const st = statFile.text();
        if (st) {
            const m = st.match(/^cpu\s+([0-9 ]+)/);
            if (m) {
                const v = m[1].trim().split(/\s+/).map(Number);
                const idle = (v[3] || 0) + (v[4] || 0);
                let total = 0;
                for (let i = 0; i < v.length; i++)
                    total += v[i] || 0;

                if (root._prevTotal >= 0) {
                    const dt = total - root._prevTotal;
                    const di = idle - root._prevIdle;
                    root.cpuPercent = dt > 0 ? Math.max(0, Math.min(100, (1 - di / dt) * 100)) : root.cpuPercent;
                }
                root._prevTotal = total;
                root._prevIdle = idle;
            }
        }

        // RAM: 1 - MemAvailable/MemTotal
        const mt = memFile.text();
        if (mt) {
            const tot = mt.match(/MemTotal:\s+(\d+)/);
            const av  = mt.match(/MemAvailable:\s+(\d+)/);
            if (tot && av) {
                const t = Number(tot[1]);
                const a = Number(av[1]);
                root.memPercent = t > 0 ? Math.max(0, Math.min(100, (1 - a / t) * 100)) : 0;
            }
        }

        // Temperatura CPU (millidegrees → °C)
        const tp = tempFile.text();
        if (tp) {
            const n = parseInt(tp.trim());
            if (!isNaN(n))
                root.tempC = Math.round(n / 1000);
        }

        // Temperatura GPU via alienware_wmi (millidegrees → °C)
        const gp = gpuTempFile.text();
        if (gp) {
            const n = parseInt(gp.trim());
            if (!isNaN(n))
                root.gpuTempC = Math.round(n / 1000);
        }
    }

    Component.onCompleted: root._recompute()

    Timer {
        interval: 2000
        running: true
        repeat: true
        // lê o que já foi carregado e dispara o reload para o próximo tick
        onTriggered: {
            root._recompute();
            statFile.reload();
            memFile.reload();
            tempFile.reload();
            gpuTempFile.reload();
        }
    }

    readonly property string cpuText: Math.round(root.cpuPercent) + "%"
    readonly property string memText: Math.round(root.memPercent) + "%"
    readonly property string tempText: root.tempC + "°C"
    readonly property string gpuText: root.gpuTempC + "°C"

    readonly property real memTotalGb: {
        const mt = memFile.text();
        if (!mt)
            return 0;
        const tot = mt.match(/MemTotal:\s+(\d+)/);
        return tot ? Number(tot[1]) / 1048576 : 0;
    }
    readonly property real memUsedGb: root.memTotalGb * root.memPercent / 100
}
