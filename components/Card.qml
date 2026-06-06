import "../config"
import QtQuick
import QtQuick.Effects

// Cartão arredondado com sombra difusa (sem stroke duro) — primitiva base de
// toda superfície flutuante da shell. A separação vem da sombra, como nos prints.
Rectangle {
    id: root
    radius: Theme.radius
    color: Theme.card
    antialiasing: true
    border.width: 1
    border.color: Theme.stroke

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Theme.shadow
        shadowBlur: Theme.shadowBlur
        shadowVerticalOffset: Theme.shadowY
        shadowHorizontalOffset: 0
        autoPaddingEnabled: true
    }
}
