pragma Singleton

import Quickshell
import QtQuick

// Tokens visuais centrais — tema claro "rosé / ink" derivado dos prints de
// referência (assets/references/). Estruturado para, na Fase 4, derivar do
// wallpaper e suportar um esquema dark via `isDark`.
Singleton {
    // ---- esquema ativo ----
    readonly property bool isDark: false

    // ---- superfícies (translúcidas sobre o wallpaper) ----
    readonly property color surface:      Qt.rgba(1, 1, 1, 0.85)  // painel/drawer
    readonly property color card:         Qt.rgba(1, 1, 1, 0.93)  // card
    readonly property color cardHover:    Qt.rgba(0.94, 0.94, 0.94, 0.97) // card em hover (cinza claro)
    readonly property color bar:          Qt.rgba(1, 1, 1, 0.88)  // barra esquerda
    // painel "sólido focado": quase opaco, para overlays que se sobrepõem a
    // JANELAS (não só ao wallpaper) — sem blur real, a translucidez alta virava
    // fantasma sobre terminal/browser. Usado no Launcher.
    readonly property color surfaceStrong: Qt.rgba(1, 1, 1, 0.985)

    // ---- acento monocromático (preto/cinza, sem cor) ----
    readonly property color accent:       "#4d4d4d"   // destaque principal (cinza-chumbo)
    readonly property color accentActive: "#3a3a3a"   // fill ativo (círculo)
    readonly property color accentSoft:   "#e6e6e6"   // hover sutil / trilha de anel (cinza claro)
    readonly property color accentTrack:  "#ededed"   // fundo de progresso (cinza claro)
    readonly property color accentPressed: Qt.darker("#e6e6e6", 1.08) // feedback de clique (hover pressionado)

    // ---- texto ----
    readonly property color text:         "#3d3d3d"
    readonly property color textDim:      "#707070"
    readonly property color textFaint:    "#b3b3b3"
    readonly property color textOnAccent: "#ffffff"   // texto/ícone sobre fill preto

    // ---- separação (quase sem stroke; a sombra é a borda) ----
    readonly property color stroke:       Qt.rgba(0, 0, 0, 0.06)
    readonly property color strokeStrong: Qt.rgba(0, 0, 0, 0.12)  // contorno mais nítido p/ separar de janelas
    readonly property color shadow:       Qt.rgba(0, 0, 0, 0.16)
    readonly property real  shadowBlur:   0.8   // 0..1 (MultiEffect)
    readonly property int   shadowY:      6

    // ---- forma ----
    readonly property int   radius:       18
    readonly property int   radiusLg:     24    // superfícies grandes (drawer) — mais generoso que um chip
    readonly property int   radiusSm:     12
    readonly property int   radiusPill:   999
    readonly property int   screenRound:  22    // raio generoso p/ peças orgânicas ancoradas na borda

    // ---- puxadores minimalistas (topo / direita / base) ----
    readonly property int   gripLen:      52
    readonly property int   gripThickness: 3
    readonly property color gripColor:    Qt.rgba(0.78, 0.78, 0.78, 0.95)
    readonly property color gripHover:    Qt.rgba(0.42, 0.42, 0.42, 0.98)

    // ---- espaçamento ----
    readonly property int   gap:          10
    readonly property int   pad:          16

    // ---- dimensões das bordas ----
    readonly property int   barW:         46    // barra esquerda fina
    readonly property int   sliver:       6      // borda de hover (topo/direita)
    readonly property int   iconSize:     19
    readonly property int   tooltipReserve: 280  // espaço transparente p/ tooltips

    // ---- tipografia ----
    readonly property string iconFont:    "JetBrainsMono Nerd Font"

    // ---- timing das animações (sensação "viva") ----
    // Só durações aqui (ints). O easing vai direto na animação:
    //   easing.type: Easing.OutCubic   (geral)
    //   easing.type: Easing.OutExpo    (drawer / launcher)
    readonly property int   tFast:        120
    readonly property int   tBase:        240
    readonly property int   tSlow:        360

    // atraso antes de um overlay abrir por hover — confirma intenção e evita
    // abertura acidental ao só passar o mouse na borda.
    readonly property int   tHoverOpen:   280
    // atraso antes de fechar — segura o painel enquanto o mouse cruza o corredor
    // entre puxador e conteúdo, evitando fechamento prematuro.
    readonly property int   tHoverClose:  220
}
