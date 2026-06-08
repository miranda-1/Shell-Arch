import "../../components"
import "../../config"
import "../../services"
import "pages"
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var modelData
    required property bool open
    required property string currentPage

    signal requestClose()

    screen: modelData
    anchors { top: true; left: true; right: true }
    exclusiveZone: 0
    implicitHeight: Math.min(Math.max(root.screenHeight * 0.7, 520), 860)
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.open && root.currentPage === "search"
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    readonly property real screenWidth: root.screen && root.screen.width ? root.screen.width : 1440
    readonly property real screenHeight: root.screen && root.screen.height ? root.screen.height : 900
    readonly property real railOffset: Theme.barW + 18
    readonly property real availableWidth: Math.max(720, root.screenWidth - root.railOffset - 48)
    readonly property real compactWidth: Math.min(Math.max(root.availableWidth * 0.56, 640), 820)
    readonly property real expandedWidth: Math.min(root.availableWidth, 1180)
    readonly property real panelWidth: root.open ? root.expandedWidth : root.compactWidth
    readonly property real panelHeight: Math.min(Math.max(root.screenHeight * 0.57, 480), 720)
    readonly property real topOffset: 14
    readonly property real bridgeHeight: root.open ? 24 : 0
    readonly property string pageGlyph: root.metaForPage(root.currentPage).glyph
    readonly property string pageTitle: root.metaForPage(root.currentPage).title
    readonly property string pageSubtitle: root.metaForPage(root.currentPage).subtitle
    readonly property var headerPills: root.pillsForPage(root.currentPage)

    function metaForPage(pageId) {
        switch (pageId) {
        case "search":
            return { glyph: "", title: "Busca e Launcher", subtitle: "Procure apps, atalhos e pontos de entrada sem sair da superfície principal." };
        case "calendar":
            return { glyph: "", title: "Calendário", subtitle: "Hora, data e visão mensal num painel dedicado e estável." };
        case "controls":
            return { glyph: "", title: "Controles", subtitle: "Rede, energia e placeholders visuais para ajustes futuros seguros." };
        case "media":
            return { glyph: "", title: "Mídia", subtitle: "Estado MPRIS real, progresso e controles já aprovados centralizados aqui." };
        case "workspaces":
            return { glyph: "", title: "Workspaces", subtitle: "Resumo real do Hyprland por tela com troca segura de workspace." };
        case "system":
            return { glyph: "", title: "Sistema", subtitle: "Sessão, uptime, bateria e leituras do ambiente atual sem polling externo." };
        case "profile":
            return { glyph: "", title: "Perfil e Energia", subtitle: "Identidade da sessão e ações futuras expostas apenas como placeholders." };
        case "dashboard":
        default:
            return { glyph: "", title: "Dashboard", subtitle: "Resumo vivo da shell com janela ativa, rede, bateria, mídia e contexto da tela." };
        }
    }

    function pillsForPage(pageId) {
        const pills = [
            { glyph: "", text: Hyprland.monitorNameForScreen(root.screen), active: true }
        ];

        switch (pageId) {
        case "media":
            pills.push({ glyph: "", text: Media.available ? Media.statusText : "Sem player", active: Media.available });
            if (Media.available)
                pills.push({ glyph: "", text: Media.activePlayerName, active: false });
            break;
        case "workspaces":
            pills.push({ glyph: "", text: "WS " + Hyprland.activeWorkspaceLabel, active: true });
            pills.push({ glyph: "", text: Hyprland.activeWindowClass, active: false });
            break;
        case "controls":
            pills.push({ glyph: "", text: Network.statusText, active: Network.connected });
            if (Battery.available)
                pills.push({ glyph: "", text: Battery.statusText, active: Battery.onBattery });
            break;
        case "calendar":
            pills.push({ glyph: "", text: Clock.dateText, active: false });
            break;
        case "search":
            pills.push({ glyph: "", text: "Launcher embutido", active: true });
            break;
        case "system":
        case "profile":
            pills.push({ glyph: "", text: System.osName || "Linux", active: false });
            if (Battery.available)
                pills.push({ glyph: "", text: Battery.profileText, active: true });
            break;
        default:
            pills.push({ glyph: "", text: Network.statusText, active: Network.connected });
            pills.push({ glyph: "", text: Hyprland.activeWindowClass, active: false });
            if (Battery.available)
                pills.push({ glyph: "", text: Battery.statusText, active: Battery.onBattery });
            break;
        }

        return pills;
    }

    mask: Region {
        x: Math.round((root.width - root.panelWidth) / 2)
        y: root.topOffset
        width: Math.ceil(root.panelWidth)
        height: root.open
            ? Math.ceil(root.panelHeight + bar.height + root.bridgeHeight)
            : Math.ceil(bar.height)
    }

    Rectangle {
        id: bar
        x: (root.width - root.panelWidth) / 2
        y: root.topOffset
        width: root.panelWidth
        height: 72
        radius: Theme.radiusLg
        antialiasing: true
        color: Qt.rgba(Theme.surfaceStrong.r, Theme.surfaceStrong.g, Theme.surfaceStrong.b, root.open ? 0.995 : 0.96)
        border.width: 1
        border.color: Theme.strokeStrong

        Behavior on x { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on width { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on color { ColorAnimation { duration: Theme.tFast } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.pad
            anchors.rightMargin: Theme.pad
            spacing: Theme.pad

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 44
                radius: 22
                antialiasing: true
                color: Theme.accentSoft

                Text {
                    anchors.centerIn: parent
                    text: root.pageGlyph
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                    color: Theme.accentActive
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 246
                spacing: 4

                Text {
                    text: root.pageTitle
                    font.pixelSize: Theme.fsTitle
                    font.bold: true
                    color: Theme.text
                }

                MarqueeText {
                    text: root.open ? root.pageSubtitle : Hyprland.activeWindowSummary
                    maxWidth: parent.width
                    pixelSize: Theme.fsBodyLg
                    color: Theme.textDim
                    pauseDuration: 1100
                    endPauseDuration: 800
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 30
                color: Theme.stroke
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: Clock.timeText
                    font.pixelSize: Theme.fsTitle
                    font.bold: true
                    color: Theme.text
                }

                Text {
                    text: Clock.dateText
                    font.pixelSize: Theme.fsBody
                    color: Theme.textDim
                }
            }

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: closeHover.hovered ? Theme.accentSoft : Theme.cardHover
                    antialiasing: true
                    opacity: root.open ? 1 : 0.8
                }

                Text {
                    anchors.centerIn: parent
                    text: root.open ? "" : ""
                    font.family: Theme.iconFont
                    font.pixelSize: 13
                    color: Theme.textDim
                }

                HoverHandler {
                    id: closeHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: root.requestClose()
                }
            }
        }
    }

    Rectangle {
        x: bar.x
        y: bar.y + bar.height - 10
        width: bar.width
        height: root.bridgeHeight
        radius: 14
        antialiasing: true
        opacity: root.open ? 1 : 0
        color: Qt.rgba(Theme.surfaceStrong.r, Theme.surfaceStrong.g, Theme.surfaceStrong.b, 0.99)
        border.width: root.open ? 1 : 0
        border.color: Theme.strokeStrong

        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on height { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on width { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
    }

    Card {
        id: sheet
        x: (root.width - root.expandedWidth) / 2
        y: root.open ? bar.y + bar.height + 6 : bar.y - root.panelHeight - 28
        width: root.expandedWidth
        height: root.panelHeight
        radius: Theme.radiusLg
        color: Qt.rgba(Theme.surfaceStrong.r, Theme.surfaceStrong.g, Theme.surfaceStrong.b, 0.995)
        border.color: Theme.strokeStrong
        opacity: root.open ? 1 : 0
        clip: true
        visible: opacity > 0

        Behavior on x { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on y { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.pad + 2
            spacing: Theme.pad

            TopSheetHeader {
                width: parent.width
                glyph: root.pageGlyph
                title: root.pageTitle
                subtitle: root.pageSubtitle
                pills: root.headerPills
                showCloseButton: true
                onCloseRequested: root.requestClose()
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.stroke
            }

            Flickable {
                id: scroll
                width: parent.width
                height: parent.height - 105
                clip: true
                contentWidth: width
                contentHeight: pageLoader.item ? pageLoader.item.implicitHeight : 0
                boundsBehavior: Flickable.StopAtBounds

                Loader {
                    id: pageLoader
                    width: scroll.width
                    sourceComponent: root.currentPage === "search" ? searchPage
                        : root.currentPage === "calendar" ? calendarPage
                        : root.currentPage === "controls" ? controlsPage
                        : root.currentPage === "media" ? mediaPage
                        : root.currentPage === "workspaces" ? workspacesPage
                        : root.currentPage === "system" ? systemPage
                        : root.currentPage === "profile" ? profilePage
                        : dashboardPage
                }
            }
        }
    }

    Component {
        id: dashboardPage
        DashboardPage {
            width: pageLoader.width
            screenRef: root.screen
        }
    }

    Component {
        id: searchPage
        SearchPage {
            width: pageLoader.width
            open: root.open
        }
    }

    Component {
        id: calendarPage
        CalendarPage {
            width: pageLoader.width
        }
    }

    Component {
        id: controlsPage
        ControlsPage {
            width: pageLoader.width
        }
    }

    Component {
        id: mediaPage
        MediaPage {
            width: pageLoader.width
        }
    }

    Component {
        id: workspacesPage
        WorkspacesPage {
            width: pageLoader.width
            screenRef: root.screen
        }
    }

    Component {
        id: systemPage
        SystemPage {
            width: pageLoader.width
            screenRef: root.screen
        }
    }

    Component {
        id: profilePage
        ProfilePage {
            width: pageLoader.width
            screenRef: root.screen
        }
    }
}
