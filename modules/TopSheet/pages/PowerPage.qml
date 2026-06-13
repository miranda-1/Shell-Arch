import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    // ação destrutiva aguardando 2º toque (confirmação)
    property string pendingId: ""

    // glyphs preenchidos via script (PUA some no editor)
    property string glyphLock: ""
    property string glyphLogout: ""
    property string glyphSuspend: ""
    property string glyphReboot: ""
    property string glyphPower: ""
    property string glyphWindows: ""

    Timer { id: resetTimer; interval: 4000; onTriggered: root.pendingId = "" }

    function trigger(item) {
        if (!item.danger) {
            item.run();
            return;
        }
        if (root.pendingId === item.id) {
            root.pendingId = "";
            item.run();
        } else {
            root.pendingId = item.id;
            resetTimer.restart();
        }
    }

    Column {
        id: content
        width: root.width
        spacing: Theme.gap

        Repeater {
            model: [
                { id: "lock",     glyph: root.glyphLock,    label: "Bloquear",           danger: false, run: function() { Power.lock(); } },
                { id: "suspend",  glyph: root.glyphSuspend, label: "Suspender",          danger: true,  run: function() { Power.suspend(); } },
                { id: "logout",   glyph: root.glyphLogout,  label: "Encerrar sessão",    danger: true,  run: function() { Power.logout(); } },
                { id: "reboot",   glyph: root.glyphReboot,  label: "Reiniciar",          danger: true,  run: function() { Power.reboot(); } },
                { id: "poweroff", glyph: root.glyphPower,   label: "Desligar",           danger: true,  run: function() { Power.poweroff(); } },
                { id: "windows",  glyph: root.glyphWindows, label: "Iniciar no Windows", danger: true,  run: function() { Power.rebootWindows(); } }
            ]

            delegate: Rectangle {
                required property var modelData
                readonly property bool pending: root.pendingId === modelData.id

                width: parent.width
                height: 52
                radius: Theme.radiusSm
                color: pending ? Theme.accentActive : (pHover.hovered ? Theme.cardHover : Theme.card)
                border.width: 1
                border.color: pending ? Theme.strokeStrong : Theme.stroke
                antialiasing: true

                Behavior on color { ColorAnimation { duration: Theme.tFast } }

                HoverHandler { id: pHover; cursorShape: Qt.PointingHandCursor }
                TapHandler { acceptedButtons: Qt.LeftButton; onTapped: root.trigger(modelData) }

                Text {
                    id: pGlyph
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.pad + 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.glyph
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                    color: parent.pending ? Theme.textOnAccent : Theme.text
                }

                Text {
                    anchors.left: pGlyph.right
                    anchors.leftMargin: Theme.pad
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.pending ? "Confirmar: " + modelData.label : modelData.label
                    font.pixelSize: Theme.fsLabel
                    color: parent.pending ? Theme.textOnAccent : Theme.text
                }

                Text {
                    visible: parent.pending
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.pad + 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: "toque de novo"
                    font.pixelSize: Theme.fsCaption
                    color: Theme.textOnAccent
                }
            }
        }

        Text {
            width: parent.width
            text: "Ações reais do sistema. As destrutivas pedem um 2º toque para confirmar."
            font.pixelSize: Theme.fsCaption
            color: Theme.textFaint
            wrapMode: Text.Wrap
        }
    }
}
