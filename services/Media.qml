pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

// Serviço read-only de mídia (Fase 5). Fonte: Quickshell MPRIS (nativo,
// evented). Apenas LEITURA — não dá play/pause/seek, não controla nada.
// Expõe o player "ativo" (prioriza um que esteja tocando) e campos formatados
// para a aba Media da EdgeTop. Em sistemas sem player ativo, `available` é
// false e a UI mostra um estado neutro.
Singleton {
    id: root

    readonly property var _list: Mpris.players ? Mpris.players.values : []

    // player ativo: o primeiro que estiver tocando; senão o primeiro disponível.
    readonly property var player: {
        for (let i = 0; i < root._list.length; i++) {
            if (root._list[i] && root._list[i].isPlaying)
                return root._list[i];
        }
        return root._list.length > 0 ? root._list[0] : null;
    }

    readonly property bool available: !!root.player
    readonly property bool isPlaying: root.available && root.player.isPlaying

    // metadados (somente leitura)
    readonly property string title: root.available && root.player.trackTitle ? root.player.trackTitle : ""
    readonly property string artist: root.available && root.player.trackArtist ? root.player.trackArtist : ""
    readonly property string album: root.available && root.player.trackAlbum ? root.player.trackAlbum : ""

    // progresso (segundos). Releitura periódica via positionChanged() — emitir o
    // sinal força o Quickshell a buscar a posição atual; é LEITURA, não controle.
    // Timer leve (1s) e ativo só enquanto há player tocando.
    readonly property real length: root.available && root.player.lengthSupported ? root.player.length : 0
    readonly property real position: root.available && root.player.positionSupported ? root.player.position : 0
    readonly property real progress: root.length > 0 ? Math.max(0, Math.min(1, root.position / root.length)) : 0

    Timer {
        running: root.available && root.isPlaying
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    function _fmt(sec) {
        if (!sec || sec < 0)
            return "0:00";
        const total = Math.floor(sec);
        const s = total % 60;
        const m = Math.floor(total / 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
    }
    readonly property string positionText: root._fmt(root.position)
    readonly property string lengthText: root._fmt(root.length)
}
