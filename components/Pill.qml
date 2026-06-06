import "../config"
import QtQuick

// Pílula totalmente arredondada — usada em toggles, fontes de mídia, chips.
Rectangle {
    radius: height / 2
    color: Theme.accentSoft
    antialiasing: true
}
