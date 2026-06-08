import "../../config"
import "../../components"
import "../../services"
import "../Dashboard"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Borda superior: faixa de hover no topo-centro abre um drawer (overlay) que
// desce com slide-down + fade. Abas Dashboard/Media/Performance/Workspaces.
// Não reserva espaço (exclusiveZone 0); máscara restrita à faixa/drawer.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    readonly property var monitorList: Hyprland.monitors && Hyprland.monitors.values ? Hyprland.monitors.values : []
    readonly property var workspaceList: Hyprland.workspaceList
    readonly property var fallbackWorkspaceList: [
        { label: "1", active: true, focused: true, windows: 2, monitorName: root.screen && root.screen.name ? root.screen.name : "\u2014" },
        { label: "2", active: false, focused: false, windows: 1, monitorName: root.screen && root.screen.name ? root.screen.name : "\u2014" },
        { label: "3", active: false, focused: false, windows: 0, monitorName: root.screen && root.screen.name ? root.screen.name : "\u2014" }
    ]
    readonly property var visibleWorkspaceList: root.workspaceList.length > 0 ? root.workspaceList : root.fallbackWorkspaceList
    readonly property int occupiedWorkspaceCount: {
        let count = 0;
        for (let i = 0; i < root.workspaceList.length; i++) {
            if (Hyprland.workspaceHasWindows(root.workspaceList[i]))
                count++;
        }

        return count;
    }
    readonly property int urgentWorkspaceCount: {
        let count = 0;
        for (let i = 0; i < root.workspaceList.length; i++) {
            if (Hyprland.isWorkspaceUrgent(root.workspaceList[i]))
                count++;
        }

        return count;
    }
    function workspaceStateText(workspace, realWorkspace) {
        if (!realWorkspace)
            return workspace && workspace.focused ? "focused" : workspace && workspace.active ? "active" : "idle";

        return Hyprland.workspaceStatusLabel(workspace);
    }

    anchors { top: true; left: true; right: true }
    exclusiveZone: 0
    implicitHeight: 640
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top

    // faixa de gatilho estreita, perto do puxador visível — não a meia-tela toda,
    // pra não abrir o drawer ao mirar a área central por outros motivos.
    readonly property int stripW: 260
    property int tab: 0
    // hover com atraso: evita abrir o drawer só ao passar o mouse no topo
    property bool hovering: stripHover.hovered || drawerHover.hovered
    property bool open: false
    Timer { id: openTimer; interval: Theme.tHoverOpen; onTriggered: root.open = true }
    onHoveringChanged: {
        if (root.hovering) openTimer.start()
        else { openTimer.stop(); root.open = false }
    }

    mask: Region {
        x: root.open ? Math.round(drawer.x) : Math.round((root.width - root.stripW) / 2)
        y: 0
        width: root.open ? Math.ceil(drawer.width) : root.stripW
        height: root.open ? Math.ceil(drawer.height) : 14
    }

    // faixa de hover (topo-centro) — invisível e um pouco mais alta p/ mira fácil
    Item {
        id: strip
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: root.stripW
        height: 14
        HoverHandler { id: stripHover }
    }

    // puxador autônomo: discreto, sem depender de moldura contínua
    Rectangle {
        id: grip
        anchors { top: parent.top; topMargin: 7; horizontalCenter: parent.horizontalCenter }
        width: Theme.gripLen
        height: Theme.gripThickness
        radius: height / 2
        antialiasing: true
        color: root.open ? Theme.gripHover : Theme.gripColor
        opacity: root.open ? 0 : 1
        scale: stripHover.hovered ? 1.04 : 1.0
        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
    }

    // drawer
    Card {
        id: drawer
        anchors.horizontalCenter: parent.horizontalCenter
        width: 880
        height: 470
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: Theme.radiusLg
        bottomRightRadius: Theme.radiusLg
        y: root.open ? 0 : -height - 16
        opacity: root.open ? 1 : 0

        HoverHandler { id: drawerHover }
        Behavior on y { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        // abas
        Row {
            id: tabbar
            anchors { top: parent.top; topMargin: Theme.gap; horizontalCenter: parent.horizontalCenter }
            spacing: Theme.pad
            TabButton { glyph: ""; label: "Dashboard";   active: root.tab === 0; onClicked: root.tab = 0 }
            TabButton { glyph: ""; label: "Media";       active: root.tab === 1; onClicked: root.tab = 1 }
            TabButton { glyph: ""; label: "Performance"; active: root.tab === 2; onClicked: root.tab = 2 }
            TabButton { glyph: ""; label: "Workspaces";  active: root.tab === 3; onClicked: root.tab = 3 }
        }

        Divider {
            id: divider
            // mesmas medidas do divisor inline anterior: recuo de Theme.pad nos
            // dois lados (largura = parent - 2*pad, centralizado → esquerda em pad).
            anchors { top: tabbar.bottom; topMargin: Theme.gap / 2; horizontalCenter: parent.horizontalCenter }
            width: parent.width - Theme.pad * 2
            height: 1
        }

        // conteúdo das abas
        Item {
            id: content
            anchors { top: divider.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: Theme.pad }

            // 0 — Dashboard
            Dashboard {
                anchors.centerIn: parent
                visible: opacity > 0
                opacity: root.tab === 0 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
            }

            // 1 — Media
            Row {
                anchors.centerIn: parent
                spacing: 44
                visible: opacity > 0
                opacity: root.tab === 1 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 160; height: 160; radius: 80
                    antialiasing: true
                    color: Theme.accentSoft
                    Text { anchors.centerIn: parent; text: ""; font.family: Theme.iconFont; font.pixelSize: 60; color: Theme.accent }  // nota
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    MarqueeText {
                        text: Media.displayTitle
                        maxWidth: 380
                        pixelSize: 22
                        bold: true
                        color: Theme.text
                    }
                    MarqueeText {
                        text: Media.displaySubtitle
                        maxWidth: 360
                        pixelSize: 14
                        color: Theme.textDim
                        pauseDuration: 1100
                        endPauseDuration: 800
                    }
                    Row {
                        spacing: 8

                        Rectangle {
                            width: statusBadgeText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: Media.isPlaying ? Theme.accentSoft : Theme.cardHover

                            Text {
                                id: statusBadgeText
                                anchors.centerIn: parent
                                text: Media.statusText
                                font.pixelSize: 11
                                color: Media.isPlaying ? Theme.accentActive : Theme.textDim
                            }
                        }

                        Rectangle {
                            visible: Media.available
                            width: sourceBadgeText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: Theme.cardHover

                            Text {
                                id: sourceBadgeText
                                anchors.centerIn: parent
                                text: Media.activePlayerName
                                font.pixelSize: 11
                                color: Theme.textDim
                            }
                        }

                        Rectangle {
                            visible: Media.playerCount > 1
                            width: countBadgeText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: Theme.cardHover

                            Text {
                                id: countBadgeText
                                anchors.centerIn: parent
                                text: Media.playerCount + " players"
                                font.pixelSize: 11
                                color: Theme.textDim
                            }
                        }
                    }
                    Row {
                        spacing: Theme.pad + 6
                        topPadding: 6
                        Item {
                            width: 24
                            height: 24
                            opacity: Media.canPrevious ? 1 : 0.38
                            scale: previousTap.pressed && Media.canPrevious ? 0.92 : previousHover.hovered && Media.canPrevious ? 1.06 : 1.0

                            Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: Theme.iconFont
                                font.pixelSize: 22
                                color: Theme.textDim
                            }

                            HoverHandler {
                                id: previousHover
                                enabled: Media.canPrevious
                                cursorShape: Media.canPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }

                            TapHandler {
                                id: previousTap
                                acceptedButtons: Qt.LeftButton
                                enabled: Media.canPrevious
                                onTapped: Media.previous()
                            }
                        }
                        Item {
                            width: 30
                            height: 30
                            opacity: Media.canPlayPause ? 1 : 0.5
                            scale: playPauseTap.pressed && Media.canPlayPause ? 0.92 : playPauseHover.hovered && Media.canPlayPause ? 1.05 : 1.0

                            Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: Media.isPlaying ? "" : ""
                                font.family: Theme.iconFont
                                font.pixelSize: 28
                                color: Media.canPlayPause ? Theme.accent : Theme.textDim
                            }

                            HoverHandler {
                                id: playPauseHover
                                enabled: Media.canPlayPause
                                cursorShape: Media.canPlayPause ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }

                            TapHandler {
                                id: playPauseTap
                                acceptedButtons: Qt.LeftButton
                                enabled: Media.canPlayPause
                                onTapped: Media.playPause()
                            }
                        }
                        Item {
                            width: 24
                            height: 24
                            opacity: Media.canNext ? 1 : 0.38
                            scale: nextTap.pressed && Media.canNext ? 0.92 : nextHover.hovered && Media.canNext ? 1.06 : 1.0

                            Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                font.family: Theme.iconFont
                                font.pixelSize: 22
                                color: Theme.textDim
                            }

                            HoverHandler {
                                id: nextHover
                                enabled: Media.canNext
                                cursorShape: Media.canNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                            }

                            TapHandler {
                                id: nextTap
                                acceptedButtons: Qt.LeftButton
                                enabled: Media.canNext
                                onTapped: Media.next()
                            }
                        }
                    }
                    Row {
                        spacing: Theme.gap
                        topPadding: 6
                        Text { anchors.verticalCenter: parent.verticalCenter; text: Media.positionText; font.pixelSize: 12; color: Theme.textDim }
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 280; height: 5; radius: 3; color: Theme.accentTrack
                            Rectangle { anchors { left: parent.left; top: parent.top; bottom: parent.bottom } width: parent.width * Media.progress; radius: 3; color: Theme.accent }
                        }
                        Text { anchors.verticalCenter: parent.verticalCenter; text: Media.lengthText; font.pixelSize: 12; color: Theme.textDim }
                    }
                }
            }

            // 2 — Performance
            Row {
                anchors.centerIn: parent
                spacing: 40
                visible: opacity > 0
                opacity: root.tab === 2 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                RingMeter { value: 0.54; big: "54°C"; sub: "GPU temp" }
                RingMeter { value: 0.41; big: "41°C"; sub: "CPU temp" }
                RingMeter { value: 0.23; big: "5.4GiB"; sub: "Memory" }
            }

            // 3 — Workspaces / estado do Hyprland
            Item {
                anchors.fill: parent
                visible: opacity > 0
                opacity: root.tab === 3 ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

                Flickable {
                    anchors.fill: parent
                    clip: true
                    contentWidth: width
                    contentHeight: workspaceTabContent.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: workspaceTabContent
                        width: parent.width
                        spacing: Theme.gap

                        Row {
                            id: summaryRow
                            property int windowCardWidth: Math.round((width - Theme.gap) * 0.5)
                            width: parent.width
                            spacing: Theme.gap

                            Rectangle {
                                width: summaryRow.windowCardWidth
                                height: 118
                                radius: Theme.radiusSm
                                antialiasing: true
                                color: Theme.card
                                border.width: 1
                                border.color: Theme.stroke

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Theme.pad
                                    spacing: 6

                                    Text {
                                        text: "Agora"
                                        font.pixelSize: 12
                                        color: Theme.textDim
                                    }

                                    MarqueeText {
                                        text: Hyprland.activeWindowTitle
                                        color: Theme.text
                                        pixelSize: 17
                                        bold: true
                                        maxWidth: parent.width
                                        pauseDuration: 1000
                                        endPauseDuration: 760
                                    }

                                    Text {
                                        text: "App: " + Hyprland.activeWindowClass
                                        font.pixelSize: 12
                                        color: Theme.textDim
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: "Workspace " + Hyprland.activeWorkspaceLabel
                                        font.pixelSize: 12
                                        color: Theme.textDim
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }
                                }
                            }

                            Rectangle {
                                width: summaryRow.width - summaryRow.windowCardWidth - summaryRow.spacing
                                height: 118
                                radius: Theme.radiusSm
                                antialiasing: true
                                color: Theme.card
                                border.width: 1
                                border.color: Theme.stroke

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Theme.pad
                                    spacing: 6

                                    Text {
                                        text: "Vis\u00e3o geral"
                                        font.pixelSize: 12
                                        color: Theme.textDim
                                    }

                                    Text {
                                        text: root.workspaceList.length > 0
                                            ? root.occupiedWorkspaceCount + " workspaces ocupados"
                                            : "Sem dados de workspace"
                                        font.pixelSize: 17
                                        color: Theme.text
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Row {
                                        spacing: 8

                                        Rectangle {
                                            width: totalBadgeText.implicitWidth + 14
                                            height: 24
                                            radius: 12
                                            color: Theme.accentSoft

                                            Text {
                                                id: totalBadgeText
                                                anchors.centerIn: parent
                                                text: root.visibleWorkspaceList.length + " total"
                                                font.pixelSize: 11
                                                color: Theme.accentActive
                                            }
                                        }

                                        Rectangle {
                                            width: activeBadgeText.implicitWidth + 14
                                            height: 24
                                            radius: 12
                                            color: Theme.cardHover

                                            Text {
                                                id: activeBadgeText
                                                anchors.centerIn: parent
                                                text: Hyprland.activeWorkspaceLabel === "\u2014" ? "sem foco" : "foco " + Hyprland.activeWorkspaceLabel
                                                font.pixelSize: 11
                                                color: Theme.textDim
                                            }
                                        }

                                        Rectangle {
                                            visible: root.urgentWorkspaceCount > 0
                                            width: urgentBadgeText.implicitWidth + 14
                                            height: 24
                                            radius: 12
                                            color: Theme.cardHover

                                            Text {
                                                id: urgentBadgeText
                                                anchors.centerIn: parent
                                                text: root.urgentWorkspaceCount + " urgente"
                                                font.pixelSize: 11
                                                color: Theme.textDim
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: Theme.gap

                            Repeater {
                                model: root.visibleWorkspaceList
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool realWorkspace: Hyprland.isRealWorkspace(modelData)
                                    readonly property bool activatableWorkspace: realWorkspace && Hyprland.canActivateWorkspace(modelData)
                                    readonly property bool focusedWorkspace: realWorkspace ? Hyprland.isWorkspaceFocused(modelData) : !!modelData.focused
                                    readonly property bool activeWorkspace: realWorkspace ? Hyprland.isWorkspaceActive(modelData) : !!modelData.active
                                    readonly property bool urgentWorkspace: realWorkspace ? Hyprland.isWorkspaceUrgent(modelData) : false
                                    readonly property bool hasWindows: realWorkspace ? Hyprland.workspaceHasWindows(modelData) : (modelData && modelData.windows > 0)
                                    readonly property int windowCount: realWorkspace ? Hyprland.workspaceWindowCount(modelData) : (modelData && modelData.windows ? modelData.windows : 0)
                                    readonly property string workspaceLabel: realWorkspace ? Hyprland.workspaceLabel(modelData) : (modelData && modelData.label ? modelData.label : "\u2014")
                                    readonly property string workspaceSummary: realWorkspace
                                        ? Hyprland.workspaceWindowSummary(modelData)
                                        : (windowCount > 0 ? windowCount + " janelas abertas" : "Vazio")
                                    width: 168
                                    height: 100
                                    radius: Theme.radiusSm
                                    antialiasing: true
                                    color: focusedWorkspace
                                        ? Theme.accentSoft
                                        : activeWorkspace
                                            ? Qt.darker(Theme.accentSoft, 1.03)
                                            : workspaceTap.pressed && activatableWorkspace
                                                ? Qt.darker(Theme.cardHover, 1.02)
                                                : workspaceHover.hovered && activatableWorkspace
                                                    ? Theme.cardHover
                                                    : Theme.card
                                    border.width: urgentWorkspace || focusedWorkspace ? 2 : 1
                                    border.color: focusedWorkspace
                                        ? Theme.accent
                                        : urgentWorkspace
                                            ? Theme.accentActive
                                            : workspaceHover.hovered && activatableWorkspace
                                                ? Theme.strokeStrong
                                                : Theme.stroke
                                    scale: workspaceTap.pressed && activatableWorkspace ? 0.985 : 1.0

                                    Behavior on color { ColorAnimation { duration: Theme.tFast } }
                                    Behavior on border.color { ColorAnimation { duration: Theme.tFast } }
                                    Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }

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

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6

                                        Row {
                                            width: parent.width
                                            spacing: 8

                                            Text {
                                                width: parent.width - statusBadge.width - parent.spacing
                                                text: "Workspace " + parent.parent.parent.workspaceLabel
                                                font.pixelSize: 15
                                                color: parent.parent.parent.focusedWorkspace ? Theme.accentActive : Theme.text
                                                font.bold: true
                                                elide: Text.ElideRight
                                            }

                                            Rectangle {
                                                id: statusBadge
                                                width: statusBadgeText.implicitWidth + 12
                                                height: 22
                                                radius: 11
                                                color: parent.parent.parent.focusedWorkspace
                                                    ? Theme.accentActive
                                                    : parent.parent.parent.activeWorkspace
                                                        ? Theme.accent
                                                        : Theme.cardHover

                                                Text {
                                                    id: statusBadgeText
                                                    anchors.centerIn: parent
                                                    text: root.workspaceStateText(parent.parent.parent.modelData, parent.parent.parent.realWorkspace)
                                                    font.pixelSize: 11
                                                    color: parent.parent.parent.focusedWorkspace || parent.parent.parent.activeWorkspace
                                                        ? Theme.textOnAccent
                                                        : Theme.textDim
                                                }
                                            }
                                        }

                                        MarqueeText {
                                            text: parent.parent.workspaceSummary
                                            maxWidth: parent.width
                                            pixelSize: 13
                                            color: parent.parent.hasWindows ? Theme.text : Theme.textDim
                                            pauseDuration: 1000
                                            endPauseDuration: 720
                                        }

                                        Text {
                                            text: parent.parent.windowCount > 0
                                                ? parent.parent.windowCount + (parent.parent.windowCount === 1 ? " janela aberta" : " janelas abertas")
                                                : "Vazio"
                                            font.pixelSize: 11
                                            color: parent.parent.hasWindows ? Theme.textDim : Theme.textFaint
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
