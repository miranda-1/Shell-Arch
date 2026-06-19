import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

Item {
    id: root

    implicitHeight: content.implicitHeight

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Row {
            id: heroRow
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                id: clockCard
                width: parent.width * 0.34
                implicitHeight: 220
                glyph: ""
                title: "Horário"
                value: Clock.timeText
                subtitle: Clock.dateText
                emphasized: true
            }

            CalendarCard {
                id: calendarCard
                width: heroRow.width - clockCard.width - Theme.gap
            }
        }
    }
}
