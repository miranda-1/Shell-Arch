# ui-shell-prototype

Protótipo **isolado** de uma *shell interativa de borda* para Hyprland — bordas
vivas, componentes compactos que se revelam no hover, painéis que expandem com
animação, integração visual com o wallpaper.

> ⚠️ **Isolado de propósito.** Nada aqui toca no sistema ativo. Não substitui a
> Waybar atual, não escreve em `~/.config/waybar`, `~/.config/hypr`,
> `~/.config/hyde`. É um sandbox para acertar o conceito antes de qualquer
> integração.

## Stack escolhida

**Quickshell (QML)** — não Waybar. Veja o raciocínio completo em
[`docs/PLANO-TECNICO.md`](docs/PLANO-TECNICO.md). Em resumo: o comportamento que
você quer (estado reativo, hover-reveal, painéis animados embutidos nas bordas) é
o paradigma nativo do Quickshell e é exatamente como o `caelestia-shell` (sua
referência) é construído. Waybar é uma barra estática e não expressa isso.

## Como testar (você roda, não eu)

O protótipo roda **sem instalar nada** e **sem tocar na config do sistema**,
apontando o Quickshell direto para este arquivo:

```sh
qs -p ~/Projetos/ui-shell-prototype/shell.qml
```

Para fechar: `Ctrl+C` no terminal, ou `qs kill`.

Isso abre janelas *layer-shell* sobrepostas à sua sessão atual. A Waybar
continua rodando normalmente por baixo — os dois coexistem durante os testes.
Quando quiser, é só fechar o protótipo e nada mudou no sistema.

## Estrutura

```
shell.qml              # entrypoint do Quickshell (raiz da shell)
config/Theme.qml       # paleta / tokens visuais (integra com wallpaper depois)
modules/
  EdgeLeft/            # dock lateral viva (sempre presente, expande no hover)
  EdgeTop/             # borda superior + painel dashboard/media/perf/workspaces
  EdgeRight/           # controles (volume/brilho/rede/bt/bateria) que expandem
  Launcher/            # launcher que sobe de baixo da tela
  Dashboard/           # conteúdo dos painéis do topo
docs/
  PLANO-TECNICO.md     # diagnóstico, arquitetura, plano incremental, riscos
  DEPENDENCIES.md      # o que precisa estar instalado
assets/                # ícones/recursos do protótipo
```

## Estado atual

Fase 0 — esqueleto. Apenas a **EdgeLeft** está implementada como prova de
conceito do padrão "borda viva que expande no hover". O resto são stubs
documentados. Veja o checklist em `docs/PLANO-TECNICO.md`.
