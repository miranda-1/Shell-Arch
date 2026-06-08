import "../../config"
import "../../components"
import "../../services"
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var modelData
    required property string currentPage
    required property bool contextOpen

    signal requestPage(string pageId)

    screen: modelData
    readonly property string screenMonitorName: Hyprland.monitorNameForScreen(root.screen)
    readonly property var workspaceDots: Hyprland.workspacesForScreen(root.screen)
    readonly property var screenWorkspace: Hyprland.activeWorkspaceForScreen(root.screen)
    readonly property var fallbackWorkspaceDots: [
        { label: "1", active: true, focused: true },
        { label: "2", active: false, focused: false },
        { label: "3", active: false, focused: false }
    ]
    readonly property var visibleWorkspaceDots: root.workspaceDots.length > 0 ? root.workspaceDots : root.fallbackWorkspaceDots
    readonly property bool hasRealWorkspaces: root.workspaceDots.length > 0
    readonly property bool hasActiveWindow: Hyprland.activeWindowTitle !== "Sem janela ativa"
    readonly property string activeWindowTooltip: root.hasActiveWindow
        ? "App: " + Hyprland.activeWindowClass + "\nJanela: " + Hyprland.activeWindowTitle
        : "Sem janela ativa"
    readonly property string screenWorkspaceTooltip: root.screenWorkspace
        ? "Workspace " + Hyprland.workspaceLabel(root.screenWorkspace) + "\n" + Hyprland.workspaceWindowSummary(root.screenWorkspace)
        : "Desktop"

    function isPageActive(pageId) {
        return root.contextOpen && root.currentPage === pageId;
    }

    function workspaceTooltipText(workspace, realWorkspace, activeWorkspace, focusedWorkspace) {
        const label = realWorkspace ? Hyprland.workspaceLabel(workspace) : (workspace && workspace.label ? workspace.label : "\u2014");
        const lines = ["Workspace " + label];

        if (!realWorkspace) {
            lines.push("Estado: " + (focusedWorkspace ? "focused" : activeWorkspace ? "active" : "idle"));
            return lines.join("\n");
        }

        lines.push("Estado: " + Hyprland.workspaceStatusLabel(workspace));
        lines.push(Hyprland.workspaceWindowSummary(workspace));
        return lines.join("\n");
    }

    anchors { left: true; top: true; bottom: true }
    exclusiveZone: Theme.barW
    implicitWidth: Theme.barW + Theme.tooltipReserve
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    mask: Region { x: 0; y: 0; width: Theme.barW; height: root.height }

    Item {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: Theme.barW
        clip: false

        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom }
            x: -30
            width: Theme.barW + 30
            radius: Theme.screenRound + 8
            antialiasing: true
            color: Theme.bar
            border.width: 1
            border.color: Theme.stroke
        }

        Item {
            anchors.fill: parent

            Column {
                anchors { top: parent.top; topMargin: Theme.gap; horizontalCenter: parent.horizontalCenter }
                spacing: 2

                ContextButton {
                    glyph: ""
                    label: "Dashboard"
                    active: root.isPageActive("dashboard")
                    glyphColor: Theme.accent
                    onClicked: root.requestPage("dashboard")
                }

                ContextButton {
                    glyph: ""
                    label: "Busca e launcher"
                    active: root.isPageActive("search")
                    onClicked: root.requestPage("search")
                }

                ContextButton {
                    glyph: ""
                    label: "Calendário"
                    active: root.isPageActive("calendar")
                    onClicked: root.requestPage("calendar")
                }

                ContextButton {
                    glyph: ""
                    label: "Controles"
                    active: root.isPageActive("controls")
                    onClicked: root.requestPage("controls")
                }

                ContextButton {
                    glyph: ""
                    label: Media.available ? "Mídia: " + Media.displayTitle : "Mídia"
                    active: root.isPageActive("media")
                    onClicked: root.requestPage("media")
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.iconSize
                    height: Theme.gap

                    Divider { anchors.centerIn: parent }
                }

                ContextButton {
                    glyph: ""
                    label: root.screenWorkspaceTooltip
                    active: root.isPageActive("workspaces")
                    onClicked: root.requestPage("workspaces")
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 7

                    Repeater {
                        model: root.visibleWorkspaceDots
                        delegate: Item {
                            required property var modelData
                            readonly property bool realWorkspace: Hyprland.isRealWorkspace(modelData)
                            readonly property bool activatableWorkspace: realWorkspace && Hyprland.canActivateWorkspace(modelData)
                            readonly property bool activeWorkspace: realWorkspace ? Hyprland.isWorkspaceActive(modelData) : !!modelData.active
                            readonly property bool focusedWorkspace: realWorkspace ? Hyprland.isWorkspaceFocused(modelData) : !!modelData.focused
                            readonly property bool urgentWorkspace: realWorkspace ? Hyprland.isWorkspaceUrgent(modelData) : false
                            readonly property bool workspaceHasWindows: realWorkspace ? Hyprland.workspaceHasWindows(modelData) : false
                            readonly property string workspaceText: root.workspaceTooltipText(modelData, realWorkspace, activeWorkspace, focusedWorkspace)
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: urgentWorkspace ? 10 : 8
                            height: width

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.focusedWorkspace ? 8 : parent.activeWorkspace ? 7 : parent.workspaceHasWindows ? 6 : 5
                                height: width
                                radius: width / 2
                                antialiasing: true
                                color: parent.focusedWorkspace
                                    ? Theme.accentActive
                                    : parent.activeWorkspace
                                        ? Theme.accent
                                        : parent.workspaceHasWindows
                                            ? Theme.textDim
                                            : Theme.textFaint
                                border.width: parent.urgentWorkspace ? 1 : 0
                                border.color: Theme.accentActive
                                scale: workspaceTap.pressed && parent.activatableWorkspace
                                    ? 0.82
                                    : parent.focusedWorkspace
                                        ? 1.0
                                        : parent.activeWorkspace
                                            ? 0.97
                                            : parent.workspaceHasWindows
                                                ? 0.94
                                                : 0.9

                                Behavior on width { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: Theme.tFast } }
                                Behavior on border.width { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
                                Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
                            }

                            HoverHandler {
                                id: workspaceHover
                                cursorShape: parent.activatableWorkspace ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }

                            TapHandler {
                                id: workspaceTap
                                acceptedButtons: Qt.LeftButton
                                enabled: parent.activatableWorkspace
                                onTapped: Hyprland.activateWorkspace(parent.modelData)
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                x: Theme.barW + Theme.gap + (workspaceHover.hovered ? 0 : -6)
                                width: Math.min(tipText.implicitWidth, 240) + Theme.pad * 2
                                height: tipText.implicitHeight + Theme.gap * 2
                                radius: Theme.radiusSm
                                color: Theme.accentActive
                                border.width: 1
                                border.color: Theme.strokeStrong
                                opacity: workspaceHover.hovered ? 1 : 0
                                visible: opacity > 0

                                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
                                Behavior on x { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }

                                Text {
                                    id: tipText
                                    anchors.centerIn: parent
                                    text: parent.parent.workspaceText
                                    color: Theme.textOnAccent
                                    font.pixelSize: 12
                                    width: Math.min(implicitWidth, 240)
                                }
                            }
                        }
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: Theme.gap

                ContextButton {
                    glyph: ""
                    label: root.activeWindowTooltip
                    active: root.isPageActive("system")
                    glyphColor: root.hasActiveWindow ? Theme.accent : Theme.textDim
                    onClicked: root.requestPage("system")
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.screenMonitorName
                    color: Theme.textDim
                    font.pixelSize: 11
                    rotation: -90
                }
            }

            Column {
                anchors { bottom: parent.bottom; bottomMargin: Theme.gap; horizontalCenter: parent.horizontalCenter }
                spacing: 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Clock.hour
                    color: Theme.text
                    font.pixelSize: 15
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Clock.minute
                    color: Theme.textDim
                    font.pixelSize: 15
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Theme.iconSize
                    height: Theme.gap

                    Divider { anchors.centerIn: parent }
                }

                ContextButton {
                    glyph: ""
                    label: "Sistema\n" + (System.uptimeText || "uptime indisponível")
                    active: root.isPageActive("system")
                    glyphColor: Theme.textDim
                    onClicked: root.requestPage("system")
                }

                ContextButton {
                    glyph: ""
                    label: Battery.available
                        ? "Perfil e energia\n" + Battery.statusText + " • " + Battery.profileText
                        : "Perfil e energia"
                    active: root.isPageActive("profile")
                    glyphColor: Theme.textDim
                    onClicked: root.requestPage("profile")
                }
            }
        }
    }
}
