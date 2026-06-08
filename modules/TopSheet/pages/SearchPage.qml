import "../../../components"
import "../../../config"
import "../../Launcher"
import QtQuick

Item {
    id: root

    property bool open: false

    implicitHeight: content.implicitHeight

    function launchApp(app) {
        if (!app || !app.desktopEntry)
            return;

        app.desktopEntry.execute();
    }

    DesktopAppModel {
        id: appModel
        limit: 6
        query: searchInput.text
    }

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Rectangle {
            width: parent.width
            height: 72
            radius: 36
            antialiasing: true
            color: Theme.card
            border.width: 1
            border.color: searchInput.activeFocus ? Theme.strokeStrong : Theme.stroke

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.pad + 4
                anchors.rightMargin: Theme.pad + 4
                spacing: Theme.pad

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    font.family: Theme.iconFont
                    font.pixelSize: 18
                    color: Theme.textDim
                }

                TextInput {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 170
                    color: Theme.text
                    font.pixelSize: Theme.fsTitle
                    clip: true
                    selectionColor: Theme.accentSoft
                    selectedTextColor: Theme.text
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    Keys.onReturnPressed: {
                        if (appModel.apps.length > 0)
                            root.launchApp(appModel.apps[0]);
                    }

                    Component.onCompleted: {
                        if (root.open)
                            forceActiveFocus();
                    }
                }

                Text {
                    visible: searchInput.text.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: searchInput.left
                    text: "Buscar apps, ações e favoritos"
                    font.pixelSize: Theme.fsTitle
                    color: Theme.textFaint
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 108
                    height: 34
                    radius: 17
                    color: Theme.accentTrack
                    antialiasing: true

                    Text {
                        anchors.centerIn: parent
                        text: appModel.query.trim().length > 0 ? "Enter abre" : "Favoritos"
                        font.pixelSize: 11
                        color: Theme.textDim
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            implicitHeight: appModel.apps.length > 0 ? resultList.implicitHeight + Theme.pad * 2 : 180
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.stroke
            antialiasing: true

            Column {
                id: resultList
                anchors.fill: parent
                anchors.margins: Theme.pad
                spacing: Theme.gap

                Text {
                    text: appModel.query.trim().length > 0 ? "Resultados" : "Favoritos e frequentes"
                    font.pixelSize: Theme.fsLabel
                    color: Theme.textDim
                }

                Repeater {
                    model: appModel.apps
                    delegate: Rectangle {
                        required property var modelData
                        width: resultList.width
                        height: 62
                        radius: Theme.radius
                        antialiasing: true
                        color: rowHover.hovered ? Theme.accentSoft : Theme.accentTrack
                        border.width: 1
                        border.color: rowHover.hovered ? Theme.strokeStrong : Theme.stroke

                        HoverHandler {
                            id: rowHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            acceptedButtons: Qt.LeftButton
                            onTapped: root.launchApp(modelData)
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.pad
                            anchors.rightMargin: Theme.pad
                            spacing: Theme.pad

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 38
                                height: 38
                                radius: 19
                                antialiasing: true
                                color: Theme.card

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.initial
                                    font.pixelSize: Theme.fsTitle
                                    font.bold: true
                                    color: Theme.accent
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 180
                                spacing: 3

                                Text {
                                    text: modelData.name
                                    font.pixelSize: Theme.fsLabel
                                    color: Theme.text
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.subtitle
                                    font.pixelSize: Theme.fsBody
                                    color: Theme.textDim
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 92
                                height: 30
                                radius: 15
                                color: Theme.card
                                antialiasing: true

                                Text {
                                    anchors.centerIn: parent
                                    text: "Abrir"
                                    font.pixelSize: 11
                                    color: Theme.textDim
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: appModel.apps.length === 0
                    text: appModel.query.trim().length > 0
                        ? "Nenhum app encontrado para essa busca."
                        : "Os apps favoritos do índice local aparecem aqui."
                    font.pixelSize: Theme.fsBodyLg
                    color: Theme.textDim
                }
            }
        }
    }
}
