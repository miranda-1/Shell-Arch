import "../config"
import QtQuick

Rectangle {
    id: root

    property string glyph: ""
    property string title: ""
    property string value: ""
    property string subtitle: ""
    property bool emphasized: false

    radius: Theme.radius
    color: root.emphasized ? Theme.accentActive : Theme.card
    border.width: 1
    border.color: root.emphasized ? Qt.rgba(1, 1, 1, 0.08) : Theme.stroke
    antialiasing: true
    implicitHeight: 132

    Column {
        anchors.fill: parent
        anchors.margins: Theme.pad
        spacing: 10

        Rectangle {
            width: 34
            height: 34
            radius: 17
            antialiasing: true
            color: root.emphasized ? Qt.rgba(1, 1, 1, 0.12) : Theme.accentSoft

            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.iconFont
                font.pixelSize: 16
                color: root.emphasized ? Theme.textOnAccent : Theme.accent
            }
        }

        Text {
            text: root.title
            font.pixelSize: Theme.fsBody
            color: root.emphasized ? Qt.rgba(1, 1, 1, 0.72) : Theme.textDim
        }

        Text {
            text: root.value
            font.pixelSize: Theme.fsHeadline
            font.bold: true
            color: root.emphasized ? Theme.textOnAccent : Theme.text
            wrapMode: Text.Wrap
        }

        Text {
            visible: root.subtitle.length > 0
            text: root.subtitle
            font.pixelSize: Theme.fsBody
            color: root.emphasized ? Qt.rgba(1, 1, 1, 0.78) : Theme.textDim
            wrapMode: Text.Wrap
        }
    }
}
