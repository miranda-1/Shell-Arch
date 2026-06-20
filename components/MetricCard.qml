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
    border.color: root.emphasized ? Theme.onAccent(0.08) : Theme.stroke
    antialiasing: true
    // altura natural acompanha o conteúdo: textos com wrap/elide nunca
    // estouram a borda inferior do card
    implicitHeight: contentCol.implicitHeight + Theme.pad * 2
    clip: true

    Column {
        id: contentCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.pad
        spacing: 10

        Rectangle {
            width: 34
            height: 34
            radius: 17
            antialiasing: true
            color: root.emphasized ? Theme.onAccent(0.12) : Theme.accentSoft

            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.iconFont
                font.pixelSize: 16
                color: root.emphasized ? Theme.textOnAccent : Theme.accent
            }
        }

        Text {
            width: parent.width
            text: root.title
            font.pixelSize: Theme.fsBody
            color: root.emphasized ? Theme.onAccent(0.72) : Theme.textDim
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root.value
            font.pixelSize: Theme.fsHeadline
            font.bold: true
            color: root.emphasized ? Theme.textOnAccent : Theme.text
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: root.subtitle.length > 0
            text: root.subtitle
            font.pixelSize: Theme.fsBody
            color: root.emphasized ? Theme.onAccent(0.78) : Theme.textDim
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }
}
