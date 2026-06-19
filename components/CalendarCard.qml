import "../config"
import "../services"
import QtQuick

// Mini-calendário navegável do mês corrente. Mantém estado próprio de mês/ano
// (inicia no mês atual do Clock) e marca o dia de hoje em círculo clay — só
// quando o mês exibido é o atual. Semana começando na segunda-feira.
Rectangle {
    id: root

    // Mês exibido (navegável). Inicia no mês atual; setas mudam mês/ano.
    property int viewYear: Clock.currentYear
    property int viewMonth: Clock.currentMonth   // 1–12

    readonly property bool isCurrentMonth: root.viewYear === Clock.currentYear
                                           && root.viewMonth === Clock.currentMonth
    readonly property var cells: Clock.monthCells(root.viewYear, root.viewMonth)
    // dia a destacar: só faz sentido no mês atual.
    readonly property int highlight: root.isCurrentMonth ? Clock.currentDay : -1

    function prevMonth() {
        if (root.viewMonth === 1) { root.viewMonth = 12; root.viewYear -= 1; }
        else root.viewMonth -= 1;
    }
    function nextMonth() {
        if (root.viewMonth === 12) { root.viewMonth = 1; root.viewYear += 1; }
        else root.viewMonth += 1;
    }
    function goToday() {
        root.viewYear = Clock.currentYear;
        root.viewMonth = Clock.currentMonth;
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

        // Navegação: ‹  Junho de 2026  › — clique no rótulo volta para hoje.
        Item {
            width: parent.width
            height: 30

            Rectangle {
                id: prevBtn
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                width: 28; height: 28; radius: 14
                antialiasing: true
                color: prevHover.hovered ? Theme.accentSoft : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.glyphSm
                    color: Theme.textDim
                }
                HoverHandler { id: prevHover }
                TapHandler { onTapped: root.prevMonth() }
            }

            Text {
                id: monthLabel
                anchors.centerIn: parent
                text: Clock.monthLabel(root.viewYear, root.viewMonth)
                font.pixelSize: Theme.fsLabel
                font.bold: true
                color: Theme.text
                HoverHandler { id: labelHover }
                TapHandler { onTapped: root.goToday() }
            }

            Rectangle {
                id: nextBtn
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: 28; height: 28; radius: 14
                antialiasing: true
                color: nextHover.hovered ? Theme.accentSoft : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.tFast } }
                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: Theme.iconFont
                    font.pixelSize: Theme.glyphSm
                    color: Theme.textDim
                }
                HoverHandler { id: nextHover }
                TapHandler { onTapped: root.nextMonth() }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            Repeater {
                model: ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"]
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
            model: root.cells
            delegate: Item {
                required property var modelData
                width: 34
                height: 28
                readonly property bool isHi: !modelData.empty && modelData.day === root.highlight

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
                    text: modelData.empty ? "" : modelData.day
                    font.pixelSize: 13
                    color: parent.isHi ? Theme.textOnAccent : Theme.text
                }
            }
        }
    }
}
