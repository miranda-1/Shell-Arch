# ROADMAP — Shell Visual Quickshell

> Documento permanente de direção do projeto. Serve de mapa para não nos
> perdermos conforme a shell evolui. Atualize-o sempre que uma fase mudar de
> estado ou quando a direção for revista.

## 1. Visão do projeto

Construir uma **shell visual própria** em Quickshell/QML para **Arch + Hyprland + HyDE**.
O objetivo final é uma shell **premium, estável, funcional e segura** para uso
diário: bonita o suficiente para substituir mentalmente a barra atual, estável
o suficiente para rodar o dia todo sem irritação, e segura o suficiente para
**conviver com o sistema real sem quebrá-lo**.

A direção aprovada é:

- **sidebar esquerda premium** como peça principal da interface;
- **TopSheet contextual** como superfície principal de conteúdo;
- **sem moldura contínua** em volta da tela (o `ScreenFrame` fica inativo);
- projeto ainda **isolado do sistema real**;
- dados reais **somente** onde já houver serviço seguro e aprovado.

A evolução é incremental: primeiro a identidade visual e a UX ficam sólidas,
depois vêm componentização, launcher funcional, dados reais somente leitura,
integração com Hyprland, controles reais, tema dinâmico, performance e, por
fim, um deploy opcional.

## 2. Regras permanentes de segurança

Estas regras valem para **todas as fases**, salvo autorização explícita em contrário:

- **não mexer fora de `~/Projetos/ui-shell-prototype/`** sem autorização explícita;
- **não mexer em HyDE / Waybar / Hyprland reais** durante as fases visuais;
- **não mexer em** boot, Secure Boot, SDDM, autostart, systemd, login, bateria ou PAM;
- **não integrar dados reais** antes da base visual/UX estar aprovada;
- **sempre manter o git limpo** antes de mudanças grandes;
- **sempre criar commits pequenos** e focados;
- **nunca dar push sem autorização**.

## 3. Estado atual resumido (atualizado 2026-06-09 — abas acopladas + controles funcionais)

- trabalho direto na **`main`** (linha oficial; sem branches); working tree limpa,
  HEAD `869154e`;
- `shell.qml` monta **EdgeLeft** e **TopSheet** por tela; roda via **`qs -p`**;
- **`ScreenFrame` inativo/DEPRECATED**; EdgeTop/EdgeRight/Launcher antigos são
  legado desmontado;
- **visual P&B/grafite aprovado** (tema claro monocromático);
- **abas acopladas à sidebar (aprovadas em 2026-06-09)**: cada página do TopSheet
  nasce colada na EdgeLeft, na linha do seu botão, deslizando de dentro da barra
  (horizontal, `tSlow`); troca de página recolhe → troca escondido → revela;
  altura do painel encaixa no conteúdo; Sistema/Perfil ancoram pela base;
  ⚠️ `interactiveLeft = 0` (a janela já desconta a exclusiveZone da barra —
  nunca somar `Theme.barW` de novo);
- **SearchPage aprovada**: launcher completo (foco automático, ↑/↓, Enter abre e
  fecha, Esc limpa→fecha, hover unificado com teclado, estado vazio), sem header,
  alinhada à lupa, largura própria (760);
- **DashboardPage refinada e aprovada**: hero de data/hora, janela ativa com
  chips, Rede/Energia, faixa de mídia com marquee; `MetricCard` com altura
  derivada do conteúdo + elide (fix de texto vazando);
- **POLÍTICA DE MUTAÇÃO ATUALIZADA (2026-06-09)**: escritas autorizadas
  **somente via API typed do Quickshell**, centralizadas em `services/`;
  `Process`/comando externo segue proibido;
- **Controles funcionais implementados (Fase 8 antecipada, em validação)**:
  Wi-Fi (toggle/scan/lista/conectar em rede salva — `Network.qml` estendido),
  Bluetooth (toggle/pareados — serviço novo `Bluez.qml`), volume real Pipewire
  (serviço novo `Audio.qml`, mute no badge), perfil de energia alternável
  (`Battery.cycleProfile()`); brilho segue placeholder (DDC exigiria `Process`);
- `QuickToggle` (corpo/switch com sinais) e `ControlSlider` (arrasto) agora são
  interativos; `services/qmldir` registra 8 singletons;
- ainda fake/pendente: brilho, CPU/MEM/TMP na SystemPage, SystemTray, ícones
  reais no launcher;
- **próximo passo**: usuário validar a ControlsPage no runtime (Bluetooth é o
  ponto mais sensível — primeiro uso do módulo `Quickshell.Bluetooth`).

## 4. Roadmap por fases

### Fase 0 — Base segura e versionamento ✅ CONCLUÍDA

**Tarefas**
- Git local e remoto correto;
- usuário/email Git correto;
- branch `main`;
- `HANDOFF.md` e `ROADMAP.md` atualizados;
- commits organizados.

**Critério de conclusão**
- `git status` limpo;
- GitHub correto;
- documentação coerente.

### Fase 1 — Identidade visual da shell ✅ CONCLUÍDA

**Tarefas**
- sidebar esquerda premium;
- refino de raio, sombra, espaçamento, densidade;
- puxadores minimalistas;
- consistência de `Theme.qml`;
- remover sensação de retângulo/moldura.

**Critério de conclusão**
- visual aprovado em todos os monitores;
- `ScreenFrame` continua inativo;
- `qmllint` limpo.

### Fase 2 — UX e interação estável ✅ CONCLUÍDA

**Tarefas**
- EdgeRight aprovado e preservado;
- Launcher por clique, não hover puro;
- clique-fora/Esc para fechar;
- click-through funcionando;
- EdgeTop sem abertura acidental;
- máscaras/input regions estáveis.

**Critério de conclusão**
- launcher não some/volta sozinho;
- painéis não abrem acidentalmente;
- janelas atrás não entram em conflito.

### Fase 3 — Limpeza e componentização ✅ CONCLUÍDA

**Tarefas**
- revisar `components/`;
- criar componentes reutilizáveis se necessário;
- remover duplicação;
- padronizar animações;
- marcar `ScreenFrame` como obsoleto ou arquivado;
- limpar comentários.

**Critério de conclusão**
- código legível;
- módulos bem separados;
- nenhuma regressão visual.

**Resultado (2026-06-06): CONCLUÍDA**
- `Divider.qml` criado e aplicado em EdgeLeft e EdgeTop (pixel-idêntico);
- tokens de tipografia/glyph/dimensão adicionados ao `Theme.qml` (aditivos);
- tokens aplicados em `SliderPill`, `RingMeter` e `Dashboard` (valores idênticos);
- `NowPlaying` avaliado e **não extraído** (layouts EdgeTop≠Dashboard divergem →
  mudaria visual; decisão correta de não forçar a extração);
- `ScreenFrame.qml` marcado **DEPRECATED** (legado da moldura; não reativar/remover);
- `qmllint` limpo; visual praticamente idêntico; nenhum dado real.

### Fase 4 — Launcher funcional ✅ CONCLUÍDA FUNCIONALMENTE

**Tarefas**
- `TextInput` real;
- busca;
- navegação por teclado;
- lista de apps;
- executar apps;
- fechar após abrir app.

**Critério de conclusão**
- launcher usável no dia a dia;
- busca estável;
- foco de teclado funcionando.

**Critérios de ENTRADA (Fase 4)**
- Fases 0–3 concluídas (✅);
- visual P&B aprovado, EdgeRight congelado, Launcher estável por clique;
- `qmllint` limpo; trabalho direto na `main`.

**Resultado (2026-06-06): CONCLUÍDA FUNCIONALMENTE**
- Fonte de apps: `Quickshell DesktopEntries.applications`;
- query vazia mostra 4 favoritos: `Opera`, `Terminal`,
  `Visual Studio Code`, `Spotify`;
- busca real implementada;
- foco automático no campo de busca ao abrir;
- navegação por teclado com `Up`/`Down`;
- `Enter` executa o item selecionado;
- clique executa a linha;
- execução segura com `DesktopEntry.execute()`;
- fecha após executar;
- `Esc` e clique-fora preservados;
- `mask`, input region e grip preservados;
- sem `sh -c`, shell eval ou `execString` direto;
- ícones reais tentados, mas **adiados**; tiles usam letras por enquanto.

**Restrições da Fase 4 (mantidas durante a implementação)**
- não integrar dados reais além do necessário para **listar/abrir apps locais**;
- não mexer em Hyprland real;
- não mexer em EdgeRight;
- não mexer em boot/sistema/autostart;
- **preservar o visual e o comportamento aprovados do Launcher** (abre por clique,
  fecha por clique-fora/Esc; **não** voltar para hover puro).

### Fase 5 — Dados reais somente leitura ✅ CONCLUÍDA FUNCIONALMENTE

**Tarefas**
- hora/data reais; ✅
- bateria (UPower); ✅
- rede/SSID (Networking); ✅
- perfil de energia (PowerProfiles); ✅
- mídia/MPRIS; ✅
- OS/WM/uptime (FileView + env); ✅
- CPU/RAM/temp: ainda fake (sem serviço nativo; Fase futura).

**Resultado (2026-06-07): CONCLUÍDA FUNCIONALMENTE**
- `services/` criado com 5 singletons (`pragma Singleton`): `Clock`, `Battery`,
  `Media`, `Network`, `System`.
- `EdgeLeft`: relógio real, SSID real, perfil real; tooltip sem clip/flicker.
- `Dashboard`: hora/data/calendário reais, OS/WM/uptime reais, bateria real.
- `EdgeTop` aba Media: título/artista/álbum/progresso reais (MPRIS, read-only).
- `IconButton`: flicker fix (`hlClear`), tooltip grafite, elide para labels longos.
- Política: `FileView` + DBus read-only permitidos; execução externa/escrita proibidas.
- `qmllint` exit 0; working tree limpa.

**Pendências não-bloqueantes (carryover p/ Fase 6+)**
- Ícones reais no Launcher (Fase 4 carryover).
- SystemTray real (API disponível; adiado).
- Performance (CPU/GPU/mem/temp) — requer política dedicada.
- Media card no Dashboard (EdgeTop tem real; Dashboard ainda fake).

### Fase 6 — Integração Hyprland + reestruturação visual ✅ IMPLEMENTADA / EM VALIDAÇÃO VISUAL

**Tarefas**
- workspaces reais via módulo nativo do Hyprland; ✅
- workspace ativo; ✅
- dots de workspace no EdgeLeft; ✅
- aba Workspaces no EdgeTop; ✅
- janela ativa, classe ativa e monitores reais; ✅
- manter tudo somente leitura nesta fase; ✅

**Critério de conclusão**
- sidebar reflete o estado real do Hyprland; ✅
- EdgeTop expõe dados reais de workspaces/monitores/janela; ✅
- sem mexer em configs reais ainda; ✅
- validação visual final do usuário ainda pendente.

**Resultado (2026-06-07): IMPLEMENTADA EM MODO READ-ONLY**
- `services/Hyprland.qml` consolidado sobre `Quickshell.Hyprland`.
- `components/MarqueeText.qml` criado para overflow horizontal suave de títulos longos.
- `EdgeLeft`: agora também funciona como seletor de contexto do TopSheet.
- `TopSheet`: nova superfície superior com animação de descida e troca de páginas.
- `WorkspacesPage`: workspaces reais em cards resumidos.
- `MediaPage`: títulos/subtítulos longos protegidos por marquee e controles MPRIS reaproveitados.
- sem alteração em `~/.config/hypr` e sem controles mutáveis do compositor.

### Fase 7 — Consolidação da arquitetura nova ✅ CONCLUÍDA FUNCIONALMENTE (2026-06-09)

**Tarefas**
- validar visualmente multi-monitor da nova shell; ✅
- revisar densidade, altura e largura do TopSheet; ✅
- decidir se `EdgeTop` legado deve ser removida do repo ou preservada como referência; (carryover)
- decidir se `Launcher` legado pode ser arquivado depois da validação da `SearchPage`. (carryover)

**Resultado (2026-06-09)**
- Dashboard refinado (hero data/hora, janela ativa com chips, mídia em faixa);
- SearchPage virou launcher completo, acoplado à lupa, com teclado restaurado;
- abas do TopSheet coladas na sidebar, nascendo do botão que as abriu, com
  coreografia horizontal de troca e altura encaixada no conteúdo — **aprovado**;
- correção estrutural: `interactiveLeft = 0` (janela já desconta a exclusiveZone
  da EdgeLeft; o gap fantasma de 46px era coordenada somada em dobro);
- **carryover**: arquivamento formal do legado (EdgeTop/EdgeRight/Launcher)
  ainda não decidido.

**Critério de conclusão**
- TopSheet validado pelo usuário; ✅
- nenhuma duplicação visual remanescente; ✅
- legado claramente documentado. ✅ (decisão de remoção pendente)

### Fase 8 — Controles reais ✅ IMPLEMENTADA (2026-06-09) / EM VALIDAÇÃO NO RUNTIME

**Tarefas**
- volume; ✅ (Pipewire via `services/Audio.qml` — slider arrastável)
- mute; ✅ (clique no badge de % do slider)
- brilho; ❌ adiado — monitor externo exige DDC/ddcutil = `Process` (proibido
  sem autorização explícita; slider segue placeholder honesto)
- MPRIS/mídia; ✅ (já existia, preservado)
- rede/Bluetooth primeiro como status, depois ações se aprovado. ✅
  (Wi-Fi: toggle + scan + lista + conectar em rede salva; Bluetooth: toggle do
  adapter + conectar/desconectar pareados via `services/Bluez.qml`)

**Política aplicada**
- toda mutação **somente via API typed do Quickshell**, centralizada nos
  serviços; nenhuma senha/secret passa pela shell; nenhum `Process` novo.

**Critério de conclusão**
- sliders controlam o sistema com segurança; ⏳ implementado, **aguardando
  validação do usuário no runtime** (Bluetooth é o primeiro uso do módulo);
- nada quebra Waybar/HyDE. ✅ (sem processo externo, sem config tocada)

### Fase 9 — Tema dinâmico e personalização

**Tarefas**
- tema claro/escuro;
- tokens derivados do wallpaper;
- variações de estilo;
- configurações locais da shell.

**Critério de conclusão**
- tema consistente;
- personalização sem editar vários arquivos.

### Fase 10 — Performance e robustez

**Tarefas**
- medir CPU/RAM;
- revisar `MultiEffect`/sombras;
- reduzir polling;
- testar por horas;
- testar em 1 e 2 monitores.

**Critério de conclusão**
- shell estável para uso diário;
- sem flicker;
- sem travar input.

### Fase 10 — Uso diário manual

**Tarefas**
- usar via `qs -p`;
- testar por 1 dia;
- corrigir bugs;
- manter Waybar/HyDE intactos.

**Critério de conclusão**
- shell utilizável sem irritação;
- sem autostart ainda.

### Fase 11 — Deploy opcional

**Tarefas**
- decidir se substitui ou convive com a Waybar;
- script start/stop;
- autostart opcional só com autorização;
- rollback documentado.

**Critério de conclusão**
- inicia e fecha de forma previsível;
- rollback simples;
- sistema real preservado.

### Fase 12 — Projeto 100%

**Checklist**
- [ ] visual aprovado;
- [ ] sidebar final;
- [ ] EdgeTop estável;
- [ ] EdgeRight funcional;
- [ ] Launcher funcional;
- [ ] dados reais;
- [ ] workspaces reais;
- [ ] volume/brilho reais;
- [ ] mídia real;
- [ ] tema dinâmico;
- [ ] multi-monitor estável;
- [ ] performance boa;
- [ ] documentação atualizada;
- [ ] rollback;
- [ ] uso diário aprovado.

## 5. Ordem imediata recomendada

Fases 0–8 implementadas no código (Fase 8 aguardando validação). A partir do estado atual:

1. usuário valida a **ControlsPage no runtime**: toggle e lista de Wi-Fi,
   Bluetooth (ponto mais sensível — primeiro uso do módulo), volume/mute,
   alternância de perfil; corrigir o que estranhar;
2. decidir o caso do **brilho**: DDC/ddcutil = `Process` → exige conversa e
   autorização explícita antes de qualquer implementação;
3. **CPU/MEM/TMP reais na SystemPage** via `FileView /proc` (leitura, dentro da
   política vigente);
4. carryovers: SystemTray real, ícones reais no launcher, decisão de
   arquivamento do legado (EdgeTop/EdgeRight/Launcher);
5. seguir sem alterar `~/.config/hypr` nem configs Hyprland reais.

## 6. Commits sugeridos por tipo

- `docs: adicionar roadmap do projeto`
- `style: refinar visual da shell`
- `fix: estabilizar launcher com abertura por clique`
- `refactor: organizar componentes da shell`
- `feat: adicionar busca funcional ao launcher`
- `feat: adicionar dados reais somente leitura`
- `feat: integrar workspaces do Hyprland`
- `chore: preparar deploy opcional da shell`

## 7. Não fazer agora

- não reativar legado (`ScreenFrame` DEPRECATED, EdgeTop/EdgeRight/Launcher antigos);
- não regredir dados reais para fake nem o visual aprovado das abas acopladas;
- não voltar a somar `Theme.barW` nas coordenadas do TopSheet (`interactiveLeft = 0`);
- não usar fundo translúcido (`Theme.bar`) no painel — fantasma sobre janelas;
- não implementar **brilho** sem conversa/autorização (exigiria `Process`/DDC);
- não adicionar mutação fora dos serviços typed de `services/` (política 2026-06-09);
- não parear/esquecer dispositivos Bluetooth nem gravar credenciais pela shell;
- não colar glyphs PUA crus em arquivos (somem) — gravar via Python `chr()` + validar com hexdump;
- não alterar `~/.config/hypr` nem configs Hyprland reais;
- não criar autostart nem fazer deploy por enquanto;
- não substituir a Waybar;
- não mexer no sistema real (HyDE/SDDM/boot/systemd/login/bateria/PAM);
- não usar execução externa/comandos externos sem autorização explícita;
- não fazer push sem autorização;
- não commitar bug como feature aprovada.
