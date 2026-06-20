pragma Singleton

import Quickshell
import Quickshell.Io
import QtQml
import QtQuick

// Métricas ao vivo do sistema. LEITURA via sysfs/proc (FileView) para CPU e RAM.
//
// EXCEÇÃO de política (autorizada pelo usuário em 2026-06-19): a GPU NVIDIA não
// expõe uso (%) nem VRAM por sysfs, então usamos `nvidia-smi` (Process, comando
// fixo, sem shell eval) — 4ª exceção de Process do projeto, ao lado de
// brightnessctl/systemctl/hyde-shell. Polling de 2s.
//
// Robustez de sensores: os números de /sys/class/hwmon/hwmonN MUDAM a cada boot
// (era por isso que a GPU lia 0°C — `hwmon6` fixo virou outro sensor). Agora
// resolvemos o hwmon PELO NOME (coretemp = CPU, spd5118 = RAM), então a leitura
// não depende do número.
Singleton {
    id: root

    // ---- fontes sysfs/proc estáveis ----
    FileView { id: statFile;    path: "/proc/stat";    preload: true; blockLoading: true }
    FileView { id: memFile;     path: "/proc/meminfo"; preload: true; blockLoading: true }
    FileView { id: cpuinfoFile; path: "/proc/cpuinfo"; preload: true; blockLoading: true }

    // ---- resolução de hwmon pelo nome (números mudam por boot) ----
    // coretemp temp1 = "Package id 0" (CPU); spd5118 temp1 = módulo de RAM (DDR5).
    // Atribuímos a path DIRETO quando o nome casa — reatribuir um `var` objeto com
    // a mesma identidade NÃO dispara binding no QML, então evitamos o mapa.
    property string cpuTempPath: ""
    property string ramTempPath: ""

    Instantiator {
        // varre /sys/class/hwmon/hwmon0..23 lendo só o `name` de cada um
        model: 24
        delegate: FileView {
            required property int index
            path: "/sys/class/hwmon/hwmon" + index + "/name"
            preload: true
            blockLoading: true
            printErrors: false
            onLoaded: {
                const t = (text() || "").trim();
                if (t === "coretemp" && !root.cpuTempPath)
                    root.cpuTempPath = "/sys/class/hwmon/hwmon" + index + "/temp1_input";
                else if (t === "spd5118" && !root.ramTempPath)
                    root.ramTempPath = "/sys/class/hwmon/hwmon" + index + "/temp1_input";
            }
        }
    }

    FileView { id: cpuTempFile; path: root.cpuTempPath; preload: true; blockLoading: true; printErrors: false }
    FileView { id: ramTempFile; path: root.ramTempPath; preload: true; blockLoading: true; printErrors: false }

    // ---- GPU via nvidia-smi (Process autorizado) ----
    Process {
        id: gpuProc
        command: ["nvidia-smi",
            "--query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total",
            "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = (text || "").trim().split("\n")[0];
                if (!line)
                    return;
                const p = line.split(",").map(function(s) { return s.trim(); });
                root.gpuPercent  = Number(p[0]) || 0;
                root.gpuTempC    = Math.round(Number(p[1]) || 0);
                root.vramUsedMb  = Number(p[2]) || 0;
                root.vramTotalMb = Number(p[3]) || 0;
                root.gpuAvailable = true;
            }
        }
    }

    // ---- valores expostos ----
    property real cpuPercent: 0
    property real memPercent: 0
    property int  tempC: 0        // CPU
    property int  ramTempC: 0
    property real cpuFreqMhz: 0

    property bool gpuAvailable: false
    property real gpuPercent: 0
    property int  gpuTempC: 0
    property real vramUsedMb: 0
    property real vramTotalMb: 0

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

        // Frequência média da CPU (média de todos os "cpu MHz" do /proc/cpuinfo)
        const ci = cpuinfoFile.text();
        if (ci) {
            const freqs = ci.match(/cpu MHz\s*:\s*([\d.]+)/g);
            if (freqs && freqs.length > 0) {
                let sum = 0;
                for (let i = 0; i < freqs.length; i++)
                    sum += parseFloat(freqs[i].split(":")[1]);
                root.cpuFreqMhz = sum / freqs.length;
            }
        }

        // Temperatura CPU (coretemp, millidegrees → °C)
        const tp = cpuTempFile.text();
        if (tp) {
            const n = parseInt(tp.trim());
            if (!isNaN(n))
                root.tempC = Math.round(n / 1000);
        }

        // Temperatura RAM (spd5118, millidegrees → °C)
        const rp = ramTempFile.text();
        if (rp) {
            const n = parseInt(rp.trim());
            if (!isNaN(n))
                root.ramTempC = Math.round(n / 1000);
        }
    }

    Component.onCompleted: {
        root._recompute();
        gpuProc.running = true;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        // lê o que já foi carregado e dispara o reload para o próximo tick
        onTriggered: {
            root._recompute();
            statFile.reload();
            memFile.reload();
            cpuinfoFile.reload();
            if (root.cpuTempPath)
                cpuTempFile.reload();
            if (root.ramTempPath)
                ramTempFile.reload();
            if (!gpuProc.running)
                gpuProc.running = true;
        }
    }

    // ---- textos prontos para a UI ----
    readonly property string cpuText:  Math.round(root.cpuPercent) + "%"
    readonly property string memText:  Math.round(root.memPercent) + "%"
    readonly property string gpuText:  Math.round(root.gpuPercent) + "%"
    readonly property string tempText:    root.tempC + "°C"
    readonly property string ramTempText: root.ramTempC + "°C"
    readonly property string gpuTempText: root.gpuTempC + "°C"

    readonly property string cpuFreqText: root.cpuFreqMhz >= 1000
        ? (root.cpuFreqMhz / 1000).toFixed(1).replace(".", ",") + " GHz"
        : Math.round(root.cpuFreqMhz) + " MHz"

    readonly property real memTotalGb: {
        const mt = memFile.text();
        if (!mt)
            return 0;
        const tot = mt.match(/MemTotal:\s+(\d+)/);
        return tot ? Number(tot[1]) / 1048576 : 0;
    }
    readonly property real memUsedGb: root.memTotalGb * root.memPercent / 100
    readonly property string memGbText: root.memUsedGb.toFixed(1).replace(".", ",")
        + " / " + Math.round(root.memTotalGb) + " GB"

    readonly property real vramTotalGb: root.vramTotalMb / 1024
    readonly property real vramUsedGb: root.vramUsedMb / 1024
    readonly property string vramText: root.gpuAvailable
        ? root.vramUsedGb.toFixed(1).replace(".", ",") + " / " + Math.round(root.vramTotalGb) + " GB"
        : "—"
}
