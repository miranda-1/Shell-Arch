pragma Singleton

import Quickshell
import QtQuick

// Ações de energia/sessão (autorizadas pelo usuário em 2026-06-13).
// EXCEÇÃO DE POLÍTICA: usa Process (Quickshell.execDetached) com comandos fixos,
// sem interpolação de shell. A UI (PowerPage) exige confirmação antes de cada
// ação destrutiva. O boot no Windows usa a entrada systemd-boot já existente.
Singleton {
    id: root

    // entrada do systemd-boot para o Windows (confirmada via `bootctl list`)
    readonly property string windowsEntry: "windows.conf"

    function lock() {
        Quickshell.execDetached(["loginctl", "lock-session"]);
    }

    function logout() {
        Quickshell.execDetached(["hyde-shell", "logout"]);
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    // reinicia já selecionando a entrada do Windows no próximo boot
    function rebootWindows() {
        Quickshell.execDetached(["systemctl", "reboot", "--boot-loader-entry=" + root.windowsEntry]);
    }
}
