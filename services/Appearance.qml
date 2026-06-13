pragma Singleton

import Quickshell
import QtQuick

// Tema e wallpaper via HyDE (autorizado pelo usuário em 2026-06-13 a mexer no
// HyDE real). EXCEÇÃO DE POLÍTICA: usa Process (Quickshell.execDetached) com a
// interface oficial do HyDE (`hyde-shell`), comandos fixos sem shell eval.
Singleton {
    id: root

    // temas instalados no HyDE (de ~/.config/hyde/themes)
    readonly property var themes: [
        "Catppuccin Mocha",
        "Crimson Blade",
        "default",
        "Gruvbox Retro",
        "Oxo Carbon",
        "Tokyo Night",
        "Vanta Black"
    ]

    function setTheme(name) {
        if (!name)
            return;
        Quickshell.execDetached(["hyde-shell", "theme.switch", "-s", name]);
    }

    function nextTheme() {
        Quickshell.execDetached(["hyde-shell", "theme.switch", "-n"]);
    }

    function prevTheme() {
        Quickshell.execDetached(["hyde-shell", "theme.switch", "-p"]);
    }

    function nextWallpaper() {
        Quickshell.execDetached(["hyde-shell", "wallpaper", "-n"]);
    }

    function prevWallpaper() {
        Quickshell.execDetached(["hyde-shell", "wallpaper", "-p"]);
    }

    function randomWallpaper() {
        Quickshell.execDetached(["hyde-shell", "wallpaper", "-r"]);
    }

    // abre o seletor de wallpaper do HyDE (rofi)
    function selectWallpaper() {
        Quickshell.execDetached(["hyde-shell", "wallpaper", "-S"]);
    }
}
