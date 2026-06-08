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
                width: heroRow.width - clockCard.width - Theme.gap
                cells: Clock.calendarCells
                highlight: Clock.currentDay
            }
        }

        Row {
            width: parent.width
            spacing: Theme.gap

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Mês"
                value: Clock.monthName
                subtitle: "Dia " + Clock.currentDay + " de " + Clock.daysInMonth
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Energia"
                value: Battery.available ? Battery.statusText : "Sem bateria"
                subtitle: Battery.available ? Battery.profileText : "Sem dispositivo móvel"
            }

            MetricCard {
                width: (parent.width - Theme.gap * 2) / 3
                glyph: ""
                title: "Eventos"
                value: "Sem eventos"
                subtitle: "Integração de agenda ainda não foi adicionada."
            }
        }
    }
}
