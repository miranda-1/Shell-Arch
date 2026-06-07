pragma Singleton

import Quickshell
import Quickshell.Hyprland as QsHyprland
import QtQuick

// Serviço read-only de estado do Hyprland (Fase 6). Fonte primária:
// singleton nativo `Quickshell.Hyprland.Hyprland`, que consome o IPC/socket
// do compositor sem depender de `hyprctl`.
//
// Regras deste serviço:
// - NÃO usa Process
// - NÃO usa hyprctl no runtime
// - NÃO chama dispatch
// - NÃO chama workspace.activate()
// - NÃO expõe métodos de ação/mutação
// - Apenas adapta dados já expostos pelo módulo nativo para a UI
Singleton {
    id: root

    readonly property var _hypr: QsHyprland.Hyprland
    readonly property string _fallback: "\u2014"

    readonly property bool available: !!root._hypr.requestSocketPath && !!root._hypr.eventSocketPath

    readonly property string requestSocketPath: root.available ? root._hypr.requestSocketPath : ""
    readonly property string eventSocketPath: root.available ? root._hypr.eventSocketPath : ""

    readonly property var monitors: root._hypr.monitors
    readonly property var workspaces: root._hypr.workspaces
    readonly property var focusedMonitor: root._hypr.focusedMonitor
    readonly property var focusedWorkspace: root._hypr.focusedWorkspace
    readonly property var activeToplevel: root._hypr.activeToplevel
    readonly property var workspaceList: {
        const list = root.workspaces ? root.workspaces.values.slice() : [];
        list.sort((a, b) => root.workspaceSortKey(a) - root.workspaceSortKey(b));
        return list;
    }

    readonly property string activeWindowTitle: {
        if (!root.activeToplevel || !root.activeToplevel.title)
            return root._fallback;
        return root.activeToplevel.title;
    }

    readonly property string activeWindowClass: {
        if (!root.activeToplevel)
            return root._fallback;

        const object = root.activeToplevel.lastIpcObject;
        if (object && object["class"])
            return object["class"];
        if (object && object["initialClass"])
            return object["initialClass"];

        return root._fallback;
    }

    readonly property string focusedMonitorName: {
        if (!root.focusedMonitor || !root.focusedMonitor.name)
            return root._fallback;
        return root.focusedMonitor.name;
    }

    readonly property string focusedWorkspaceName: {
        if (!root.focusedWorkspace)
            return root._fallback;
        return root.workspaceLabel(root.focusedWorkspace);
    }

    function workspaceLabel(workspace) {
        if (!workspace)
            return root._fallback;
        if (workspace.name)
            return workspace.name;
        if (workspace.id !== undefined && workspace.id !== null)
            return String(workspace.id);
        return root._fallback;
    }

    function isWorkspaceActive(workspace) {
        return !!(workspace && workspace.active);
    }

    function isWorkspaceFocused(workspace) {
        return !!(workspace && workspace.focused);
    }

    function workspaceSortKey(workspace) {
        if (!workspace || workspace.id === undefined || workspace.id === null)
            return 2147483647;
        return workspace.id;
    }

    function monitorForScreen(screen) {
        if (!root.available || !screen)
            return null;
        return root._hypr.monitorFor(screen);
    }

    function workspacesForMonitorName(name) {
        const list = root.workspaceList;
        const filtered = [];

        for (let i = 0; i < list.length; i++) {
            const workspace = list[i];
            if (workspace && workspace.monitor && workspace.monitor.name === name)
                filtered.push(workspace);
        }

        return filtered;
    }

    function workspacesForScreen(screen) {
        const monitor = root.monitorForScreen(screen);

        if (monitor && monitor.name) {
            const filtered = root.workspacesForMonitorName(monitor.name);
            if (filtered.length > 0)
                return filtered;
        }

        return root.workspaceList;
    }
}
