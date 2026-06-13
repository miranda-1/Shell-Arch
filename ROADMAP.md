# ROADMAP — Shell Visual Quickshell

> Documento permanente de direção do projeto. Mapa para não nos perdermos.
> Atualize sempre que uma etapa mudar de estado ou a direção for revista.
> **Reescrito em 2026-06-13** com foco no caminho até o **uso diário definitivo**
> (substituindo a Waybar). O histórico detalhado das Fases 0–8 está compactado na
> seção 8; a seção 4 agora descreve o **caminho restante**.

## 1. Visão do projeto

Construir uma **shell visual própria** em Quickshell/QML para **Arch + Hyprland + HyDE**.
Objetivo final: shell **premium, estável, funcional e segura** para uso diário —
bonita o suficiente para substituir a barra atual, estável o suficiente para
rodar o dia todo sem irritação, segura o suficiente para **conviver com o
sistema real sem quebrá-lo**.

Direção aprovada:
- **sidebar esquerda premium** (`EdgeLeft`) como peça principal e seletor de contexto;
- **TopSheet contextual** (8 páginas) como superfície de conteúdo;
- **sem moldura contínua** (`ScreenFrame` DEPRECATED/inativo);
- dados reais **somente** via serviços typed seguros em `services/`.

## 2. Decisões de produto (tomadas em 2026-06-13)

Estas decisões guiam o caminho restante e **superam** dúvidas anteriores:

- **Destino da Waybar:** **SUBSTITUIR DE VEZ.** O deploy final desliga a Waybar do
  HyDE e coloca a shell em autostart. Como isso mexe em `~/.config/hyde` /
  `~/.config/hypr`, **exige autorização explícita no momento + rollback testado
  ANTES**. (Etapa Deploy.)
- **SystemTray:** **ESSENCIAL / BLOQUEANTE.** A shell não vira daily-driver sem
  tray real (apps em background: VPN, Telegram, etc.). (Etapa T.)
- **Brilho:** **somente a tela interna do notebook** (via sysfs/backlight). Monitor
  externo (que exigiria `ddcutil`/DDC = `Process` pesado) **fica de fora**. (Etapa B.)

## 3. Regras permanentes de segurança

Valem para **todas as etapas**, salvo autorização explícita em contrário:

- **não mexer fora de `~/Projetos/ui-shell-prototype/`** sem autorização explícita;
- **não mexer em HyDE / Waybar / Hyprland / SDDM / boot / Secure Boot / systemd /
  autostart / login / bateria / PAM** durante as etapas de desenvolvimento — só na
  Etapa Deploy, e só com autorização explícita no momento;
- **mutação do sistema apenas via API typed do Quickshell**, centralizada em
  `services/` (política de 2026-06-09); `Process`/comando externo **proibido** sem
  autorização explícita (exceção candidata: brilho interno — ver Etapa B);
- leitura via `FileView` + DBus typed: permitida;
- não parear/esquecer dispositivos BT nem gravar credenciais pela shell;
- glyphs PUA Nerd Font **somem** no Write/Edit — gravar via script Python (`chr()`)
  e validar com `iconv -t UTF-32LE | xxd`;
- git sempre limpo antes de mudanças grandes; commits pequenos e focados;
- **o usuário (Miranda) é quem commita** — a IA deixa a working tree pronta e
  **nunca** dá push nem cria branch;
- **só o usuário roda `qs -p`** (a IA não executa a shell; ela desenha layers na
  tela dele). A IA valida com `qmllint`.

## 4. Caminho até o uso diário (etapas restantes)

> Fases 0–8 implementadas no código (ver seção 8). O que falta para o uso
> definitivo está abaixo, **na ordem recomendada**. Legenda: 🔴 bloqueante para
> daily-driver · 🟡 desejável/qualidade.

### Etapa V — Validação no runtime 🔴 **(PORTÃO — fazer primeiro)**

Nada abaixo deve avançar antes disto. **Nenhuma das funções da Fase 8 foi testada
rodando ao vivo.**

**Tarefas**
- usuário roda `qs -p ~/Projetos/ui-shell-prototype/shell.qml`;
- validar abertura/troca/fechamento das 8 páginas do TopSheet;
- validar **ControlsPage ao vivo** (ponto mais sensível):
  - Wi-Fi: toggle, scan, lista, conectar em rede salva;
  - **Bluetooth: toggle do adapter + conectar/desconectar pareados** (primeiro uso
    real do módulo `Quickshell.Bluetooth` — risco maior);
  - volume/mute (Pipewire); alternância de perfil de energia;
- validar multi-monitor (eDP-1 + HDMI-A-1) e **click-through** do desktop;
- anotar bugs; a IA corrige; revalidar.

**Critério de conclusão**
- tudo funciona ao vivo sem crash; controles agem no sistema com segurança;
- usuário aprova o comportamento real da ControlsPage.

### Etapa T — SystemTray real 🔴 **(decisão: essencial)**

**Tarefas**
- consumir `Quickshell.Services.SystemTray` (`StatusNotifierItem`);
- `Repeater` + `Image` delegate para os ícones dos apps em background;
- definir **onde mora** o tray (provável: base da `EdgeLeft` ou uma faixa própria);
- política sobre `activate`/menu de contexto (esquerda = activate, direita = menu);
- elide/overflow se houver muitos ícones.

**Critério de conclusão**
- ícones reais de apps em background aparecem e respondem a clique;
- menu de contexto funciona com segurança (sem spawn externo arbitrário).

### Etapa M — Métricas reais (CPU/MEM/temp) 🟡

**Tarefas**
- `FileView /proc/stat` (delta de CPU), `/proc/meminfo`, `/sys/class/hwmon/.../temp`;
- novo serviço typed (ex.: `services/Stats.qml`) com polling controlado;
- preencher a **SystemPage** (hoje fake) com valores reais.

**Critério de conclusão**
- CPU/MEM/temperatura reais na SystemPage; polling sem custo perceptível
  (refinar na Etapa P).

### Etapa B — Brilho interno 🟡 **(decisão: só tela interna)**

**Tarefas**
- controlar **só a tela do notebook** via backlight (`/sys/class/backlight/...`);
- resolver a forma de escrita dentro da política: idealmente escrita typed/sysfs
  sem `Process`; se inevitável, propor **exceção mínima** (`brightnessctl`) só para
  brilho interno, encapsulada num serviço, **com autorização explícita**;
- monitor externo **continua placeholder honesto** (sem ddcutil).

**Critério de conclusão**
- slider de brilho controla a tela interna de verdade;
- monitor externo segue claramente marcado como não-controlável.

### Etapa P — Performance e robustez 🔴

**Tarefas**
- **soak test:** deixar rodando **horas** nos 2 monitores; observar vazamento de
  memória, flicker, travamento de input, custo de CPU/GPU a 240Hz;
- revisar `MultiEffect`/sombras e **reduzir polling** (Clock evented já; checar
  Stats/Media/uptime);
- garantir que fechar/reabrir a shell não deixa estado preso.

**Critério de conclusão**
- estável por um dia inteiro de uso real, sem flicker nem regressão de input;
- consumo aceitável.

### Etapa Deploy — Substituir a Waybar 🔴 **(decisão: substituir de vez)**

> **Única etapa que toca o sistema real. Só com autorização explícita no momento
> e rollback testado ANTES de qualquer alteração.**

**Tarefas**
- script `start`/`stop` da shell (e `qs kill` documentado);
- **rollback documentado e testado primeiro** (como religar a Waybar em 1 comando);
- autostart via `exec-once` do Hyprland (**mexe em `~/.config/hypr`** → autorização);
- **desligar a Waybar do HyDE** (**mexe em `~/.config/hyde`** → autorização);
- período de convivência opcional (shell + Waybar) antes do corte, se o usuário
  quiser segurança extra mesmo tendo escolhido "substituir".

**Critério de conclusão**
- shell inicia com a sessão de forma previsível;
- Waybar desligada sem quebrar o HyDE;
- rollback simples e comprovado;
- sistema real preservado fora do que foi explicitamente autorizado.

### Etapa Tema — Tema dinâmico (pós-deploy, opcional) 🟡

- tema claro/escuro; tokens derivados do wallpaper; variações; config local da shell.

## 5. Ordem imediata recomendada

1. **Etapa V** — você roda e validamos tudo ao vivo (em especial Bluetooth). 🔴
2. **Etapa T** — SystemTray real. 🔴
3. **Etapas M e B** em paralelo — métricas reais + brilho interno. 🟡
4. **Etapa P** — soak test / performance. 🔴
5. **Etapa Deploy** — substituir a Waybar (autorização + rollback testado). 🔴
6. **Etapa Tema** — quando quiser. 🟡

## 6. Checklist "projeto 100% / daily-driver"

- [x] visual aprovado (P&B/grafite)
- [x] sidebar final (EdgeLeft)
- [x] TopSheet estável (abas acopladas)
- [x] Launcher funcional
- [x] dados reais read-only (hora/bateria/rede/mídia/OS/uptime)
- [x] workspaces reais
- [x] volume/mídia reais
- [x] Wi-Fi/Bluetooth/perfil reais (implementados)
- [ ] **controles validados ao vivo** (Etapa V)
- [ ] **SystemTray real** (Etapa T)
- [ ] CPU/MEM/temp reais (Etapa M)
- [ ] brilho interno real (Etapa B)
- [ ] multi-monitor estável + soak test (Etapa P)
- [ ] autostart + Waybar substituída + rollback (Etapa Deploy)
- [ ] tema dinâmico (opcional)

## 7. Não fazer

- não reativar legado (`ScreenFrame` DEPRECATED; EdgeTop/EdgeRight/Launcher antigos);
- não regredir dados reais para fake nem o visual aprovado das abas acopladas;
- não somar `Theme.barW` nas coordenadas do TopSheet (`interactiveLeft = 0`);
- não usar fundo translúcido (`Theme.bar`) no painel — vaza janelas ("fantasma");
- não adicionar mutação fora dos serviços typed de `services/`;
- não usar `ddcutil`/DDC para brilho externo (decisão 2026-06-13);
- **não tocar `~/.config/hypr` / `~/.config/hyde` / Waybar fora da Etapa Deploy** —
  e mesmo lá, só com autorização explícita no momento e rollback pronto;
- não criar autostart antes da Etapa Deploy;
- não commitar (working tree fica para o Miranda); nunca dar push nem criar branch;
- a IA não roda `qs -p` — só `qmllint`.

## 8. Histórico das fases concluídas (registro compacto)

- **Fase 0 — Base/versionamento ✅** git local+remoto, `main`, docs.
- **Fase 1 — Identidade visual ✅** sidebar premium; sem moldura; tema P&B/grafite.
- **Fase 2 — UX/interação ✅** abertura por clique, Esc/clique-fora, click-through,
  máscaras estáveis.
- **Fase 3 — Componentização ✅** `Divider.qml`; tokens aditivos no `Theme.qml`;
  `ScreenFrame` DEPRECATED.
- **Fase 4 — Launcher funcional ✅** `DesktopEntries` + `DesktopEntry.execute()`,
  busca, foco, ↑/↓, Enter; ícones reais adiados (tiles com letra).
- **Fase 5 — Dados reais read-only ✅** `services/` com singletons Clock, Battery,
  Media, Network, System (FileView + DBus typed).
- **Fase 6 — Hyprland read-only ✅** `services/Hyprland.qml`; workspaces/janela/
  monitor reais; `MarqueeText.qml`.
- **Fase 7 — Consolidação ✅** TopSheet com abas acopladas à sidebar (nascem do
  botão, slide horizontal, altura encaixa no conteúdo); SearchPage = launcher
  completo; **descoberta crítica `interactiveLeft = 0`** (janela já desconta a
  exclusiveZone — nunca somar `Theme.barW`).
- **Fase 8 — Controles reais ✅ implementada / ❌ não validada ao vivo** volume/mute
  (`Audio.qml`), Wi-Fi toggle+scan+conectar-rede-salva (`Network.qml`), Bluetooth
  toggle+pareados (`Bluez.qml`), perfil de energia (`Battery.cycleProfile()`).
  Brilho = placeholder. **Validação no runtime é a Etapa V acima.**

## 9. Comandos de retomada

```sh
cd ~/Projetos/ui-shell-prototype/
git log --oneline -5
git status
qmllint shell.qml modules/TopSheet/TopSheet.qml modules/TopSheet/pages/*.qml services/*.qml
qs -p ~/Projetos/ui-shell-prototype/shell.qml   # SÓ o usuário roda — fechar com Ctrl+C ou `qs kill`
```
