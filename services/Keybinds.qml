pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Atalhos do Hyprland — SOMENTE LEITURA do keybindings.conf via FileView.
// Faz um parse best-effort do formato `bind(d) = MODS, KEY, [descrição,] ...`.
Singleton {
    id: root

    FileView {
        id: kb
        path: Quickshell.env("HOME") + "/.config/hypr/keybindings.conf"
        preload: true
        blockLoading: true
        watchChanges: true
    }

    function _mods(s) {
        return s.replace(/\$mainMod/gi, "Super")
                .replace(/\bSUPER\b/g, "Super")
                .replace(/\s+/g, " ")
                .trim();
    }

    readonly property var binds: {
        const t = kb.text();
        if (!t)
            return [];

        const out = [];
        const lines = t.split("\n");

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.indexOf("bind") !== 0)
                continue;

            const eq = line.indexOf("=");
            if (eq < 0)
                continue;

            const head = line.slice(0, eq);          // ex.: "bindd"
            const hasDesc = head.indexOf("bindd") === 0;
            const parts = line.slice(eq + 1).split(",").map(function(p) { return p.trim(); });
            if (parts.length < 2)
                continue;

            const mods = root._mods(parts[0]);
            const key = parts[1];
            let desc = "";
            if (hasDesc && parts.length >= 3)
                desc = parts[2];
            else
                desc = parts.slice(2).join(" ");      // fallback: dispatcher + args

            const combo = (mods.length > 0 ? mods + " + " : "") + key;
            out.push({ combo: combo, desc: desc.length > 0 ? desc : "(sem descrição)" });
        }

        return out;
    }
}
