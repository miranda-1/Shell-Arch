pragma Singleton

import Quickshell
import QtQuick

// Serviço read-only de hora/data (Fase 5 — primeira integração real).
// Fonte: Quickshell SystemClock (nativo, evented — sem polling manual e sem
// comando externo). Precisão de minuto: dateChanged dispara a cada minuto, o
// que basta para o relógio e para detectar a virada do dia no calendário.
// NÃO escreve nada no sistema; apenas expõe strings formatadas para a UI.
Singleton {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // QDateTime exposto como Date (JS) — base para todos os formatos abaixo.
    readonly property date now: clock.date

    // Locale pt-BR para nomes de dia/mês.
    readonly property var _loc: Qt.locale("pt_BR")

    // primeira letra maiúscula (pt-BR abrevia em minúsculas: "sáb." / "junho")
    function _cap(s) {
        return s.length > 0 ? s[0].toUpperCase() + s.slice(1) : s;
    }

    // ---- EdgeLeft: relógio empilhado "21" / "40" (dois dígitos cada) ----
    readonly property string hour: (clock.hours < 10 ? "0" : "") + clock.hours
    readonly property string minute: (clock.minutes < 10 ? "0" : "") + clock.minutes

    // ---- Dashboard: relógio grande "21:06" ----
    readonly property string timeText: root.hour + ":" + root.minute

    // ---- Dashboard: data "Sáb, 7 de Junho" ----
    readonly property string dateText: {
        const wd = root._cap(root.now.toLocaleDateString(root._loc, "ddd").replace(".", ""));
        const month = root._cap(root.now.toLocaleDateString(root._loc, "MMMM"));
        return wd + ", " + root.now.getDate() + " de " + month;
    }

    // ---- CalendarCard: dia do mês atual (1–31) para o highlight ----
    readonly property int day: root.now.getDate()
}
