import QtQuick

Item {
    id: root

    property string text: ""
    property string fallbackText: "\u2014"
    property real maxWidth: 0
    property color color: "black"
    property string fontFamily: ""
    property int pixelSize: 14
    property bool bold: false
    property int fontWeight: Font.Normal
    property bool running: true
    property int pauseDuration: 900
    property int endPauseDuration: 700
    property int returnDuration: 420
    property real pixelsPerSecond: 28

    readonly property string displayText: text && text.length > 0 ? text : fallbackText
    readonly property real frameWidth: maxWidth > 0 ? maxWidth : metrics.advanceWidth
    readonly property real contentWidth: metrics.advanceWidth
    readonly property real overflow: Math.max(0, contentWidth - frameWidth)
    readonly property bool marqueeActive: running && visible && overflow > 0.5

    implicitWidth: Math.ceil(frameWidth)
    implicitHeight: label.implicitHeight
    width: implicitWidth
    height: implicitHeight
    clip: true

    onMarqueeActiveChanged: {
        if (!marqueeActive)
            track.x = 0;
    }

    TextMetrics {
        id: metrics
        text: root.displayText
        font.family: root.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
        font.weight: root.fontWeight
    }

    Item {
        id: track
        width: label.implicitWidth
        height: parent.height
        x: 0

        Text {
            id: label
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: root.marqueeActive ? implicitWidth : root.width
            text: root.displayText
            color: root.color
            font.family: root.fontFamily
            font.pixelSize: root.pixelSize
            font.bold: root.bold
            font.weight: root.fontWeight
            elide: root.marqueeActive ? Text.ElideNone : Text.ElideRight
        }
    }

    SequentialAnimation {
        id: marqueeAnimation
        running: root.marqueeActive
        loops: Animation.Infinite

        PauseAnimation {
            duration: root.pauseDuration
        }

        NumberAnimation {
            target: track
            property: "x"
            from: 0
            to: -root.overflow
            duration: Math.max(2200, Math.round(root.overflow * root.pixelsPerSecond))
            easing.type: Easing.InOutSine
        }

        PauseAnimation {
            duration: root.endPauseDuration
        }

        NumberAnimation {
            target: track
            property: "x"
            from: -root.overflow
            to: 0
            duration: root.returnDuration
            easing.type: Easing.OutCubic
        }
    }
}
