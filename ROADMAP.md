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
- **puxadores/painéis minimalistas** no topo, na direita e na base;
- **sem moldura contínua** em volta da tela (o `ScreenFrame` fica inativo);
- projeto ainda **isolado do sistema real**;
- **dados fake/stub** até a base visual e interativa ficar estável e aprovada.

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

## 3. Estado atual resumido (atualizado 2026-06-07 — Fase 6 implementada em código)

- trabalho direto na **`main`** (linha oficial; sem branches);
- `shell.qml` monta **EdgeLeft**, **EdgeTop**, **EdgeRight** e **Launcher** por tela;
- o projeto roda via **`qs -p`** (entrypoint isolado, não substitui nada do sistema);
- **`ScreenFrame` está inativo** e marcado **DEPRECATED** (não importado, não remover);
- **multi-monitor ativo** — uma instância de cada borda em todos os monitores;
- **visual P&B/grafite aprovado** (tema claro monocromático);
- **EdgeRight aprovado e congelado** — não mexer;
- **Launcher aprovado e estável** — abre por clique no puxador, fecha por
  clique-fora/Esc, com hardening contra clique invisível (`enabled: !root.open`);
- **Launcher funcional concluído** — usa apps reais via `DesktopEntries`,
  mostra 4 favoritos com query vazia, busca apps locais, aceita foco imediato no
  campo de busca, navega por `Up`/`Down`, executa por clique/`Enter` com
  `DesktopEntry.execute()` e fecha após executar;
- **EdgeTop** mantém o anti-hover-acidental (delay + faixa de gatilho estreita);
- **Fase 3 concluída**: `Divider.qml` criado e aplicado, tokens de
  tipografia/glyph/dimensão no `Theme.qml`, `ScreenFrame` DEPRECATED.
- **Fase 4 concluída funcionalmente**; ícones reais no Launcher como melhoria futura.
- **Fase 5 concluída funcionalmente**: dados reais somente leitura integrados via
  `services/` (Clock, Battery, Media, Network, System); `IconButton` sem flicker;
  tooltips corrigidos (clip + elide). Ainda fake: CPU/GPU e SystemTray.
- **Fase 6 implementada em modo read-only**: `services/Hyprland.qml`, workspaces
  reais por tela no EdgeLeft, janela ativa real, monitor real por tela e aba
  Workspaces da EdgeTop com dados reais de workspaces/monitores.
- **Refino visual da Fase 6 aplicado**: `MarqueeText.qml` para títulos longos
  de mídia, cards de workspace mais compactos e menos informação técnica na
  `EdgeLeft` e na aba Workspaces da `EdgeTop`.
- **estado atual da Fase 6**: pronta para validação visual do usuário; nenhuma
  ação mutável liberada.

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

### Fase 6 — Integração Hyprland ✅ IMPLEMENTADA NO CÓDIGO / EM VALIDAÇÃO VISUAL

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
- `EdgeLeft`: workspaces reais por tela, estados visuais, resumo de workspace na tela e resumo da janela ativa.
- `EdgeTop`: aba Workspaces com workspaces reais em cards resumidos; aba Media com títulos/subtítulos longos protegidos por marquee.
- sem alteração em `~/.config/hypr` e sem controles mutáveis do compositor.

### Fase 7 — Controles reais

**Tarefas**
- volume;
- mute;
- brilho;
- MPRIS/mídia;
- rede/Bluetooth primeiro como status, depois ações se aprovado.

**Critério de conclusão**
- sliders controlam o sistema com segurança;
- nada quebra Waybar/HyDE.

### Fase 8 — Tema dinâmico e personalização

**Tarefas**
- tema claro/escuro;
- tokens derivados do wallpaper;
- variações de estilo;
- configurações locais da shell.

**Critério de conclusão**
- tema consistente;
- personalização sem editar vários arquivos.

### Fase 9 — Performance e robustez

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

Fases 0–6 implementadas no código. A partir do estado atual:

1. validar visualmente a Fase 6 com troca de workspace, foco, multi-monitor e textos longos de mídia;
2. corrigir qualquer ajuste fino visual, de marquee ou de fallback encontrado nessa validação;
3. só depois disso discutir a Fase 7, com ações reais atrás de autorização explícita;
4. seguir sem alterar `~/.config/hypr` nem configs Hyprland reais.

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

- não mexer no EdgeRight (aprovado/congelado);
- não reativar o `ScreenFrame` (DEPRECATED);
- não regredir dados reais da Fase 5 para fake;
- não implementar controles reais (MPRIS play/pause, volume, brilho) ainda;
- não alterar `~/.config/hypr` nem configs Hyprland reais;
- não criar autostart nem fazer deploy por enquanto;
- não substituir a Waybar;
- não mexer no sistema real (HyDE/SDDM/boot/systemd/login/bateria/PAM);
- não usar execução externa/comandos externos sem autorização explícita;
- não fazer push sem autorização;
- não commitar bug como feature aprovada.
