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

## 3. Estado atual resumido

- `shell.qml` monta **EdgeLeft**, **EdgeTop**, **EdgeRight** e **Launcher** por tela;
- o projeto roda via **`qs -p`** (entrypoint isolado, não substitui nada do sistema);
- **`ScreenFrame` está inativo** (não é importado no `shell.qml`);
- todos os **dados são fake/stub**;
- **multi-monitor ativo** — uma instância de cada borda em todos os monitores;
- **EdgeRight aprovado** — não mexer sem necessidade;
- **Launcher em correção arquitetural** — saindo de hover puro para abertura por
  clique no puxador + fechar com clique-fora/Esc;
- **visual da sidebar em refinamento** (polimento de cor, raio, sombra, espaçamento).

## 4. Roadmap por fases

### Fase 0 — Base segura e versionamento

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

### Fase 1 — Identidade visual da shell

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

### Fase 2 — UX e interação estável

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

### Fase 3 — Limpeza e componentização

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

### Fase 4 — Launcher funcional

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

### Fase 5 — Dados reais somente leitura

**Tarefas**
- hora/data reais;
- bateria;
- CPU/RAM;
- temperatura se disponível;
- nome real do monitor;
- dados read-only em `services/`.

**Critério de conclusão**
- dados reais sem escrever no sistema;
- sem travamentos;
- sem polling pesado.

### Fase 6 — Integração Hyprland

**Tarefas**
- workspaces reais;
- workspace ativo;
- janelas/foco;
- ações pequenas e seguras via IPC.

**Critério de conclusão**
- sidebar reflete o estado real do Hyprland;
- sem mexer em configs reais ainda.

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

A partir do estado atual:

1. terminar o refinamento visual atual;
2. estabilizar o Launcher;
3. commitar a Leva D aprovada;
4. continuar sidebar/puxadores;
5. componentizar;
6. só depois iniciar dados reais.

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

- não mexer no EdgeRight se aprovado;
- não reativar o `ScreenFrame`;
- não integrar dados reais durante a Leva D;
- não criar autostart;
- não substituir a Waybar;
- não mexer no sistema real;
- não fazer push sem autorização;
- não commitar bug como feature aprovada.
