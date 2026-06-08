import "../config"
import "../services"
import QtQuick

Item {
    id: root

    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property var pills: []
    property bool showCloseButton: false

    signal closeRequested()

    implicitHeight: 88

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

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 180
            spacing: 6

            Text {
                text: root.title
                font.pixelSize: Theme.fsTitleLg
                font.bold: true
                color: Theme.text
            }

            Text {
                text: root.subtitle
                font.pixelSize: Theme.fsBodyLg
                color: Theme.textDim
                width: parent.width
                elide: Text.ElideRight
            }

            Row {
                spacing: 8

                Repeater {
                    model: root.pills
                    delegate: Rectangle {
                        required property var modelData
                        width: pillText.implicitWidth + (modelData.glyph ? 38 : 20)
                        height: 26
                        radius: 13
                        color: modelData.active ? Theme.accentSoft : Theme.accentTrack
                        antialiasing: true

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                visible: !!modelData.glyph
                                text: modelData.glyph || ""
                                font.family: Theme.iconFont
                                font.pixelSize: 12
                                color: modelData.active ? Theme.accentActive : Theme.textDim
                            }

                            Text {
                                id: pillText
                                text: modelData.text || ""
                                font.pixelSize: 11
                                color: modelData.active ? Theme.accentActive : Theme.textDim
                            }
                        }
                    }
                }
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 96
            height: 40

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: timeText.implicitWidth + 18
                    height: 32
                    radius: 16
                    color: Theme.cardHover
                    antialiasing: true

                    Text {
                        id: timeText
                        anchors.centerIn: parent
                        text: Clock.timeText
                        font.pixelSize: 12
                        color: Theme.textDim
                    }
                }

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
