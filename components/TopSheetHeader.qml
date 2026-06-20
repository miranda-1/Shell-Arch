import "../config"
import QtQuick

Item {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property var pills: []
    property bool showCloseButton: false

    signal closeRequested()

    implicitHeight: 64

    Row {
        anchors.fill: parent
        spacing: Theme.pad

        Rectangle {
            width: 52
            height: 52
            radius: 26
            antialiasing: true
            color: Theme.accentSoft

            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.iconFont
                font.pixelSize: 21
                color: Theme.accentActive
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 116
            text: root.title
            font.pixelSize: Theme.fsTitleLg
            font.bold: true
            color: Theme.text
            elide: Text.ElideRight
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    visible: root.showCloseButton
                    width: 32
                    height: 32
                    radius: 16
                    color: closeHover.hovered ? Theme.accentSoft : Theme.cardHover
                    antialiasing: true

                    Text {
                        anchors.centerIn: parent
                        text: ""
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
                        onTapped: root.closeRequested()
                    }
                }
            }
        }
    }
}
