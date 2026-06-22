pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Serviço de áudio via Pipewire (API typed do Quickshell — sem comando
// externo). Lê volume/mudo do sink padrão e, na fase de controles
// funcionais (autorizada), escreve volume e mute pelo mesmo node typed.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink

    // todas as saídas de áudio reais (sinks que NÃO são streams de apps)
    readonly property var sinks: {
        const out = [];
        const nodes = Pipewire.nodes ? Pipewire.nodes.values : [];
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i];
            if (n && n.isSink && !n.isStream)
                out.push(n);
        }
        return out;
    }

    // há mais de uma saída pra onde dá pra mandar o som?
    readonly property bool hasMultipleSinks: root.sinks.length > 1

    // mantém o sink padrão E todas as saídas "bound" para descrição/estado
    // ficarem vivos (senão description/nickname podem vir vazios)
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    PwObjectTracker {
        objects: root.sinks
    }

    // rótulo amigável de uma saída qualquer
    function sinkLabel(node) {
        if (!node)
            return "";
        return node.description || node.nickname || node.name || "Saída";
    }

    // essa saída é a padrão atual?
    function isDefaultSink(node) {
        return !!node && !!root.sink && node.id === root.sink.id;
    }

    // manda o som passar a sair por esta saída (vira o sink padrão)
    function setDefaultSink(node) {
        if (!node || root.isDefaultSink(node))
            return false;
        Pipewire.preferredDefaultAudioSink = node;
        return true;
    }

    readonly property bool available: !!root.sink && !!root.sink.audio && root.sink.ready
    readonly property real volume: root.available ? root.sink.audio.volume : 0
    readonly property bool muted: root.available ? root.sink.audio.muted : false

    readonly property string deviceName: {
        if (!root.sink)
            return "";

        return root.sink.description || root.sink.nickname || root.sink.name || "";
    }

    readonly property string statusText: {
        if (!root.available)
            return "Pipewire indisponível";
        if (root.muted)
            return "Mudo";
        return Math.round(Math.min(1, Math.max(0, root.volume)) * 100) + "%";
    }

    function setVolume(value) {
        if (!root.available)
            return false;

        root.sink.audio.volume = Math.max(0, Math.min(1, value));
        return true;
    }

    function toggleMute() {
        if (!root.available)
            return false;

        root.sink.audio.muted = !root.sink.audio.muted;
        return true;
    }
}
