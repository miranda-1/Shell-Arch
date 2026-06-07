# HANDOFF — ui-shell-prototype

> Documento de continuidade. Leia tudo antes de tocar em qualquer coisa.
> O objetivo é permitir que outra IA/assistente continue o projeto **sem perder
> contexto e sem quebrar o sistema do usuário**.

---

## 0. ESTADO ATUAL AUTORITATIVO (2026-06-07 — Fase 6 implementada em modo read-only)

> **Leia esta seção primeiro.** Ela é a fonte de verdade atual e **supersede** as
> seções históricas abaixo onde houver conflito. As seções 1–14 são registro
> histórico (incluindo o tema rosé/ink antigo e o "Launcher bugado" — ambos
> **superados**: hoje o tema é **P&B/grafite** e o **Launcher está aprovado**).

**1. Linha oficial de trabalho**
- Trabalho **direto na `main`**, **sem branches**. Não criar branch, não dar push.

**2. Fase 6 — IMPLEMENTADA NO CÓDIGO / VALIDAÇÃO VISUAL PENDENTE**
- Todos os dados fake de hora/data, bateria, rede, perfil, mídia e sistema
  foram substituídos por fontes reais via serviços nativos do Quickshell.
- A shell agora também reage ao estado real do Hyprland com leitura nativa do
  módulo `Quickshell.Hyprland`, sem controle mutável.
- Refinamento visual adicional aplicado na Fase 6: títulos longos de mídia com
  marquee suave, Workspaces da `EdgeTop` mais resumidos e `EdgeLeft` menos técnica.

**3. Resumo das Fases 3, 4, 5 e 6**

*Fases 3 e 4:*
- `Divider.qml` criado e aplicado (EdgeLeft/EdgeTop). Tokens aditivos em `Theme.qml`.
- `NowPlaying.qml` avaliado e NÃO criado (layouts EdgeTop≠Dashboard divergem).
- `ScreenFrame.qml` marcado **DEPRECATED** — não reativar.
- `DesktopAppModel.qml` criado como adapter read-only de `DesktopEntries`.
- Launcher funcional: 4 favoritos reais, busca, foco imediato, Up/Down, Enter executa,
  fecha após executar. Execução via `DesktopEntry.execute()` (sem `sh -c`).
- Ícones reais: tentados e adiados; tiles usam letras por enquanto.

*Fase 5 — Dados reais somente leitura (concluída 2026-06-07):*
- `services/qmldir` + 5 singletons (`pragma Singleton` + `Singleton {}`):
  - **`Clock.qml`** — `SystemClock` evented (precisão minuto); `hour`, `minute`,
    `timeText`, `dateText` pt-BR, `calendarCells`, `currentDay`, `monthName`.
  - **`Battery.qml`** — `UPower.displayDevice` + `PowerProfiles` (leitura);
    `available`, `percent`, `charging`, `full`, `statusText`, `profileText`.
    Nota: `percentage` do UPower é fração 0–1; multiplicar por 100.
  - **`Media.qml`** — `Mpris.players` (leitura); player ativo = primeiro `isPlaying`,
    fallback ao primeiro da lista; `title`, `artist`, `album`, `progress`,
    `positionText`, `lengthText`, `isPlaying`. Timer 1s emite `positionChanged()`
    (re-leitura de posição, NÃO controle).
  - **`Network.qml`** — `Quickshell.Networking` (NetworkManager); `ssid`, `connected`,
    `statusText`; null-guards completos em device/networks/values.
  - **`System.qml`** — `FileView /etc/os-release` → `osName`;
    `Quickshell.env("XDG_CURRENT_DESKTOP")` → `wm`;
    `FileView /proc/uptime` + delta `Date.now()` + Timer 1×/min → `uptimeText`.
    **`FileView` lê arquivo — não é comando externo nem spawn separado.**
- Módulos atualizados com dados reais:
  - `EdgeLeft`: `Clock.hour`/`minute`, `Network.statusText`, `Battery.profileText`;
    `shellShape.clip: false` (antes `clip: true` cortava tooltips em x>46px).
  - `Dashboard`: `Clock.timeText`/`dateText`, `calendarCells`/`currentDay`,
    `System.osName`/`wm`/`uptimeText` (com fallbacks), `Battery.available`/`statusText`.
  - `EdgeTop` aba Media: `Media.title`/`artist`/`album`/`isPlaying`/`progress`/
    `positionText`/`lengthText` — read-only.
- *Fase 6 — Integração Hyprland read-only (implementada em 2026-06-07):*
  - `services/Hyprland.qml` consolidado como adapter somente leitura do singleton
    nativo `Quickshell.Hyprland`.
  - `EdgeLeft`: dots de workspace reais por tela, estados `focused`/`active`/
    ocupado/vazio/urgente, tooltip resumido por workspace e indicação discreta
    da janela ativa real.
  - `EdgeTop` aba Workspaces: lista real de workspaces com cards resumidos
    (`workspace + badge + resumo do que está aberto`), sem poluição técnica.
  - `EdgeTop` aba Media: títulos/subtítulos longos agora usam marquee suave
    com largura fixa e clip correto, sem quebrar layout.
  - `components/MarqueeText.qml`: componente reutilizável para overflow
    horizontal elegante em textos longos.
  - Sem controle mutável do compositor; apenas leitura e derivação para UI.
- `IconButton.qml` — três correções acumuladas:
  - **Flicker fix:** `hlClear = Qt.rgba(accentSoft, 0)` — nunca animar `color` para
    `"transparent"` (`#00000000` = preto alpha 0 → interpola via preto = flash).
  - **Tooltip grafite:** `Card` → `Rectangle` (`color: accentActive`, borda sutil,
    texto `textOnAccent`); sem MultiEffect layer; anima só `opacity`/`x`.
  - **Overflow fix:** `elide: Text.ElideRight` + `width: Math.min(implicitWidth, 220)`;
    `tipBg.width: Math.min(tipText.implicitWidth, 220) + Theme.pad * 2`.
- Política confirmada pelo usuário: `FileView` + DBus read-only → **permitidos**.
  execução externa/escrita/alteração de estado → **proibidas sem autorização explícita**.
- `qmllint` exit 0 em todos os arquivos tocados; working tree limpa.

**4. Arquivos relevantes atuais**
```
shell.qml                      # entrypoint (NÃO alterar) — monta as 4 bordas
config/Theme.qml               # tokens visuais (P&B/grafite) + tokens da Fase 3
config/qmldir                  # registra o singleton Theme
components/
  Divider.qml                  # NOVO (Fase 3) — separador fino reutilizável
  Card.qml  IconButton.qml  Pill.qml  TabButton.qml
  SliderPill.qml  RingMeter.qml  CalendarCard.qml  SectionHeader.qml
  MarqueeText.qml              # NOVO (Fase 6) — overflow horizontal suave
  ScreenFrame.qml              # DEPRECATED/legado — inativo, não importado
services/                      # NOVO (Fase 5) — singletons read-only
  qmldir                       # registra Clock, Battery, Media, Network, System, Hyprland
  Clock.qml   Battery.qml   Media.qml   Network.qml   System.qml   Hyprland.qml
modules/
  EdgeLeft/EdgeLeft.qml        # sidebar principal (aprovada)
  EdgeTop/EdgeTop.qml          # drawer do topo + 4 abas (anti-hover-acidental)
  EdgeRight/EdgeRight.qml      # rail + card de sliders (APROVADO/CONGELADO)
  Launcher/Launcher.qml        # launcher funcional: busca + navegação + execução
  Launcher/DesktopAppModel.qml # adapter read-only de DesktopEntries + favoritos
  Dashboard/Dashboard.qml      # conteúdo da aba Dashboard
ROADMAP.md  HANDOFF.md  README.md  docs/  assets/references/
```

**5. Regras absolutas de segurança (reforço)**
- Trabalhar **somente** dentro de `~/Projetos/ui-shell-prototype/`.
- **Não** mexer em HyDE, Waybar, Hyprland, SDDM, boot, Secure Boot, systemd,
  autostart, login, bateria ou PAM — nada do sistema real.
- **Não** instalar pacotes. **Não** dar push. **Não** criar branch.
- **Não** integrar dados reais fora do escopo autorizado da fase atual.
- **Não** reativar `ScreenFrame`. **Não** commitar bug como feature aprovada.
- Qualquer coisa fora da pasta do protótipo exige **autorização explícita**.

**6. Estado aprovado (NÃO regredir)**
- **Visual:** P&B/grafite (tema claro monocromático) — **aprovado**. (O tema
  rosé/ink descrito nas seções 4/6 históricas está **superado**.)
- **EdgeRight:** aprovado e **congelado** — não mexer.
- **Launcher:** aprovado e estável — abre por **clique** no puxador, fecha por
  **clique-fora/Esc**, com hardening `enabled: !root.open` contra clique invisível.
  **Não** voltar para hover puro. Agora também:
  - mostra 4 favoritos reais quando a query está vazia;
  - aceita digitação imediata ao abrir;
  - busca apps locais reais;
  - navega por `Up`/`Down`;
  - executa o item selecionado com `Enter` ou clique;
  - fecha após executar.
- **EdgeTop:** mantém **anti-hover-acidental** (delay + faixa de gatilho estreita).
  **Não** alterar sua lógica de máscara/hover/trigger/delay.
- **Dados reais (Fase 5):** hora/data, calendário, bateria, rede/SSID, perfil de
  energia, mídia (MPRIS), OS/WM/uptime — todos integrados em `services/` (read-only).
  **Não regredir para valores fake.**
- **Refino visual da Fase 6:** marquee discreto para textos longos de mídia e
  cards de workspace mais limpos/resumidos. **Não regredir para layout técnico
  ou texto explodindo o card.**
- **Tooltip grafite + clip:false:** aprovados. `hlClear` flicker fix aprovado.
  **Não reverter.**

**7. Próxima etapa recomendada — validar a Fase 6 e preparar a Fase 7**
- Próximo passo imediato: validar visualmente a integração read-only do Hyprland
  em todos os monitores.
- Se aprovado, a próxima fase natural é a **Fase 7 — controles reais**, sempre
  atrás de autorização explícita para qualquer ação mutável.
- Continuar sem alterar `~/.config/hypr` nem configs reais.

**8. Instruções para o Codex trabalhar com segurança**
- Antes de editar: `git status` / `git log --oneline -5` para situar-se na `main`.
- Mudanças **pequenas e isoladas**; rodar **`qmllint`** nos arquivos tocados.
- **Não executar `qs -p`** — quem faz o teste visual é o usuário (a shell desenha
  layers na sessão dele). Entregar comandos para o usuário rodar.
- **Não commitar sem aprovação** do usuário; **nunca** dar push.
- Preservar visual/comportamento aprovados (EdgeRight, Launcher, EdgeTop).
- Em dúvida sobre tocar algo sensível (máscara/hover/sistema), **parar e perguntar**.

**9. Dados reais: integrados vs. ainda proibidos/pendentes**
- **Integrados (read-only):** hora/data, calendário, bateria, rede/SSID, perfil de
  energia, mídia/MPRIS (título/artista/álbum/progresso), OS/WM/uptime, apps locais,
  workspaces reais, monitor real por tela, janela ativa real e classe ativa real.
- **Refinos visuais integrados:** marquee para títulos longos de mídia, resumo
  compacto do conteúdo dos workspaces e tooltips mais curtos na `EdgeLeft`.
- **Pendente sem autorização:** áudio/volume (controle), brilho (controle), MPRIS
  play/pause/seek (controle), CPU/GPU/mem/temp (`FileView /proc` — requer política),
  SystemTray real (API disponível;
  requer Image delegate + política sobre activate).
- Spawn externo e comandos externos continuam **proibidos** sem autorização explícita.

**10. Proibição de autostart/deploy por enquanto**
- **Não** criar serviço systemd, **não** configurar autostart, **não** substituir
  a Waybar e **não** fazer deploy. Isso é assunto da Fase 11, só com autorização.

**11. Decisões registradas da Fase 4**
- Fonte de apps: **`Quickshell DesktopEntries.applications`**.
- Execução de apps: **`DesktopEntry.execute()`**.
- Busca: filtro local no adapter `DesktopAppModel.qml`, sem prompt de comando.
- Favoritos atuais: `Opera`, `Terminal`, `Visual Studio Code`, `Spotify`.
- Ícones reais: **adiados**; não são bloqueio funcional da Fase 4.

**12. Decisões registradas da Fase 5**
- Clock: `SystemClock` com `precision: SystemClock.Minutes` (evented; sem Timer manual).
- Battery: `UPower.displayDevice`; `percentage` é fração 0–1 → multiplicar por 100.
- Media: player ativo = primeiro `isPlaying`; posição via `positionChanged()` emit (leitura).
- Network: null-guards obrigatórios em todos os acessos a device/networks/values.
- System: `FileView` em `/etc/os-release` e `/proc/uptime` — leitura, NÃO processo.
- Uptime: lido uma vez em `Component.onCompleted`; drift corrigido com `Date.now()`.
- Tooltip: `clip: false` em `shellShape`; `Rectangle` (não `Card`) evita layer churn.
- Flicker: nunca animar `color → "transparent"` — usar `Qt.rgba(r, g, b, 0)`.
- `PowerProfiles.profile`: apenas leitura; NÃO altera perfil de energia.
- Overflow tooltip: `Math.min(implicitWidth, 220)` + `elide: Text.ElideRight`.

**13. Pendências registradas após a Fase 6**
- **SystemTray real:** `StatusNotifierItem` disponível; adiado — requer `Image` + `Repeater`
  dinâmico + política sobre `activate`/menu.
- **Performance (CPU/GPU/mem/temp):** sem serviço nativo; requer `FileView /proc`+`/sys`
  + política dedicada.
- **Ações controladas de workspace/janela:** fase futura, só com aprovação explícita.
- **Ícones reais no Launcher:** carryover da Fase 4.
- **Media card no Dashboard:** ainda fake; EdgeTop já tem MPRIS real.
- **Nome do mês no CalendarCard:** `Clock.monthName` disponível, não exibido na grade.

**14. Pendências de Fases anteriores (carryover)**
- Revisar futuramente a política/lista de **favoritos padrão** do Launcher.
- Refinar detalhes visuais do Launcher sem mexer no comportamento aprovado.

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

Interromper a instância no terminal em que ela foi iniciada (`Ctrl+C`).

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

Fechar: interromper a instância no terminal onde rodou (`Ctrl+C`). A Waybar do
HyDE continua intacta por baixo.

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
Para fechar: interromper a instância no terminal usado para iniciar.
Próximo passo recomendado: **Leva D**, focada em polimento visual/UX,
redução de abertura acidental, revisão de multi-monitor e preparação gradual
para futura integração de dados reais.

---

## 14. Leva D — polimento de interação (EM ANDAMENTO — 2026-06-06)

> Atualização de fim de sessão. Estado real abaixo. EdgeRight resolvido;
> **Launcher inferior ainda bugado** — NÃO considerar aprovado.

### 14.1 Estado atual do projeto
- Shell continua **isolada em Quickshell/QML**, rodando por cima do HyDE/Waybar
  via `qs -p`, **sem alterar nada do sistema**.
- Bordas montadas em `shell.qml`: `EdgeLeft`, `EdgeTop`, `EdgeRight`, `Launcher`.
  Tudo ainda **fake/stub**; **nenhum dado real** integrado.
- `components/ScreenFrame.qml` continua **desmontado/inativo** (sem `import` nem
  instância em `shell.qml`). **Não reativar.** (Lembrete: ele ainda referencia
  tokens removidos `frameLine/frameRest/frameSoft` → quebraria se remontado.)
- **Git local existe** (`git init` feito nesta leva). Há **3 commits**:
  - `037ea36` chore: snapshot do estado aprovado (sidebar + puxadores)
  - `b338c4a` feat: primeiro commit para o github
  - `117a5e2` feat: ajuste visual na sidebar do som
  - Os commits `b338c4a`/`117a5e2` já incluem o anti-hover e o EdgeRight resolvido.
- **Working tree com alterações pendentes (NÃO commitadas):**
  - `config/Theme.qml`
  - `modules/Launcher/Launcher.qml`
  - São a **tentativa de correção visual do Launcher** (que NÃO resolveu o bug).

### 14.2 Estado da Leva D
Foco da leva: polimento de interação/UX, sem dados reais.
- ✅ **Anti-hover-acidental** — feito e commitado.
- ✅ **EdgeRight** — resolvido e **aprovado pelo usuário**.
- ❌ **Launcher inferior** — **ainda bugado** (ver 14.5). Pendente, não aprovado.

### 14.3 O que foi alterado na Leva D (por arquivo)
- **`config/Theme.qml`** — novos tokens:
  - `tHoverOpen: 280` (atraso p/ abrir por hover);
  - `tHoverClose: 220` (atraso p/ fechar — segura o painel no corredor);
  - `surfaceStrong` (creme quase opaco, alpha ~0.985 — painel sólido sobre janelas);
  - `strokeStrong` (contorno mais nítido p/ separar de janelas).
  - (os 2 últimos são a tentativa pendente do Launcher).
- **`modules/EdgeTop/EdgeTop.qml`** — faixa de gatilho reduzida **720→260px**;
  delay 110→`Theme.tHoverOpen`. (commitado)
- **`modules/EdgeRight/EdgeRight.qml`** — **hover unificado** (1 só HoverHandler +
  máscara contígua), **close delay**, e **remoção dos ícones redundantes** de
  som/brilho (pills externos saíram; controles só no card aberto). (commitado)
- **`modules/Launcher/Launcher.qml`** — anti-hover + hover unificado + close delay
  (commitado); e a tentativa visual **pendente**: card `surfaceStrong` +
  `strokeStrong`, máscara redesenhada (caixa do card + ponte estreita central
  `sliverW`×`bridgeH` fixa no rodapé, em vez de largura inteira até a base).

### 14.4 Anti-hover-acidental (aplicado)
- `tHoverOpen: 280ms` — precisa pousar o mouse ~0,28s para abrir.
- `tHoverClose: 220ms` — fechamento com atraso (atravessar o corredor não fecha).
- **EdgeTop**: faixa de gatilho reduzida (720→260px), perto do puxador visível.
- **EdgeRight**: hover unificado + close delay + remoção de ícones redundantes.
- Padrão técnico: **um único `HoverHandler` cobrindo a janela**; quem define a
  área interativa é a **`mask`** (região contígua → sem corredor morto).

### 14.5 EdgeRight — APROVADO / resolvido
- O usuário testou e disse que **"ficou bom / resolvido"**.
- Em repouso: só o puxador vertical. No hover: card único de controles
  (som/brilho + Wi-Fi/BT), sem ícones duplicados fora do painel.
- **NÃO mexer no EdgeRight na próxima etapa.**

### 14.6 Launcher inferior — BUG PENDENTE (não aprovado)
Sintomas observados pelo usuário ao abrir o Launcher **sobre terminal/browser**:
- fica **instável**; parece **disputar foco/render/interação** com as janelas atrás;
- **some e volta** quando o mouse passa por áreas do browser/terminal;
- **persistiu** mesmo com card mais opaco (`surfaceStrong`) e máscara redesenhada;
- **provável causa**: a geometria/máscara/input-region/modelo de hover do Launcher
  ainda está errada — possível **conflito entre a área interativa do PanelWindow
  e as janelas atrás**;
- precisa ser **investigado com calma no próximo chat** (não é mais "ajuste de
  alpha/máscara": é arquitetural).
- **O Launcher NÃO deve ser considerado aprovado.**

### 14.7 Arquivos alterados / status do working tree
- Commitado nesta leva: `config/Theme.qml`, `modules/EdgeTop/EdgeTop.qml`,
  `modules/EdgeRight/EdgeRight.qml`, `modules/Launcher/Launcher.qml`
  (anti-hover + EdgeRight resolvido).
- **Pendente (não commitado):** `config/Theme.qml`, `modules/Launcher/Launcher.qml`
  (tentativa visual do Launcher, **bug ainda presente**).
- `qmllint` passa (exit 0) nos arquivos alterados.

### 14.8 Comandos de retomada (próximo chat)
```sh
cd ~/Projetos/ui-shell-prototype/
git status
git diff
qs -p ~/Projetos/ui-shell-prototype/shell.qml
qmllint modules/Launcher/Launcher.qml
```

### 14.9 Próximo passo recomendado (só Launcher)
- **Parar de remendar a máscara** do Launcher.
- **Revisar a arquitetura** do Launcher do zero.
- Verificar se o **`PanelWindow` do Launcher deveria usar uma janela / input
  region diferente** (ex.: camada/keyboard-focus/exclusividade distintos).
- Testar uma solução com o **painel sempre dentro de uma única região contígua
  e sólida** (sem ponte/remendo de máscara).
- Considerar **trocar hover puro por clique/atalho** para abrir o Launcher;
  **manter hover só como preview**, se necessário.
- Foco da próxima etapa: **somente o Launcher**.

### 14.10 NÃO FAZER (registro histórico da Leva D)
- **Não** mexer no EdgeRight (ficou bom).
- **Não** reativar `ScreenFrame`.
- **Não** integrar dados reais.
- **Não** mexer no sistema real (Waybar/Hypr/HyDE/SDDM/boot/systemd/login/etc.).
- **Não** commitar como "aprovado" algo ainda bugado (Launcher).

---

## 15. Resumo rápido para próximo chat (atualizado 2026-06-07 — pós-Fase 6)

> Esta é a seção de entrada rápida. Leia a Seção 0 para detalhes completos.

Projeto isolado em `~/Projetos/ui-shell-prototype/`, feito em **Quickshell/QML**,
rodando por cima do HyDE/Waybar via `qs -p` **sem alterar nada do sistema**.

**Estado atual:**
- `EdgeLeft` (sidebar): barra vertical P&B/grafite com relógio, Wi-Fi, perfil, workspaces reais por tela e tooltips mais curtos/resumidos.
- `EdgeTop` (drawer topo): abas Dashboard/Media/Performance/Workspaces — Media real com marquee para títulos longos; aba Workspaces com cards resumidos do Hyprland.
- `EdgeRight` (sliders): **aprovado e congelado** — não mexer.
- `Launcher` (rodapé): abre por clique, busca apps reais, executa via `DesktopEntry.execute()`.
- `Dashboard` (aba): hora/data/calendário/bateria/OS/WM/uptime reais.
- `services/`: Clock, Battery, Media, Network, System e Hyprland — todos `pragma Singleton`, todos read-only.
- `components/MarqueeText.qml`: novo componente reutilizável para overflow horizontal suave.
- Tooltips: `clip: false` no `shellShape`, chip grafite, elide para labels longos, sem flicker.
- **`ScreenFrame.qml`** existe mas está INATIVO (DEPRECATED) — não reativar.
- `qmllint` limpo em `services/Hyprland.qml`, `modules/EdgeLeft/EdgeLeft.qml` e `modules/EdgeTop/EdgeTop.qml`.

**O que ainda é fake:** CPU/GPU/mem/temp (Performance), SystemTray real, media card do Dashboard.

**Próxima fase:** validar visualmente a Fase 6 e, depois de aprovação, planejar a Fase 7.

**Regras que nunca mudam:**
- Somente dentro de `~/Projetos/ui-shell-prototype/`.
- Não mexer em HyDE/Waybar/Hyprland/SDDM/boot/systemd/login/bateria/PAM.
- spawn externo/comandos externos proibidos sem autorização. `FileView`+DBus read-only: ok.
- Não dar push. Não criar branch. Não commitar sem aprovação.
- `qs -p`: só o usuário roda (não a IA).

**Comandos de retomada:**
```sh
cd ~/Projetos/ui-shell-prototype/
git log --oneline -5
git status
qs -p ~/Projetos/ui-shell-prototype/shell.qml  # usuário roda, não a IA
```
