import "../../config"
import "../../components"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Launcher: faixa de hover no rodapé-centro faz um painel SUBIR (slide-up +
// fade). Campo de busca fake + lista read-only de apps via DesktopEntries.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors { bottom: true; left: true; right: true }
    exclusiveZone: 0
    implicitHeight: 420
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    // Foco de teclado SÓ quando aberto → permite Esc fechar, sem roubar teclas
    // das janelas atrás (terminal/browser) em repouso. OnDemand = o compositor
    // concede o foco no clique que abre; None = não interfere.
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    readonly property int sliverW: 220
    readonly property int gripHotspotH: 18   // altura da zona clicável do puxador (repouso)
    readonly property int resultRowHeight: 54
    readonly property int resultSpacing: 6
    readonly property int resultSlots: 4
    property int selectedIndex: -1
    property bool selectionResetPending: false

    // Abertura por CLIQUE no puxador (não por hover). `open` é alternado pelo
    // TapHandler da zona do grip; hover é só feedback visual. Esc e clique-fora
    // fecham. Sem timers de hover: a abertura é sempre intencional.
    property bool open: false
    function toggle() { root.open = !root.open }
    function close() { root.open = false }
    function requestSearchFocus() {
        if (!root.open)
            return;

        searchInput.forceActiveFocus();
        searchInput.cursorPosition = searchInput.text.length;

        Qt.callLater(() => {
            if (!root.open)
                return;

            searchInput.forceActiveFocus();
            searchInput.cursorPosition = searchInput.text.length;
        });
    }
    function resetSelection() {
        root.selectedIndex = appModel.apps.length > 0 ? 0 : -1;
    }
    function moveSelection(delta) {
        const count = appModel.apps.length;

        if (count === 0) {
            root.selectedIndex = -1;
            return;
        }

        if (root.selectedIndex < 0) {
            root.selectedIndex = 0;
            return;
        }

        root.selectedIndex = Math.max(0, Math.min(count - 1, root.selectedIndex + delta));
    }
    function launchApp(app) {
        if (!app || !app.desktopEntry)
            return;

        app.desktopEntry.execute();
        searchInput.text = "";
        root.close();
    }
    function launchSelectedResult() {
        if (appModel.apps.length === 0 || root.selectedIndex < 0 || root.selectedIndex >= appModel.apps.length)
            return;

        root.launchApp(appModel.apps[root.selectedIndex]);
    }

    DesktopAppModel {
        id: appModel
        limit: 4
        query: searchInput.text
    }

    Shortcut {
        enabled: root.open && appModel.apps.length > 0
        context: Qt.WindowShortcut
        sequence: "Down"
        onActivated: root.moveSelection(1)
    }

    Shortcut {
        enabled: root.open && appModel.apps.length > 0
        context: Qt.WindowShortcut
        sequence: "Up"
        onActivated: root.moveSelection(-1)
    }

    Timer {
        id: focusRetryTimer
        interval: 30
        repeat: false
        onTriggered: root.requestSearchFocus()
    }

    Connections {
        target: appModel
        function onAppsChanged() {
            if (root.selectionResetPending) {
                root.resetSelection();
                root.selectionResetPending = false;
                return;
            }

            if (appModel.apps.length === 0)
                root.selectedIndex = -1;
            else if (root.selectedIndex >= appModel.apps.length)
                root.selectedIndex = appModel.apps.length - 1;
        }
    }

    // Máscara DESACOPLADA da animação do card (essa dependência causava o loop
    // abre/fecha sobre janelas atrás). Fechado = só o hotspot do puxador no
    // rodapé-centro → resto da tela é click-through. Aberto = a JANELA inteira:
    // região sólida e estável (não segue o card que desliza); clicar fora do
    // card fecha.
    mask: Region {
        x: root.open ? 0 : Math.round((root.width - root.sliverW) / 2)
        y: root.open ? 0 : (root.height - root.gripHotspotH)
        width: root.open ? root.width : root.sliverW
        height: root.open ? root.height : root.gripHotspotH
    }

    // Fundo de captura: ativo só quando aberto. Clique em qualquer ponto FORA do
    // card fecha o launcher. Declarado primeiro → fica ATRÁS do card e do grip.
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.close()
    }

    // Esc fecha. Precisa de um item com foco ativo; o foco de teclado é concedido
    // pelo compositor (keyboardFocus OnDemand) no clique que abre o painel.
    Item {
        id: closeProxy
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: root.close()
    }

    // Zona do puxador: área clicável que coincide com a máscara fechada (mais
    // fácil de acertar que a linha de 3px). Clique alterna abrir/fechar; hover é
    // só feedback visual. Some quando aberto.
    Item {
        id: gripZone
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        width: root.sliverW
        height: root.gripHotspotH
        opacity: root.open ? 0 : 1
        // opacity 0 ainda recebe input em QML → desativa a captura quando aberto,
        // pra a faixa do puxador não disparar o toggle com o painel já aberto.
        enabled: !root.open
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        HoverHandler { id: gripHover }
        TapHandler { onTapped: root.toggle() }

        // linha fina visível do puxador, centrada na zona
        Rectangle {
            id: grip
            anchors { bottom: parent.bottom; bottomMargin: 7; horizontalCenter: parent.horizontalCenter }
            width: Theme.gripLen
            height: Theme.gripThickness
            radius: height / 2
            antialiasing: true
            color: gripHover.hovered ? Theme.gripHover : Theme.gripColor
            scale: gripHover.hovered ? 1.04 : 1.0
            Behavior on color { ColorAnimation { duration: Theme.tFast } }
            Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
        }
    }

    Card {
        id: card
        width: 632
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.open ? Theme.gap : -(height + 30)
        opacity: root.open ? 1 : 0
        radius: Theme.radiusLg
        // painel sólido + contorno mais nítido: sem blur real, isso separa o
        // launcher das janelas atrás (terminal/browser) e mata o efeito fantasma.
        color: Theme.surfaceStrong
        border.color: Theme.strokeStrong
        height: col.implicitHeight + Theme.pad * 2

        Behavior on anchors.bottomMargin { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }

        // engole cliques dentro do card → não chegam ao fundo de captura, então
        // clicar no painel NÃO fecha. Fica atrás da Column (hover das linhas intacto).
        MouseArea { anchors.fill: parent }

        Column {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.pad }
            spacing: Theme.gap

            // resultados read-only
            Rectangle {
                width: parent.width
                radius: Theme.radiusLg
                antialiasing: true
                color: Theme.accentTrack
                border.width: 1
                border.color: Theme.stroke
                implicitHeight: Theme.gap * 2
                              + root.resultRowHeight * root.resultSlots
                              + root.resultSpacing * (root.resultSlots - 1)

                Column {
                    id: resultsCol
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.gap }
                    spacing: root.resultSpacing

                    Repeater {
                        model: appModel.apps
                        delegate: Rectangle {
                            required property var modelData
                            width: parent.width
                            height: root.resultRowHeight
                            radius: Theme.radius
                            antialiasing: true
                            readonly property bool selected: modelData.rowIndex === root.selectedIndex
                            color: selected ? Theme.accentPressed
                                 : rowHover.hovered ? Theme.accentSoft
                                 : Theme.card
                            border.width: 1
                            border.color: selected ? Theme.strokeStrong
                                         : rowHover.hovered ? Theme.strokeStrong
                                         : Theme.stroke
                            Behavior on color { ColorAnimation { duration: Theme.tFast } }
                            Behavior on border.color { ColorAnimation { duration: Theme.tFast } }

                            HoverHandler { id: rowHover }
                            TapHandler {
                                onTapped: {
                                    root.selectedIndex = modelData.rowIndex;
                                    root.launchApp(modelData);
                                }
                            }

                            Row {
                                anchors { left: parent.left; leftMargin: Theme.pad; verticalCenter: parent.verticalCenter }
                                spacing: Theme.pad - 2
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 38; height: 38; radius: Theme.radiusSm
                                    antialiasing: true
                                    color: Theme.surfaceStrong

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.initial
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: Theme.accent
                                    }
                                }
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1
                                    Text { text: modelData.name; font.pixelSize: 15; color: Theme.text }
                                    Text { text: modelData.subtitle; font.pixelSize: 12; color: Theme.textDim; width: 500; elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: appModel.query.trim().length > 0 && appModel.apps.length === 0
                    text: "No results"
                    font.pixelSize: 13
                    color: Theme.textDim
                }
            }

            // campo de busca
            Rectangle {
                width: parent.width
                height: 46
                radius: height / 2
                antialiasing: true
                color: Theme.card
                border.width: 1
                border.color: Theme.stroke
                Row {
                    anchors { left: parent.left; leftMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                    spacing: Theme.gap
                    Text { anchors.verticalCenter: parent.verticalCenter; text: ""; font.family: Theme.iconFont; font.pixelSize: 16; color: Theme.textDim }  // lupa

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 520
                        height: 24

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            clip: true
                            color: Theme.text
                            selectionColor: Theme.accentSoft
                            selectedTextColor: Theme.text
                            font.pixelSize: 15
                            verticalAlignment: TextInput.AlignVCenter

                            Keys.priority: Keys.BeforeItem
                            Keys.forwardTo: [closeProxy]
                            onTextChanged: root.selectionResetPending = true
                            Keys.onPressed: (event) => {
                                switch (event.key) {
                                case Qt.Key_Return:
                                case Qt.Key_Enter:
                                    root.launchSelectedResult();
                                    event.accepted = true;
                                    break;
                                default:
                                    break;
                                }
                            }
                        }

                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            visible: searchInput.text.length === 0
                            text: "Search apps"
                            font.pixelSize: 15
                            color: Theme.textDim
                        }
                    }
                }

                Item {
                    anchors { right: parent.right; rightMargin: Theme.pad + 4; verticalCenter: parent.verticalCenter }
                    width: 20
                    height: 20

                    Text {
                        anchors.centerIn: parent
                        text: ""   // x
                        font.family: Theme.iconFont
                        font.pixelSize: 14
                        color: Theme.textDim
                        opacity: searchInput.text.length > 0 ? 1 : 0.55
                    }

                    TapHandler {
                        onTapped: {
                            searchInput.clear();
                            searchInput.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    onOpenChanged: {
        if (root.open) {
            root.resetSelection();
            root.requestSearchFocus();
            focusRetryTimer.restart();
        } else {
            focusRetryTimer.stop();
            root.selectedIndex = -1;
            searchInput.text = "";
            root.selectionResetPending = false;
        }
    }
}
