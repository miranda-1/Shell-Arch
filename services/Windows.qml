pragma Singleton

import Quickshell
import Quickshell.Wayland
import QtQuick

// Serviço de janelas (toplevels Wayland) — usado pela visão "alt-tab" da
// WorkspacesPage. Fonte: ToplevelManager (wlr-foreign-toplevel), nativo do
// Quickshell. Leitura da lista + foco via `activate()` typed (mesma natureza
// permitida que `workspace.activate()` — NÃO é Process). Não fecha nem mata
// janelas pela shell.
Singleton {
    id: root

    readonly property var _mgr: ToplevelManager
    readonly property var activeToplevel: root._mgr.activeToplevel

    // Lista materializada e ordenada por app (estável entre repaints).
    readonly property var windowList: {
        const model = root._mgr.toplevels;
        const list = (model && model.values && model.values.slice) ? model.values.slice() : [];
        list.sort(function(a, b) {
            const la = root.appLabel(a).toLowerCase();
            const lb = root.appLabel(b).toLowerCase();
            if (la < lb) return -1;
            if (la > lb) return 1;
            return 0;
        });
        return list;
    }

    readonly property int count: root.windowList.length
    readonly property bool hasWindows: root.count > 0

    // rótulo principal do card: appId, senão título, senão travessão.
    function appLabel(toplevel) {
        if (!toplevel)
            return "—";
        const id = String(toplevel.appId || "").trim();
        if (id)
            return id;
        const title = String(toplevel.title || "").trim();
        return title || "—";
    }

    function titleText(toplevel) {
        return toplevel ? String(toplevel.title || "").trim() : "";
    }

    function isActive(toplevel) {
        return !!(toplevel && toplevel.activated);
    }

    // Foca a janela. API typed do Quickshell (wlr activation) — não é Process.
    function focus(toplevel) {
        if (!toplevel)
            return false;
        toplevel.activate();
        return true;
    }
}
