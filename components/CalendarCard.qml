import "../config"
import QtQuick

// Mini-calendário fake. Dia `highlight` marcado em círculo clay.
Rectangle {
    id: root

    property int highlight: 7

    readonly property var days: {
        const arr = [];
        const lead = [26, 27, 28, 29, 30, 31];
        for (let i = 0; i < lead.length; i++)
            arr.push({ n: lead[i], muted: true });
        for (let d = 1; d <= 30; d++)
            arr.push({ n: d, muted: false });
        let pad = 1;
        while (arr.length % 7 !== 0)
            arr.push({ n: pad++, muted: true });
        return arr;
    }

    color: Theme.card
    radius: Theme.radius
    antialiasing: true
    implicitWidth: grid.implicitWidth + Theme.pad * 2
    implicitHeight: header.height + grid.implicitHeight + Theme.pad * 2 + Theme.gap

    Column {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: Theme.pad }
        spacing: Theme.gap

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            Repeater {
                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                delegate: Text {
                    required property var modelData
                    width: 34
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: 12
                    font.bold: true
                    color: Theme.textDim
                }
            }
        }
    }

    Grid {
        id: grid
        anchors { top: header.bottom; topMargin: Theme.gap; horizontalCenter: parent.horizontalCenter }
        columns: 7
        rowSpacing: 2
        columnSpacing: 0
        Repeater {
            model: root.days
            delegate: Item {
                required property var modelData
                width: 34
                height: 28
                readonly property bool isHi: !modelData.muted && modelData.n === root.highlight

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    antialiasing: true
                    visible: parent.isHi
                    color: Theme.accentActive
                }
                Text {
                    anchors.centerIn: parent
                    text: modelData.n
                    font.pixelSize: 13
                    color: parent.isHi ? Theme.textOnAccent
                         : modelData.muted ? Theme.textFaint : Theme.text
                }
            }
        }
    }
}
