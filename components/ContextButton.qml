import "../config"
import QtQuick

Item {
    id: root

    property string glyph: ""
    property string label: ""
    property bool active: false
    property color glyphColor: Theme.text
    property bool enabled: true
    // gira o glyph continuamente (usado p/ mídia tocando)
    property bool spinning: false

    signal clicked()

    implicitWidth: Theme.barW
    implicitHeight: 40
    readonly property bool hovered: hover.hovered && root.enabled
    readonly property color hlClear: Qt.rgba(Theme.accentSoft.r, Theme.accentSoft.g, Theme.accentSoft.b, 0)

    Rectangle {
        anchors.centerIn: parent
        width: Theme.iconSize + 18
        height: Theme.iconSize + 18
        radius: root.active ? width / 2 : Theme.radiusSm
        antialiasing: true
        color: tap.pressed && root.enabled && !root.active ? Theme.accentPressed
             : root.active ? Theme.accentActive
             : root.hovered ? Theme.accentSoft
             : root.hlClear
        scale: tap.pressed && root.enabled ? 0.94
             : root.hovered && !root.active ? 1.08
             : 1.0
        opacity: root.enabled ? 1 : 0.45

        Behavior on color { ColorAnimation { duration: Theme.tFast } }
        Behavior on radius { NumberAnimation { duration: Theme.tFast } }
        Behavior on scale { NumberAnimation { duration: Theme.tFast; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
    }

    Text {
        anchors.centerIn: parent
        text: root.glyph
        color: root.active ? Theme.textOnAccent : root.glyphColor
        opacity: root.enabled ? 1 : 0.5
        font.family: Theme.iconFont
        font.pixelSize: Theme.iconSize

        RotationAnimator on rotation {
            running: root.spinning
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 3600
        }
    }

    HoverHandler {
        id: hover
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }

    TapHandler {
        id: tap
        acceptedButtons: Qt.LeftButton
        enabled: root.enabled
        onTapped: root.clicked()
    }

    Item {
        id: tip
        visible: opacity > 0 && root.label.length > 0
        opacity: root.hovered && root.label.length > 0 ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter
        x: root.width + Theme.gap + (root.hovered ? 0 : -6)
        width: tipBg.width
        height: tipBg.height

        Behavior on opacity { NumberAnimation { duration: Theme.tFast } }
        Behavior on x { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }

        Rectangle {
            id: tipBg
            width: Math.min(tipText.implicitWidth, 240) + Theme.pad * 2
            height: tipText.implicitHeight + Theme.gap * 2
            radius: Theme.radiusSm
            antialiasing: true
            color: Theme.accentActive
            border.width: 1
            border.color: Theme.onAccent(0.14)

            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.label
                color: Theme.textOnAccent
                font.pixelSize: 13
                width: Math.min(implicitWidth, 240)
                wrapMode: Text.Wrap
            }
        }
    }
}
