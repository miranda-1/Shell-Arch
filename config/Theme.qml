pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Tokens visuais centrais. As CORES agora SEGUEM O TEMA DO HyDE ao vivo: lemos a
// paleta wallbash de `~/.cache/hyde/wall.dcol` (a mesma fonte que a Waybar do
// HyDE usa) e derivamos todos os tokens dela, trocando claro/escuro pelo
// `dcol_mode`. Quando o usuário troca o tema/wallpaper no HyDE, o arquivo muda e
// o `FileView` (watchChanges) recarrega → o shell recolore sozinho.
//
// Fonte (wallbash): pry1 = cor primária (fundo), txt1 = texto sobre pry1,
// pry4 = cor de acento (dominante do wallpaper), txt4 = texto sobre o acento.
// Se o arquivo não existir (máquina sem HyDE), caímos num P&B claro neutro.
Singleton {
    id: root

    // ---- leitura da paleta do HyDE ----
    // OBS: `wall.dcol` é um SYMLINK que o HyDE REPONTA para outro arquivo em
    // dcols/ ao trocar de tema. O `watchChanges` (inotify) fica preso no inode
    // antigo e não dispara — por isso a troca só aparecia ao reabrir o shell.
    // Solução: além do watch, RELEMOS por polling (reload segue o symlink para o
    // alvo atual). Arquivo pequeno → custo desprezível.
    FileView {
        id: dcolFile
        path: Quickshell.env("HOME") + "/.cache/hyde/wall.dcol"
        preload: true
        blockLoading: true
        watchChanges: true
        printErrors: false
        onLoaded: root._reparse()
        onFileChanged: reload()
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        onTriggered: {
            // reload() reabre o path → segue o symlink ao alvo atual; com
            // blockLoading, o _reparse já lê o conteúdo fresco. Se nada mudou,
            // reatribui os mesmos valores (no-op, sem flicker).
            dcolFile.reload();
            root._reparse();
        }
    }

    // hexes crus (fallback = P&B claro, reproduz o visual antigo sem HyDE)
    property string _pry1: "ffffff"   // fundo primário
    property string _txt1: "3d3d3d"   // texto sobre o fundo
    property string _pry4: "4d4d4d"   // acento
    property string _txt4: "ffffff"   // texto sobre o acento
    property string _mode: "light"

    function _grab(text, key, fb) {
        if (!text)
            return fb;
        const m = text.match(new RegExp('dcol_' + key + '="?([0-9A-Fa-f]{6})"?'));
        return m ? m[1] : fb;
    }

    function _reparse() {
        const t = dcolFile.text();
        root._pry1 = root._grab(t, "pry1", "ffffff");
        root._txt1 = root._grab(t, "txt1", "3d3d3d");
        root._pry4 = root._grab(t, "pry4", "4d4d4d");
        root._txt4 = root._grab(t, "txt4", "ffffff");
        const mm = t ? t.match(/dcol_mode="?(dark|light)"?/) : null;
        root._mode = mm ? mm[1] : "light";
    }

    Component.onCompleted: root._reparse()

    // ---- cores-base derivadas dos hexes ----
    readonly property color basePry:    "#" + root._pry1
    readonly property color baseTxt:    "#" + root._txt1
    readonly property color baseAccent: "#" + root._pry4
    readonly property color baseAccentTxt: "#" + root._txt4

    // helpers de cor
    function _alpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }
    // cor de texto/elemento SOBRE um fill de acento (contrasta o acento em
    // qualquer tema). Usar em vez de branco fixo nos cards enfáticos/accentActive.
    function onAccent(a) { return root._alpha(root.baseAccentTxt, a); }
    function _mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t,
                       a.g * (1 - t) + b.g * t,
                       a.b * (1 - t) + b.b * t, 1);
    }

    // ---- esquema ativo ----
    readonly property bool isDark: root._mode === "dark"

    // ---- superfícies (translúcidas sobre o wallpaper) ----
    readonly property color surface:      root._alpha(root.basePry, 0.85)
    readonly property color card:         root._alpha(root._mix(root.basePry, root.baseTxt, 0.07), 0.93)
    readonly property color cardHover:    root._alpha(root._mix(root.basePry, root.baseTxt, 0.14), 0.97)
    readonly property color bar:          root._alpha(root.basePry, 0.88)
    // painel "sólido focado": quase opaco, para overlays que se sobrepõem a
    // JANELAS (não só ao wallpaper) — sem blur real, translucidez alta vira
    // fantasma sobre terminal/browser.
    readonly property color surfaceStrong: root._alpha(root.basePry, 0.985)

    // ---- acento (vindo do tema) ----
    readonly property color accent:        root.isDark ? Qt.lighter(root.baseAccent, 1.06) : Qt.darker(root.baseAccent, 1.12)
    readonly property color accentActive:  root.baseAccent                 // fill (texto = textOnAccent)
    readonly property color accentSoft:    root._alpha(root.baseAccent, root.isDark ? 0.24 : 0.18) // hover sutil / trilha de anel
    readonly property color accentTrack:   root._alpha(root._mix(root.basePry, root.baseTxt, 0.16), 0.6) // fundo de progresso
    readonly property color accentPressed: root._alpha(root.baseAccent, 0.34) // feedback de clique

    // ---- texto ----
    readonly property color text:         root.baseTxt
    readonly property color textDim:      root._mix(root.baseTxt, root.basePry, 0.38)
    readonly property color textFaint:    root._mix(root.baseTxt, root.basePry, 0.62)
    readonly property color textOnAccent: root.baseAccentTxt   // texto/ícone sobre fill de acento

    // ---- separação (quase sem stroke; a sombra é a borda) ----
    readonly property color stroke:       root._alpha(root.baseTxt, 0.08)
    readonly property color strokeStrong: root._alpha(root.baseTxt, 0.16)  // contorno mais nítido p/ separar de janelas
    readonly property color shadow:       Qt.rgba(0, 0, 0, root.isDark ? 0.4 : 0.16)
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
    readonly property color gripColor:    root._alpha(root._mix(root.basePry, root.baseTxt, 0.45), 0.9)
    readonly property color gripHover:    root._alpha(root._mix(root.basePry, root.baseTxt, 0.7), 0.95)

    // ---- espaçamento ----
    readonly property int   gap:          10
    readonly property int   pad:          16

    // ---- dimensões das bordas ----
    readonly property int   barW:         46    // barra esquerda fina
    readonly property int   sliver:       6      // borda de hover (topo/direita)
    readonly property int   iconSize:     19
    readonly property int   tooltipReserve: 280  // espaço transparente p/ tooltips

    // ---- dimensões de componentes ----
    readonly property int   rowHeight:    58   // linha de lista (ex.: resultados do launcher)
    readonly property int   iconTile:     38   // tile arredondado com glyph
    readonly property int   trackThin:    5    // espessura de trilha de progresso
    readonly property int   ringWidth:    9    // espessura do anel (RingMeter)

    // ---- tipografia ----
    readonly property string iconFont:    "JetBrainsMono Nerd Font"

    // escala tipográfica
    readonly property int   fsTiny:       10
    readonly property int   fsCaption:    11
    readonly property int   fsBody:       12
    readonly property int   fsBodyLg:     13
    readonly property int   fsLabel:      14
    readonly property int   fsTitle:      16
    readonly property int   fsTitleLg:    18
    readonly property int   fsHeadline:   22
    readonly property int   fsDisplay:    34
    readonly property int   fsHero:       52

    // tamanhos de glyph (Nerd Font)
    readonly property int   glyphSm:      14
    readonly property int   glyphMd:      18
    readonly property int   glyphLg:      24
    readonly property int   glyphXl:      34
    readonly property int   glyphHero:    60

    // ---- timing das animações (sensação "viva") ----
    readonly property int   tFast:        120
    readonly property int   tBase:        240
    readonly property int   tSlow:        360

    // atraso antes de um overlay abrir/fechar por hover
    readonly property int   tHoverOpen:   280
    readonly property int   tHoverClose:  220
}
