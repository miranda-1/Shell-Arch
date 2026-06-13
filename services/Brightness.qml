pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Serviço de brilho da TELA INTERNA do notebook.
// Decisão do usuário (2026-06-13): controlar SOMENTE a tela interna; o monitor
// externo (que exigiria DDC/ddcutil) fica de fora de propósito.
//
// ATENÇÃO — exceção de política: este é o ÚNICO ponto do projeto que usa um
// processo externo. A LEITURA do brilho é via sysfs (FileView, sem efeito
// colateral). A ESCRITA usa `brightnessctl`, que ajusta o backlight via
// systemd-logind (sem root) — o sysfs é root-only, então não há como escrever
// direto. O comando é fixo, sem interpolação de shell, escopado ao backlight
// interno detectado. Nada além de brilho passa por aqui.
Singleton {
    id: root

    // backlight interno detectado nesta máquina
    readonly property string device: "nvidia_wmi_ec_backlight"
    readonly property string basePath: "/sys/class/backlight/" + root.device

    FileView {
        id: curFile
        path: root.basePath + "/brightness"
        preload: true
        blockLoading: true
        watchChanges: true   // reflete mudanças feitas por teclado/externas
    }

    FileView {
        id: maxFile
        path: root.basePath + "/max_brightness"
        preload: true
        blockLoading: true
    }

    readonly property int rawMax: {
        const t = maxFile.text();
        const n = t ? parseInt(t.trim()) : 0;
        return isNaN(n) ? 0 : n;
    }

    readonly property int rawValue: {
        const t = curFile.text();
        const n = t ? parseInt(t.trim()) : 0;
        return isNaN(n) ? 0 : n;
    }

    readonly property bool available: root.rawMax > 0

    // 0–1 para o slider
    readonly property real value: root.available
        ? Math.max(0, Math.min(1, root.rawValue / root.rawMax))
        : 0

    // define o brilho (fração 0–1). Piso de 2% para nunca apagar a tela.
    function setPercent(frac) {
        if (!root.available)
            return false;
        const pct = Math.round(Math.max(0.02, Math.min(1, frac)) * 100);
        Quickshell.execDetached(["brightnessctl", "-d", root.device, "set", pct + "%"]);
        return true;
    }
}
