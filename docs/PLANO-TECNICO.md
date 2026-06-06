# Plano técnico — shell interativa de borda

## 1. Diagnóstico: o que você realmente quer

Você não quer "uma barra bonita". Você quer uma **shell de desktop** — uma
camada de UI viva que mora nas bordas da tela e se comporta como um organismo:

- **Compacta em repouso** (slivers finos nas bordas, quase invisíveis).
- **Reativa ao mouse** — hover revela labels, expande cartões, abre painéis.
- **Estado contínuo** — volume, brilho, rede, bateria, mídia, workspaces não são
  só "texto que atualiza", são *componentes com estado* que crescem/encolhem.
- **Animada** — transições suaves de tamanho, opacidade e posição.
- **Coesa** — os painéis parecem *sair da borda*, são parte da mesma shell, não
  janelas soltas.
- **Integrada ao wallpaper** — a paleta acompanha o fundo.

Isso é um **paradigma de shell reativa**, não de status bar.

## 2. Por que o draft anterior falhou (erro conceitual)

O draft tentou expressar uma shell reativa dentro da **Waybar**. Waybar é, por
arquitetura:

- **Stateless e declarativa estática**: você define módulos num JSON e estiliza
  com CSS. Não há um modelo de estado de UI próprio, nem ciclo de vida de
  componentes, nem composição de painéis.
- **Uma barra, não uma superfície**: pensada para ocupar *uma* aresta com uma
  fileira de módulos. "Painel que expande de dentro da borda", "cartão que cresce
  no hover", "launcher subindo de baixo" não são primitivas dela.
- **Animação limitada**: só o que CSS transition do GTK permite em propriedades
  de estilo — nada de orquestrar layout/posição/máscara de input.
- **Sem hover-reveal real**: dá pra fazer `:hover` em CSS, mas não revelar um
  *painel com conteúdo dinâmico* ancorado na borda.

Resultado inevitável: ao forçar o conceito na Waybar, você regrediu para o que a
Waybar sabe fazer — **uma barra cinza tradicional com módulos comuns**. O draft
não falhou por falta de capricho no CSS; falhou porque a ferramenta não tem as
primitivas do comportamento desejado. Era a ferramenta errada para o conceito.

## 3. Waybar é suficiente? Não.

Waybar cobre **uma fatia pequena** do que você quer: uma fileira de indicadores
numa aresta. Tudo o que define a sua visão — bordas vivas, expansão animada,
painéis embutidos, launcher subindo, hover-reveal com conteúdo — está **fora** do
modelo da Waybar. Insistir nela é o erro que já aconteceu.

## 4. Recomendação de stack

**Quickshell (QML).** Decisão, não opinião solta:

| Critério | Waybar | **Quickshell** | AGS/Astal | Eww |
|---|---|---|---|---|
| Modelo de estado reativo | ❌ | ✅ (QML bindings) | ✅ (JS/GJS) | 🟡 (yuck/vars) |
| Painéis/superfícies arbitrárias na borda | ❌ | ✅ layer-shell nativo | ✅ | 🟡 |
| Animações ricas (size/pos/opacity/blur) | ❌ | ✅ (Qt Quick anim) | 🟡 | 🟡 |
| Hover-reveal com conteúdo dinâmico | ❌ | ✅ | ✅ | 🟡 |
| Integração wallpaper/cores | manual | ✅ (serviço de cor) | ✅ | manual |
| **Sua referência (caelestia) usa** | — | ✅ **é Quickshell** | — | — |
| Maturidade visual "premium" | média | alta | alta | média |

O argumento decisivo: **`caelestia-shell`, que é a sua referência visual e
funcional, é literalmente um projeto Quickshell em QML** (confirmado em
`~/Projetos/referencias/caelestia-shell` — `shell.qml` + 264 arquivos `.qml`,
módulos `bar/ dashboard/ sidebar/ launcher/ controlcenter/ osd/ drawers/`). Os
"drawers/popouts" dele são exatamente o padrão "painel que sai da borda no
hover". Você não está escolhendo uma ferramenta para *imitar* o Caelestia — está
escolhendo a *mesma* ferramenta com que o Caelestia foi feito.

Já está tudo instalado: `quickshell`, `qt6-declarative`, `qt6-wayland`. Custo
zero de dependência nova.

**Por que não os outros:**
- **AGS/Astal**: capaz, mas nem instalado, ecossistema GTK/GJS, e te afastaria do
  código de referência (caelestia é QML). Mais atrito para reaproveitar padrões.
- **Eww**: ótimo para widgets declarativos, mas hover-reveal animado e composição
  de painéis ficam trabalhosos; menos "premium" pronto.
- **Híbrido (Waybar + outra)**: possível, mas vira duas linguagens, dois temas,
  duas fontes de verdade de cor. Só vale se você quiser *manter a Waybar atual* e
  só adicionar bordas extras — registrado como opção, não como recomendação.

## 5. Arquitetura proposta

Uma única shell Quickshell, uma janela *layer-shell* por aresta, todas lendo o
mesmo `Theme` e os mesmos serviços de estado.

```
shell.qml (ShellRoot)
│
├── Variants over Quickshell.screens        # multi-monitor (eDP-1 + HDMI)
│
├── EdgeLeft   (PanelWindow anchor: left)    # dock viva, exclusiveZone fino
│     repouso: sliver ~6px  →  hover: ~220px (labels/ações)
│
├── EdgeTop    (PanelWindow anchor: top)     # borda sutil + popout de painéis
│     hover/clique → Dashboard | Media | Performance | Workspaces
│
├── EdgeRight  (PanelWindow anchor: right)   # pílulas de controle
│     volume / brilho / rede / bt / bateria  → hover expande em cartão/slider
│
├── Launcher   (PanelWindow anchor: bottom)  # sobe de baixo, overlay
│     atalho/gesto → painel de busca de apps
│
└── (services)                               # camada de estado compartilhada
      Audio, Brightness, Network, Bluetooth, Battery, Mpris(media),
      Hyprland(workspaces), ColorScheme(wallpaper)
```

Princípios de design da shell:
- **exclusiveZone só do sliver em repouso** — a área reservada permanente é
  mínima; a expansão é *overlay* por cima das janelas, não empurra o layout.
- **input mask** — em repouso, só o sliver captura mouse; o resto é click-through
  (pra não bloquear o conteúdo da tela). Expande a máscara no hover.
- **um Theme central** — tokens de cor/raio/spacing/timing num só lugar; troca de
  wallpaper repinta tudo.
- **estado em serviços** — widgets só fazem binding; lógica de áudio/rede/etc.
  fica isolada e testável.

## 6. Componentes (escopo por módulo)

1. **EdgeLeft — dock viva** *(POC pronta)*: tira fina sempre presente; ícones de
   apps/atalhos/estados; hover destaca e revela label/ações.
2. **EdgeTop — borda + painéis**: linha sutil no topo; popout com abas Dashboard
   / Media / Performance / Workspaces; sensação de "parte da shell".
3. **EdgeRight — controles**: pílulas compactas (vol/brilho/rede/bt/bateria) que
   viram cartões com slider no hover.
4. **Launcher — busca**: painel que sobe da base, com animação de slide+fade.
5. **Dashboard — conteúdo**: os cartões internos dos painéis do topo (relógio,
   mídia, gráficos de CPU/RAM/temp, grade de workspaces).

## 7. O que dá pra fazer dentro do HyDE vs. shell paralela

- **Coexiste com o HyDE sem conflito**: Quickshell roda como cliente layer-shell
  independente. Durante o protótipo, **roda por cima** da Waybar do HyDE — os
  dois convivem. Nada do HyDE precisa ser tocado para testar.
- **Exige uma shell paralela** (i.e. *substituir* a Waybar) só na fase final, e
  só se você decidir. A migração é: parar a Waybar no autostart do Hyprland e
  subir o Quickshell no lugar — uma linha trocada, **reversível**, feita com
  backup. Até lá, nada disso acontece.
- **HyDE keybinds/wallpaper**: dá pra *ler* o wallpaper atual do HyDE para gerar a
  paleta (integração só-leitura). Disparar o launcher pode ser um keybind novo,
  aditivo, sem remover os do HyDE.

## 8. Plano incremental e seguro

- **Fase 0 — esqueleto isolado** *(feito)*: pasta sandbox, `shell.qml` rodável,
  EdgeLeft como POC do padrão de borda viva. Zero contato com o sistema.
- **Fase 1 — vocabulário visual**: fechar `Theme` (cores/raio/timing), animações
  de hover/expand, máscara de input. Validar a *linguagem* numa borda só.
- **Fase 2 — bordas restantes**: EdgeTop, EdgeRight, Launcher como POCs visuais
  (ainda com dados falsos/placeholder).
- **Fase 3 — serviços reais**: ligar Audio/Brightness/Network/BT/Battery/Mpris/
  Hyprland/ColorScheme. Estado de verdade.
- **Fase 4 — integração com wallpaper**: paleta derivada do fundo do HyDE
  (só-leitura).
- **Fase 5 — teste de convivência**: rodar junto com a Waybar por dias, ajustar.
- **Fase 6 — integração final (opcional, com aprovação)**: backup da config,
  trocar autostart Waybar→Quickshell, plano de rollback de 1 comando.

Cada fase termina com um **teste visual** que *você* roda (`qs -p .../shell.qml`)
e aprova antes da próxima.

## 9. Riscos e cuidados

- **Não substituir a Waybar** até a Fase 6 e só com seu OK. Protótipo sempre por
  cima, nunca no lugar.
- **Backup antes de qualquer integração**: `~/.config/hypr`, autostart, e a
  config da Waybar — copiados antes de tocar.
- **Não mexer em áreas sensíveis**: boot, systemd-boot, Windows, SDDM, autologin,
  Secure Boot, bateria (config de energia), PAM, login, power management. Nada
  disso é tocado por uma shell de UI — e não será.
- **Multi-monitor**: eDP-1 (2560x1600@240) + HDMI (1920x1080). O `Variants` cria
  uma instância por tela; testar em ambos e tratar DPI.
- **Performance**: `QSG_RENDER_LOOP=threaded` e cuidado com blur/sombra em 240Hz.
- **Não rodar scripts de install do caelestia às cegas** — usamos o repo só como
  *referência de leitura*, não instalamos por cima.
- **Reversibilidade**: toda mudança de sistema (só na Fase 6) tem rollback de um
  comando documentado antes de ser aplicada.

## 10. Próximo passo sugerido

Você roda a POC e me diz se a *sensação* da borda viva está no caminho certo:

```sh
qs -p ~/Projetos/ui-shell-prototype/shell.qml
```

Passe o mouse na **borda esquerda**: o sliver deve expandir suave revelando os
ícones com label. Se a linguagem de interação estiver certa, eu sigo para a Fase
1 (fechar Theme + animações) e depois replico o padrão nas outras bordas.

Se você tiver os prints/vídeo de referência, me aponte o caminho deles
(`~/Imagens/...` ou similar) — eu não os encontrei no sistema e eles vão calibrar
o vocabulário visual (raios, densidade, paleta).
