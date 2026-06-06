import "../config"
import Quickshell
import Quickshell.Wayland
import QtQuick

// Moldura viva contínua (Leva C). Desenha UMA linha finíssima e arredondada ao
// redor de toda a tela — topo, direita, base e os quatro cantos como uma única
// forma (um Rectangle com border arredondado), garantindo continuidade e cantos
// conectados sem trabalho de junção.
//
// A esquerda fica coberta pela EdgeLeft (a barra principal, 46px > raio 22), de
// modo que a linha "nasce" da barra. Puramente decorativa: NÃO captura input
// (máscara vazia), então o desktop continua 100% clicável nas bordas em repouso.
//
// Montada PRIMEIRO no shell.qml para ficar no fundo da camada Top — abaixo da
// barra e dos drawers, que a cobrem quando abrem.
PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    exclusiveZone: 0
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top

    // máscara vazia = sem captura de input em lugar nenhum (full click-through)
    mask: Region {}

    // halo externo muito sutil (dá profundidade premium sem engrossar a linha).
    // Raio IGUAL ao da linha/barra (screenRound, sem +1): assim o arco do halo
    // coincide com o canto arredondado da EdgeLeft e NÃO vaza 1px além dele nos
    // cantos esquerdos — era esse vazamento que deixava o pequeno resquício/crescente
    // de creme sobre o wallpaper no canto sup-esq e inf-esq. A largura maior do
    // border cresce só p/ DENTRO, mantendo o glow de profundidade.
    Rectangle {
        anchors.fill: parent
        radius: Theme.screenRound
        color: "transparent"
        antialiasing: true
        border.width: Theme.frameLine + 2
        border.color: Theme.frameSoft
    }

    // linha principal contínua da moldura
    Rectangle {
        anchors.fill: parent
        radius: Theme.screenRound
        color: "transparent"
        antialiasing: true
        border.width: Theme.frameLine
        border.color: Theme.frameRest
    }
}
