pragma Singleton

import Quickshell
import Quickshell.Hyprland as QsHyprland
import Quickshell.Io
import QtQuick

// Serviço de TELAS (monitores). Duas responsabilidades:
//
//   (a) PARTE SEGURA — escolher em qual monitor o shell aparece. Persiste o nome
//       da tela escolhida em statePath("monitors.json") via JsonAdapter+FileView.
//       O shell.qml lê `shellMonitor` para filtrar `Quickshell.screens`. Não toca
//       no sistema; é só config local da própria shell.
//
//   (b) PARTE COM MUTAÇÃO (exceção de política autorizada pelo usuário em
//       2026-06-19) — mudar Hz/resolução/escala de um monitor no Hyprland VIVO.
//       `Quickshell.Hyprland` não expõe `keyword`, então abrimos um `Socket`
//       (Quickshell.Io) no `requestSocketPath` e escrevemos
//       `keyword monitor <name>,<WxH@Hz>,<x>x<y>,<scale>`. É IPC typed do
//       Quickshell — NÃO é Process. Toda aplicação tem REVERT AUTOMÁTICO: um
//       timer reverte para o modo anterior se o usuário não confirmar (protege
//       contra apagar a tela com um modo inválido).
Singleton {
    id: root

    readonly property var _hypr: QsHyprland.Hyprland
    readonly property string requestSocketPath: root._hypr && root._hypr.requestSocketPath
        ? String(root._hypr.requestSocketPath) : ""

    // ---- (a) tela do shell (config local persistida) ----
    // "" = todas as telas. Caso a tela escolhida não exista, o shell.qml volta a
    // mostrar em todas (fallback seguro), mas a config persistida é preservada.
    readonly property string shellMonitor: cfgAdapter.shellMonitor

    function setShellMonitor(name) {
        cfgAdapter.shellMonitor = name || "";
        cfgFile.writeAdapter();
    }

    FileView {
        id: cfgFile
        path: Quickshell.statePath("monitors.json")
        watchChanges: true
        printErrors: false
        onAdapterUpdated: writeAdapter()
        onFileChanged: reload()
        adapter: JsonAdapter {
            id: cfgAdapter
            property string shellMonitor: ""
        }
    }

    // ---- modelo de monitores (derivado do Hyprland) ----
    // Cada item: { name, description, w, h, hz, scale, x, y, focused, disabled,
    //              modeToken (modo atual p/ revert), modes:[{label,token,w,h,hz}] }
    readonly property var monitors: {
        const out = [];
        const list = (root._hypr && root._hypr.monitors && root._hypr.monitors.values)
            ? root._hypr.monitors.values.slice() : [];

        for (let i = 0; i < list.length; i++) {
            const m = list[i];
            const o = m && m.lastIpcObject ? m.lastIpcObject : {};

            const w = Number(o.width) || 0;
            const h = Number(o.height) || 0;
            const hz = Number(o.refreshRate) || 0;
            const scale = Number(o.scale) || 1;
            const x = Number(o.x) || 0;
            const y = Number(o.y) || 0;

            out.push({
                name: m && m.name ? String(m.name) : String(o.name || ""),
                description: String(o.description || o.model || ""),
                w: w,
                h: h,
                hz: Math.round(hz),
                scale: scale,
                x: x,
                y: y,
                focused: !!o.focused,
                disabled: !!o.disabled,
                // token exato do modo atual (p/ reverter sem arredondar)
                modeToken: w + "x" + h + "@" + hz,
                modes: root._parseModes(o.availableModes)
            });
        }

        return out;
    }

    readonly property int count: root.monitors.length

    function findMonitor(name) {
        const list = root.monitors;
        for (let i = 0; i < list.length; i++)
            if (list[i].name === name)
                return list[i];
        return null;
    }

    // pede ao Hyprland para reemitir os monitores (garante availableModes fresco)
    function refresh() {
        if (root._hypr && root._hypr.refreshMonitors)
            root._hypr.refreshMonitors();
    }

    // availableModes vem como ["2560x1600@240.00100Hz", ...]. Vira lista de modos
    // ordenada (maior resolução / maior Hz primeiro), sem duplicar W×H@Hz.
    function _parseModes(raw) {
        const arr = (raw && raw.slice) ? raw.slice() : [];
        const seen = {};
        const modes = [];

        for (let i = 0; i < arr.length; i++) {
            const entry = String(arr[i]);
            const match = entry.match(/^(\d+)x(\d+)@([\d.]+)Hz$/);
            if (!match)
                continue;

            const w = parseInt(match[1]);
            const h = parseInt(match[2]);
            const hzRaw = match[3];
            const hz = Math.round(parseFloat(hzRaw));
            const token = w + "x" + h + "@" + hzRaw;
            const key = w + "x" + h + "@" + hz;

            if (seen[key])
                continue;
            seen[key] = true;

            modes.push({
                label: w + "×" + h + " · " + hz + " Hz",
                token: token,
                w: w,
                h: h,
                hz: hz
            });
        }

        modes.sort(function(a, b) {
            if (b.w !== a.w) return b.w - a.w;
            if (b.h !== a.h) return b.h - a.h;
            return b.hz - a.hz;
        });

        return modes;
    }

    // escalas comuns oferecidas na UI. Escala rejeitada pelo Hyprland (px físico
    // não-inteiro) simplesmente não aplica → o revert reaplica a anterior.
    readonly property var scaleOptions: [1.0, 1.25, 1.5, 1.6, 1.75, 2.0]

    function _fmtScale(scale) {
        const n = Math.round(Number(scale) * 100) / 100;
        return String(n);
    }

    // ---- aplicação de modo com revert automático ----
    property string pendingName: ""    // monitor com mudança aguardando confirmação
    property string pendingPrevCmd: "" // comando que restaura o estado anterior
    property string pendingDesc: ""    // descrição do modo aplicado (p/ a UI)
    property int    pendingSeconds: 0  // contagem regressiva até o revert
    readonly property bool hasPending: root.pendingName !== ""
    readonly property int revertSeconds: 12

    Timer {
        id: revertCountdown
        interval: 1000
        repeat: true
        running: root.hasPending
        onTriggered: {
            root.pendingSeconds -= 1;
            if (root.pendingSeconds <= 0)
                root.revertNow();
        }
    }

    // Aplica WxH@Hz + escala a um monitor. Captura o estado atual ANTES de enviar
    // (para o revert) e arma a contagem regressiva. Posição é preservada.
    function applyMode(name, modeToken, scale) {
        const m = root.findMonitor(name);
        if (!m || !root.requestSocketPath)
            return false;

        const pos = m.x + "x" + m.y;
        const prevCmd = "keyword monitor " + name + "," + m.modeToken + "," + pos + "," + root._fmtScale(m.scale);
        const newCmd = "keyword monitor " + name + "," + modeToken + "," + pos + "," + root._fmtScale(scale);

        if (!root._send(newCmd))
            return false;

        root.pendingName = name;
        root.pendingPrevCmd = prevCmd;
        root.pendingDesc = name + " · " + modeToken.replace("@", " · ") + " Hz · " + root._fmtScale(scale) + "x";
        root.pendingSeconds = root.revertSeconds;
        return true;
    }

    // confirma o modo atual (cancela o revert agendado)
    function confirmApply() {
        root.pendingName = "";
        root.pendingPrevCmd = "";
        root.pendingDesc = "";
        root.pendingSeconds = 0;
    }

    // reverte imediatamente para o estado anterior
    function revertNow() {
        if (root.pendingPrevCmd)
            root._send(root.pendingPrevCmd);
        root.confirmApply();
    }

    // ---- canal de escrita: Socket no requestSocketPath do Hyprland ----
    // O socket1 do Hyprland processa um comando por conexão e fecha. Mantemos uma
    // fila simples e drenamos um comando por vez: conecta → escreve o head →
    // Hyprland processa e fecha → consome o head → reconecta se sobrou algo.
    property var _queue: []
    property bool _sending: false

    function _send(cmd) {
        if (!root.requestSocketPath)
            return false;
        root._queue = root._queue.concat([cmd]);
        root._pump();
        return true;
    }

    function _pump() {
        if (root._sending || root._queue.length === 0 || !root.requestSocketPath)
            return;
        root._sending = true;
        ctlSocket.connected = true;
    }

    Socket {
        id: ctlSocket
        path: root.requestSocketPath

        onConnectionStateChanged: {
            if (ctlSocket.connected) {
                if (root._queue.length > 0) {
                    ctlSocket.write(root._queue[0]);
                    ctlSocket.flush();
                }
            } else {
                // Hyprland fechou após processar o comando → consome o head
                if (root._queue.length > 0)
                    root._queue = root._queue.slice(1);
                root._sending = false;
                root._pump();
            }
        }
    }
}
