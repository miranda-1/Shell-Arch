# HANDOFF — ui-shell-prototype

> Documento de continuidade. Leia tudo antes de tocar em qualquer coisa.
> O objetivo é permitir que outra IA/assistente continue o projeto **sem perder
> contexto e sem quebrar o sistema do usuário**.

---

## 1. Objetivo do projeto

Este projeto **não é uma Waybar bonita**. É uma **shell visual reativa** para
**Arch Linux + Hyprland + HyDE**, inspirada no **Caelestia**, com:

- **bordas vivas** ao redor da tela;
- **drawers** (painéis que descem/sobem/deslizam);
- **launcher** que sobe do rodapé;
- **dashboard** com cards;
- **sliders** (volume/brilho) em cards;
- **interação por hover** (em repouso é discreto, no hover revela/expande).

A linguagem de interação é o ponto central: componentes compactos em repouso que
se revelam e expandem com animação suave quando o mouse se aproxima das bordas.
Waybar foi descartada como ferramenta principal porque é uma barra estática
stateless — incapaz de expressar esse paradigma. A stack escolhida é
**Quickshell/QML** (mesma tecnologia do caelestia-shell de referência).

---

## 2. Máquina e ambiente

- **Sistema:** Arch Linux + Hyprland (0.55.2) + HyDE
- **Usuário:** `miranda` (home `/home/miranda`)
- **Pasta do protótipo:** `~/Projetos/ui-shell-prototype/`
- **Referência (só-leitura):** `~/Projetos/referencias/caelestia-shell` (projeto
  Quickshell real) e `~/Projetos/referencias/waybar-caelestia-draft` (draft
  antigo abandonado da abordagem Waybar)
- **Stack:** Quickshell / QML (Qt Quick)
- **Quickshell:** versão **0.3.0** instalada (binário `qs`)
- **Qt:** 6.11.1 (qt6-base/qt6-declarative)
- **Fonte de ícones:** `JetBrainsMono Nerd Font` (instalada)
- **Monitores:** `eDP-1` 2560x1600@240Hz + `HDMI-A-1` 1920x1080
- **Aviso conhecido:** o pacote `quickshell` foi **buildado contra Qt 6.11.0** e
  o sistema está em **Qt 6.11.1**. Ao rodar aparece um `WARN` recomendando
  rebuildar o pacote. **Ainda NÃO mexemos nisso** — só vira problema real se a
  shell crashar ao abrir. Por ora, ignorar.

---

## 3. Regras absolutas de segurança

Estas regras vêm do usuário e são **inegociáveis**:

- **Não** mexer no sistema ativo.
- **Não** substituir a Waybar (ela continua rodando por baixo como fallback).
- **Não** alterar `~/.config/waybar`.
- **Não** alterar `~/.config/hypr`.
- **Não** alterar `~/.config/hyde`.
- **Não** alterar SDDM.
- **Não** mexer em: boot, systemd-boot, Windows, Secure Boot, bateria,
  PAM, login, autologin, power management.
- **Tudo** deve continuar isolado dentro de `~/Projetos/ui-shell-prototype/`.
- O `caelestia-shell` em `~/Projetos/referencias/` é **referência só-leitura** —
  **não instalar por cima** do sistema, não rodar scripts de install dele.
- **Qualquer** alteração fora da pasta do protótipo exige **autorização explícita
  do usuário** antes de ser feita.
- O protótipo roda **por cima** da sessão atual (`qs -p ...`), nunca no lugar de
  nada. Fechar o protótipo não muda nada no sistema.

---

## 4. Referência visual

Os prints de referência (em `assets/references/`) mostram uma shell **clara,
quente, rosé/ink** — **NÃO é dark**. É um wallpaper sumi-ê (nanquim) creme com a
shell em tons quentes. Características:

- **fundo creme/translúcido** (superfícies deixam o wallpaper vazar tingido);
- **acento terracota/clay** (`#b0604a`, ativo `#a8553f`);
- **texto carvão morno** (`#3a322e`);
- **sombras difusas** (a separação vem da sombra, não de borda);
- **cards bem arredondados** (raio ~18);
- **pills** (totalmente arredondadas) em toggles/chips;
- **pouca borda dura** (stroke quase imperceptível);
- **blur/transparência leve** (ainda sem blur real forte aplicado);
- **visual premium/orgânico**;
- **movimento suave** tipo `OutCubic` (geral) e `OutExpo` (drawer/launcher),
  durações ~120–360ms;
- **tudo overlay** — os painéis se sobrepõem, **não empurram** o layout das
  janelas. Só a barra esquerda reserva espaço permanente (fino).

Estados capturados nos prints: repouso, drawer Dashboard, drawer Media, hover de
tray (SafeEyes/Wi-Fi/bateria), borda direita com tabs espiando, Performance com
anéis, e Launcher subindo do rodapé.

---

## 5. Estrutura atual do projeto (nomes reais)

```
~/Projetos/ui-shell-prototype/
├── shell.qml                       # entrypoint (monta as bordas por tela)
├── README.md                       # visão geral + como testar
├── HANDOFF.md                      # este arquivo
├── config/
│   ├── Theme.qml                   # tokens visuais (tema claro rosé/ink)
│   └── qmldir                      # registra o singleton Theme  ← extra
├── components/
│   ├── ScreenFrame.qml             # experimento histórico da moldura; inativo
│   ├── Card.qml                    # card arredondado + sombra (MultiEffect)
│   ├── Pill.qml                    # pílula
│   ├── IconButton.qml              # ícone da barra + hover + tooltip
│   ├── TabButton.qml               # aba do drawer (sublinhado clay)
│   ├── SliderPill.qml              # slider-pílula arrastável (fake)
│   ├── RingMeter.qml               # anel de progresso (Canvas)
│   ├── CalendarCard.qml            # mini-calendário
│   └── SectionHeader.qml           # rótulo de seção
├── modules/
│   ├── EdgeLeft/EdgeLeft.qml       # barra vertical principal (aprovada)
│   ├── EdgeTop/EdgeTop.qml         # drawer do topo + 4 abas
│   ├── EdgeRight/EdgeRight.qml     # rail + card de sliders
│   ├── Launcher/Launcher.qml       # painel que sobe do rodapé
│   └── Dashboard/Dashboard.qml     # conteúdo da aba Dashboard
├── docs/
│   ├── PLANO-TECNICO.md            # diagnóstico/arquitetura/plano/riscos
│   └── DEPENDENCIES.md
└── assets/
    └── references/                 # 8 prints de referência (.png)
```

**Diferenças vs. a árvore esperada no pedido:**
- existe `config/qmldir` (não listado no pedido) — necessário para o singleton
  `Theme` funcionar;
- existe `README.md` (já criado na fase de planejamento);
- **não há repositório git inicializado** ainda no protótipo.

---

## 6. O que já foi feito

### Leva A — vocabulário visual + barra esquerda
- `config/Theme.qml` reescrito para o **tema claro rosé/ink** (cores, forma,
  espaçamento, durações, `iconFont`).
- `modules/EdgeLeft/EdgeLeft.qml` criada como **barra vertical principal**: logo
  Arch no topo → apps (ativo em círculo clay) → dots de workspace → centro com
  "Desktop" + monitor → base com tray, **relógio "21/40" empilhado**, status e
  power. Hover destaca o ícone e revela **tooltip lateral**.
- Componentes base criados: `Card`, `Pill`, `IconButton`.
- **Erro inicial corrigido no Theme.qml**: havia uma propriedade chamada
  `onAccent`, que o QML interpretava como *signal handler* (`on`+`Accent`) e
  quebrava o carregamento. Renomeada para `textOnAccent`. Os tokens de easing
  (`ease`/`easeOut`) foram **removidos do Theme** — o easing agora vai direto na
  animação (`easing.type: Easing.OutCubic` / `Easing.OutExpo`).
- EdgeLeft **testada e aprovada visualmente** pelo usuário.

### Leva B — drawers, dashboard, sliders, launcher
- `modules/EdgeTop/EdgeTop.qml`: **drawer que desce do topo** (overlay, slide-down
  + fade), com abas **Dashboard / Media / Performance / Workspaces**.
- `modules/Dashboard/Dashboard.qml`: cards **fake** (clima, sistema Arch/Hyprland,
  relógio grande, calendário, mídia, mini-performance).
- Abas implementadas: Dashboard (cards), Media (player), Performance (3 anéis),
  Workspaces (grade de tiles).
- `modules/EdgeRight/EdgeRight.qml`: **tabs/pílulas clay espiando** na borda
  direita; hover desliza um card com **sliders fake** de volume e brilho +
  pílulas Wi-Fi/Bluetooth.
- `modules/Launcher/Launcher.qml`: **painel que sobe** do rodapé (slide-up + fade)
  com campo de busca fake e lista de apps fake.
- Componentes novos: `TabButton`, `SliderPill`, `RingMeter`, `CalendarCard`,
  `SectionHeader`.
- `shell.qml` ajustado para montar **as 4 bordas por tela** via `Scope` dentro de
  `Variants` (o `modelData`/tela é injetado pelo Variants).
- **Detalhe técnico importante (encoding de glyphs):** ao escrever os arquivos,
  os caracteres Nerd Font (PUA) se perdiam (viravam string vazia). A correção foi
  **inserir os glyphs por codepoint via script Python** (ex.: `chr(0xf028)`).
  Se for editar glyphs no futuro, prefira esse método ou escapes `\uXXXX` — evite
  colar o caractere PUA cru.
- Leva B **testada e aprovada visualmente** pelo usuário.

### Leva C — moldura/frame viva contínua
- **`components/ScreenFrame.qml` (novo):** `PanelWindow` ancorado nas **4 bordas**,
  transparente, `WlrLayer.Top`, **montado primeiro** no `shell.qml` (fica no fundo
  da camada). Desenha **uma única linha finíssima e arredondada** ao redor da tela
  via um `Rectangle` com `color: transparent` + `border` arredondado
  (`radius: Theme.screenRound`). Por ser **uma forma só**, topo/direita/base e os
  **quatro cantos são a mesma linha** → continuidade e cantos conectados "de graça".
  **Máscara vazia (`Region {}`)** ⇒ NÃO captura clique: desktop 100% click-through.
  Tem ainda um `Rectangle` de **halo sutil** (`Theme.frameSoft`) para profundidade.
- **`config/Theme.qml`:** novos tokens — `frameLine: 2` (espessura em repouso),
  `frameRest` (clay translúcido ~0.45 — discreto/premium), `frameSoft` (halo),
  `gripLen: 56` (puxador central).
- **`shell.qml`:** `import "components"` + `ScreenFrame { modelData }` montado
  **antes** de EdgeLeft (z-order: moldura no fundo, barra/drawers por cima).
- **`EdgeTop` / `Launcher`:** ganham um **"puxador" central** (`grip`) — um segmento
  clay arredondado sobre a linha, afordância sutil que **some quando o painel abre**.
  Trocado o `open` instantâneo por **`open` com atraso (Timer 110ms)**: encostar de
  raiva no topo/rodapé não abre mais o painel sem querer; ao sair, fecha na hora.
  Faixa de hover subiu de 12→14px (mira mais fácil, ainda invisível).
- **`EdgeRight`:** as 2 pílulas agora ficam dentro de um `Item` com um **trilho
  vertical fino** (`Theme.frameLine`) contínuo com a linha da moldura → as tabs
  parecem "engrossar" a linha em vez de flutuarem soltas. O trilho acende em clay
  no hover/aberto. Glyphs preservados (não toquei nas linhas com PUA).
- A **esquerda** (EdgeLeft) cobre os cantos sup-esq/inf-esq (barra 46px > raio 22),
  de modo que a linha do topo e da base **nasce da barra**.

### Leva C.1 — refino visual (cor/integração/direita escondida)
Três ajustes em cima da Leva C (aprovação visual pendente):
- **Direita escondida em repouso:** em `EdgeRight`, a `Column` das pílulas
  (volume/brilho) agora tem `opacity: root.open ? 1 : 0` + `Behavior` — em repouso
  fica só o **trilho creme finíssimo**; controles surgem no hover, igual topo/rodapé.
  O `open` virou `property` com `Timer` de 110ms (paridade anti-hover-acidental).
- **Cor da moldura = creme da barra:** `Theme.frameRest` deixou de ser clay/terracota
  e passou a `Qt.rgba(0.965,0.925,0.905,0.95)` — mesmo creme de `Theme.bar` (só um
  tico mais opaco p/ o hairline ler). `frameSoft` virou halo creme sutil. Reduz o
  contraste barra↔moldura; a linha ficou mais clara e integrada.
- **União barra↔moldura (cantos):** em `EdgeLeft`, a `barBg` passou a arredondar os
  cantos **externos (esquerdos)** com `Theme.screenRound` (22, igual à moldura) e a
  **quadrar** os cantos internos (direitos). Some a cunha/triângulo no encontro com
  a linha do topo/base e o canto externo passa a compartilhar o mesmo arco da
  moldura → leitura de **peça única**.
- **Puxadores (topo/rodapé):** cor trocada de `accentSoft` (rosé) p/ `Theme.textFaint`
  (taupe neutro), pra não destoarem da linha creme.
- `ScreenFrame.qml` não mudou (a cor vem dos tokens do Theme).

### Reversão da Leva C — retorno ao conceito mais limpo
- `shell.qml`: `ScreenFrame` foi **removido da montagem**; a shell volta a ser
  composta só por `EdgeLeft`, `EdgeTop`, `EdgeRight` e `Launcher`.
- `modules/EdgeLeft/EdgeLeft.qml`: removidos os acoplamentos visuais da moldura
  (selagens, fusão artificial e remendos de canto). A barra virou uma peça mais
  orgânica, lida como uma **pill vertical cortada pela borda esquerda**.
- `modules/EdgeTop/EdgeTop.qml` e `modules/Launcher/Launcher.qml`: os puxadores
  centrais passam a ser **autônomos**, discretos, creme/rosé, sem parecer trechos
  de uma linha contínua.
- `modules/EdgeRight/EdgeRight.qml`: removida a leitura de trilho integrado à
  moldura. Em repouso fica só um **puxador vertical curto**; os controles de
  volume/brilho continuam escondidos até hover/abertura.
- `config/Theme.qml`: os tokens da moldura completa (`frameLine`, `frameRest`,
  `frameSoft`) deixaram de existir; ficam só os tokens úteis aos puxadores
  minimalistas (`gripLen`, `gripThickness`, `gripColor`, `gripHover`).

### Validação
- `qmllint` passa **sem erros** em todos os `.qml` alterados/criados (exit 0).
- Contagem de glyphs reconferida: EdgeTop 8, EdgeRight 6, Launcher 6, EdgeLeft 16
  (todos inalterados). Dashboard 8 (não tocado).
- **A shell NÃO é executada pela IA** — quem roda o teste visual é o usuário
  (ela desenha layers na tela dele).

---

## Estado atual — pós-reversão da moldura completa

### 1. Decisão visual atual

A ideia de **moldura/quadrado completo ao redor da tela foi abandonada**.

**Motivo:**
- a moldura contínua gerava **junções artificiais**;
- os **cantos** ficavam difíceis de fechar;
- a estética ficou **menos orgânica**;
- o visual **melhorou** quando a shell voltou para um conceito mais limpo.

**Novo conceito aprovado:**

**"sidebar esquerda premium + pequenos puxadores minimalistas nas outras bordas"**

### 2. Estado visual atual aprovado

- O usuário testou o estado pós-reversão e disse que **"ficou muito melhor"**.
- O visual atual desejado é:
  - **sidebar esquerda** como elemento principal;
  - sidebar **colada na borda esquerda**;
  - sidebar com visual **claro rosé/ink**;
  - sidebar mais **arredondada/orgânica** nas pontas que entram para a tela;
  - **sem moldura fechada** ao redor da tela;
  - topo com **pequeno puxador discreto** para abrir o drawer;
  - baixo com **pequeno puxador discreto** para abrir o launcher;
  - direita com **pequeno puxador/trilho discreto**;
  - controles de **som/brilho escondidos em repouso**;
  - painéis continuam abrindo por **hover**;
  - tudo ainda **fake/stub**;
  - nada integrado a **dados reais** ainda.

### 3. ScreenFrame

- `components/ScreenFrame.qml` pode continuar existindo no projeto.
- Mas **não deve estar montado/ativo** em `shell.qml`.
- A moldura completa **não faz mais parte** do visual aprovado.
- **Não tentar reativar `ScreenFrame`** sem autorização explícita do usuário.

### 4. Arquivos alterados nessa reversão

- `shell.qml`
- `modules/EdgeLeft/EdgeLeft.qml`
- `modules/EdgeTop/EdgeTop.qml`
- `modules/Launcher/Launcher.qml`
- `modules/EdgeRight/EdgeRight.qml`
- `config/Theme.qml`
- `HANDOFF.md`

### 5. Regras de segurança continuam valendo

- Trabalhar **somente** dentro de `~/Projetos/ui-shell-prototype/`.
- **Não** mexer em Waybar.
- **Não** mexer em HyDE.
- **Não** mexer em Hyprland.
- **Não** mexer em SDDM.
- **Não** mexer em boot, systemd-boot, Windows ou Secure Boot.
- **Não** mexer em bateria, PAM, login ou autologin.
- **Não** criar serviço systemd.
- **Não** configurar autostart.
- **Não** instalar pacotes.
- **Não** integrar dados reais sem autorização.
- **Não** dar `push`.

### 6. Comando de teste atual

Rodar:

```sh
qs -p ~/Projetos/ui-shell-prototype/shell.qml
```

Fechar:

```sh
qs kill
```

ou `Ctrl+C` no terminal.

---

## 8. Registro histórico — Leva C abandonada

### Leva C — Frame/Moldura viva completa

> Registro histórico. Esta direção foi implementada como experimento visual,
> mas **não é mais o caminho ativo** do projeto.

**Objetivo original:** transformar a shell em uma **moldura contínua ao redor da
tela**, de modo que o monitor pareça *envolvido* por uma shell viva.

**Escopo:**
- **Esquerda:** continua como a **barra principal**, mais visível (já existe).
- **Topo:** uma **linha/sliver finíssimo contínuo** ao longo de toda a borda
  superior (não só a faixa central de gatilho).
- **Direita:** uma **linha/sliver finíssimo contínuo**, **não** só as pílulas
  isoladas de hoje.
- **Baixo:** uma **linha/sliver finíssimo contínuo** ao longo de toda a borda
  inferior.
- **Cantos:** os **quatro cantos devem parecer conectados** (moldura única, com
  cantos arredondados — provavelmente um módulo de *screen corners* + slivers que
  se encontram nos cantos). Já existe o token `Theme.screenRound` (22) reservado
  para isso.
- **Repouso:** a moldura deve ser **muito fina, elegante e discreta**.
- **Hover por área** (mantendo o que já funciona):
  - topo revela o **drawer/dashboard**;
  - direita revela **sliders/cards**;
  - baixo revela o **launcher**;
  - esquerda mantém a **barra principal**.

**Abordagem sugerida (a validar):** criar um módulo `Frame` (ou `EdgeFrame`) que
desenha os slivers contínuos das 4 bordas + cantos arredondados como uma camada
de fundo coesa, e fazer EdgeTop/EdgeRight/Launcher se ancorarem/“nascerem” dessa
moldura em vez de serem janelas soltas. Cuidar para que os slivers contínuos
**não** capturem clique (máscara restrita às zonas de hover reais), senão a
moldura bloquearia o desktop nas bordas.

---

## Próxima etapa recomendada

### Leva D — Polimento da shell própria

Antes de qualquer dado real, continuar com uma fase de **polimento visual/UX**.

**Objetivos:**
- refinar a sidebar esquerda:
  - raio;
  - sombra;
  - largura;
  - respiro interno;
  - sensação de peça orgânica;
  - evitar aparência de retângulo seco;
- refinar os puxadores:
  - topo;
  - baixo;
  - direita;
  - tamanho;
  - cor;
  - intensidade;
  - hover;
  - delay;
- reduzir abertura acidental:
  - delays;
  - áreas de hover;
  - talvez trocar alguns gatilhos para clique/keybind;
- revisar multi-monitor:
  - decidir se a shell aparece em todos os monitores ou só no principal;
- preparar terreno para dados reais, mas ainda **sem integrar tudo de uma vez**.

---

## 9. O que ainda NÃO fazer

- **Não** integrar **áudio real** ainda.
- **Não** integrar **brilho real** ainda.
- **Não** integrar **rede real** ainda.
- **Não** integrar **bateria real** ainda.
- **Não** integrar **MPRIS/Spotify real** ainda.
- **Não** integrar **performance real** (CPU/GPU/mem/temp) ainda.
- **Não** substituir a **Waybar** ainda.
- **Não** criar **serviço systemd**.
- **Não** criar **autostart** ainda.
- **Não** instalar no **HyDE**.
- **Não** fazer **integração final** com o sistema.

Tudo permanece **fake/visual** e **isolado** até o usuário autorizar explicitamente
a próxima etapa.

---

## 10. Comando de teste

Rodar (o usuário roda; a IA não executa):
```sh
qs -p ~/Projetos/ui-shell-prototype/shell.qml
```

Fechar:
```sh
qs kill
```
ou `Ctrl+C` no terminal onde rodou. A Waybar do HyDE continua intacta por baixo.

---

## 11. Problemas conhecidos

- **Warning Qt/Quickshell 6.11.0 vs 6.11.1:** aparece ao rodar; não mexer por ora;
  só preocupa se a shell crashar ao abrir (aí o passo seria rebuildar o pacote
  `quickshell` — fora do protótipo, exige autorização).
- **Glyphs quadrados (□):** se a JetBrainsMono Nerd Font não cobrir algum
  codepoint, o ícone aparece como quadrado — trocar o codepoint. Lembrar do
  problema de encoding: inserir glyphs por codepoint (Python `chr()`) ou `\uXXXX`,
  nunca colar o caractere PUA cru (ele se perde na escrita).
- **Overlays podem abrir sem querer por hover:** os gatilhos do topo e do rodapé
  são faixas de hover; encostar na faixa central abre o painel. É proposital nesta
  fase (sem keybind). O gatilho real por atalho fica para a integração.
- **Multi-monitor:** o `Variants` cria **uma instância de cada borda por tela**
  (eDP + HDMI). Esperado; dá para restringir depois.
- **Máscara de input (`mask`):** precisa de cuidado — se mal dimensionada, um
  overlay transparente pode **bloquear cliques** no desktop. Padrão atual:
  `exclusiveZone: 0` + `mask` restrita à faixa de hover (fechado) que expande para
  o bounding box do painel (aberto). **Testar sempre o click-through.**
- **Performance a 240Hz:** observar. Hoje só os painéis externos têm sombra
  (`MultiEffect`); cards internos são retângulos simples para não aninhar layers.
- **Blur real:** ainda **não** foi usado fortemente (só translucidez). Se for
  adicionar blur, medir custo antes.
- **`Behavior on anchors.rightMargin/bottomMargin`** (EdgeRight/Launcher): anima
  margem de âncora; se o slide “pular”, trocar por animação de `y`/transform.

---

## 12. Critérios atuais de aprovação visual

O estado atual só é considerado bom se:

- a `EdgeLeft` parecer a peça principal da shell, com leitura **premium/orgânica**;
- topo, direita e baixo parecerem **puxadores autônomos** e não pedaços de uma
  moldura;
- os **overlays** (drawer/sliders/launcher) continuarem bonitos;
- o **click-through** continuar funcionando (desktop clicável nas bordas em
  repouso);
- a **Waybar** continuar intacta por baixo;
- **nada fora do protótipo** for alterado.

---

## 13. Sugestão de commit

O protótipo ainda **não é um repositório git**. Para versionar este estado:

```sh
cd ~/Projetos/ui-shell-prototype
git init
git add .
git commit -m "refactor: remove moldura contínua e refina sidebar da shell"
```

Alternativas de mensagem:
- `feat: define shell visual com sidebar premium e puxadores minimalistas`
- `refactor: remove moldura contínua e refina sidebar da shell`

---

## Resumo rápido para próximo chat

Projeto isolado em `~/Projetos/ui-shell-prototype/`, feito em **Quickshell/QML**,
rodando por cima do HyDE/Waybar sem alterar nada do sistema.
O protótipo já tem `EdgeLeft`, `EdgeTop`, `EdgeRight`, `Launcher` e `Dashboard`,
tudo ainda **fake/stub**.
A tentativa de **moldura contínua completa** foi implementada como experimento,
mas foi **abandonada**.
Motivo: a moldura criava junções artificiais, cantos difíceis de fechar e uma
estética menos orgânica.
O conceito aprovado agora é: **sidebar esquerda premium + pequenos puxadores
minimalistas nas outras bordas**.
`ScreenFrame.qml` ainda existe no projeto por histórico, mas **não está ativo**
e **não deve ser remontado** sem autorização explícita.
O usuário testou o estado atual e disse que **"ficou muito melhor"**.
O topo mantém um puxador discreto para o drawer; o baixo, um puxador discreto
para o launcher; a direita, um puxador/trilho curto com controles escondidos
em repouso.
Nenhum dado real foi integrado ainda.
Comando de teste atual: `qs -p ~/Projetos/ui-shell-prototype/shell.qml`.
Para fechar: `qs kill` ou `Ctrl+C`.
Próximo passo recomendado: **Leva D**, focada em polimento visual/UX,
redução de abertura acidental, revisão de multi-monitor e preparação gradual
para futura integração de dados reais.
