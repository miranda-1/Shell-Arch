//@ pragma Env QSG_RENDER_LOOP=threaded

import "modules/EdgeLeft"
import "modules/TopSheet"
import "services"
import Quickshell

// Entrypoint da shell. Depois do install.sh (symlink em ~/.config/quickshell/
// miranda-shell), roda com:  qs -c miranda-shell   — ou, a partir do repo:  qs -p ./shell.qml
// Convive com a Waybar do HyDE — não substitui nada até você optar pelo deploy.
ShellRoot {
    // Uma instância de cada borda por tela. O Scope agrupa as janelas e repassa
    // o `modelData` (a tela) injetado pelo Variants.
    Variants {
        // Por padrão o shell aparece em todas as telas. Se o usuário escolher um
        // monitor específico na página "Telas" (Monitors.shellMonitor), filtra
        // para só essa tela.
        //
        // Importante: consideramos APENAS telas que o Hyprland confirma como
        // conectadas (Monitors.monitors). Ao desplugar o HDMI, o Quickshell pode
        // manter por um tempo um `screen` fantasma da tela que saiu; sem esse
        // filtro o shell tentaria abrir na tela morta e não apareceria no
        // notebook. Com o filtro, ao sair de casa só com o eDP-1 o monitor
        // escolhido (HDMI) some da lista, o filtro não casa e caímos no fallback
        // → o shell abre direto na tela interna.
        model: {
            const all = Quickshell.screens || [];

            // nomes dos monitores REALMENTE conectados, segundo o Hyprland vivo
            const live = (Monitors.monitors || [])
                .map(m => m && m.name ? m.name : "")
                .filter(n => n !== "");
            const connected = live.length > 0
                ? all.filter(s => s && live.indexOf(s.name) !== -1)
                : all;

            const chosen = Monitors.shellMonitor;
            if (chosen) {
                const match = connected.filter(s => s && s.name === chosen);
                if (match.length > 0)
                    return match;
            }
            // sem escolha, ou tela escolhida ausente: todas as conectadas
            return connected;
        }
        delegate: Scope {
            id: scope
            required property var modelData
            property string currentPage: "dashboard"
            property bool contextOpen: false

            function toggleContextPage(pageId) {
                if (scope.contextOpen && scope.currentPage === pageId) {
                    scope.contextOpen = false;
                    return;
                }

                scope.currentPage = pageId;
                scope.contextOpen = true;
            }

            function closeContext() {
                scope.contextOpen = false;
            }

            EdgeLeft {
                modelData: scope.modelData
                currentPage: scope.currentPage
                contextOpen: scope.contextOpen
                onRequestPage: (pageId) => scope.toggleContextPage(pageId)
            }

            TopSheet {
                modelData: scope.modelData
                currentPage: scope.currentPage
                open: scope.contextOpen
                onRequestClose: scope.closeContext()
            }
        }
    }
}
