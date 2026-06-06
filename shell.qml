//@ pragma Env QSG_RENDER_LOOP=threaded

import "modules/EdgeLeft"
import "modules/EdgeTop"
import "modules/EdgeRight"
import "modules/Launcher"
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

            EdgeLeft  { modelData: scope.modelData }
            EdgeTop   { modelData: scope.modelData }
            EdgeRight { modelData: scope.modelData }
            Launcher  { modelData: scope.modelData }
        }
    }
}
