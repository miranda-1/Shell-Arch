import "../config"
import QtQuick

// Linha fina de separação — extraída dos divisores inline da EdgeLeft.
// Pixel-idêntica ao divisor anterior: largura = iconSize, 1px, cor stroke.
// `width` é sobrescrevível pelo chamador quando precisar de outra extensão.
Rectangle {
    width: Theme.iconSize
    height: 1
    color: Theme.stroke
    antialiasing: true
}
