//@ pragma Env QSG_RENDER_LOOP=threaded

import "modules/EdgeLeft"
import "modules/TopSheet"
import Quickshell

// Entrypoint isolado. Roda com:  qs -p ~/Projetos/ui-shell-prototype/shell.qml
// Convive com a Waybar do HyDE — não substitui nada.
ShellRoot {
    // Uma instância de cada borda por tela. O Scope agrupa as janelas e repassa
    // o `modelData` (a tela) injetado pelo Variants.
    Variants {
        model: Quickshell.screens
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
