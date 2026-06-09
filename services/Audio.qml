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

    // mantém o node do sink "bound" para os valores de áudio ficarem vivos
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
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
