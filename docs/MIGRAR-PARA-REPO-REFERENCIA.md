# MIGRAR PARA O REPO DE REFERÊNCIA (caelestia-shell)

> Documento de planejamento da mudança de direção: usar o **caelestia-shell**
> como base real e customizar em cima dele, preservando o protótipo
> (`~/Projetos/ui-shell-prototype/`) como referência visual.
>
> **Estado (2026-06-04):** Opção A **validada e funcionando**. Dependências
> instaladas (incl. `quickshell-git` substituindo o `quickshell` 0.3.0,
> `caelestia-cli`, `libcava`, `app2unit`). Plugin C++ compilado localmente em
> `build/`. `qs -p shell.qml` carrega (`Configuration Loaded`, sem erro fatal),
> coexistindo com a Waybar/HyDE. **Nada instalado em `/usr`; hypr/hyde/waybar
> intactos.** Pendências: fonte Material Symbols (ícones) e tema de cor rosé/ink.

### Como rodar (Opção A — comando validado)

```sh
cd ~/Projetos/referencias/caelestia-shell
export CAELESTIA_LIB_DIR="$PWD/build/lib"
export QML2_IMPORT_PATH="$PWD/build/qml:${QML2_IMPORT_PATH:-}"
qs -p shell.qml          # fechar: Ctrl+C ou `qs kill`
```

> Build configurado com `-DVERSION=1.0.0 -DGIT_REVISION=$(git rev-parse HEAD)`
> porque o clone não tem tags (o `git describe` do CMakeLists falha sem isso).

### Pendências conhecidas

1. **Fonte Material Symbols** ausente → ícones viram quadradinhos. Nome AUR
   `otf-material-symbols` não existe; achar o pacote correto (provável
   `ttf-material-symbols-variable-git` ou similar).
2. **Tema rosé/ink**: `~/.local/state/caelestia/scheme.json` não existe →
   nenhum esquema. Definir via `caelestia scheme` + mapear paleta do protótipo.
3. **Wallpaper**: `~/Pictures/Wallpapers` não existe (seletor fica vazio).

---

## 1. O que é o repositório

- **Pasta:** `~/Projetos/referencias/caelestia-shell`
- **Projeto:** `caelestia-shell` (o shell de desktop dos *caelestia dots*)
- **Origem git:** `https://github.com/caelestia-dots/shell` — branch `main`,
  HEAD `63bb827`. Clone limpo, sem alterações locais.
- **Stack:** Quickshell (QML/Qt Quick 6) + um **plugin C++** próprio (módulo QML
  `Caelestia`, compilado via CMake/Ninja) + detector de batida (lib nativa).
- **WM alvo:** Hyprland.
- **Entrypoint:** `shell.qml` (raiz `ShellRoot`). Roda via `qs -c caelestia`
  ou `caelestia shell -d`.
- **Licença:** presente (LICENSE).

### Estrutura (alto nível)

```
shell.qml          entrypoint
modules/           bar, sidebar, drawers, launcher, dashboard, controlcenter,
                   notifications, osd, session, lock, background, areapicker,
                   utilities, windowinfo
services/          Colours, Audio, Network, Hypr, Players, Weather, Time, ...
components/        widgets, controls, effects, containers (biblioteca interna)
utils/             Paths, Icons, Images, Searcher, ...
plugin/src/        C++ -> módulo QML `Caelestia` (Config, Services, Models, ...)
extras/            executável `version`
assets/            logo, shaders, gifs, pam.d (config PAM PRÓPRIA do lock)
CMakeLists.txt     build/instalação
flake.nix/.envrc   build Nix + workflow de dev (direnv)
```

### Mapa módulo do repo → desejo do protótipo

| Quero (protótipo)            | Já existe no caelestia            |
|------------------------------|-----------------------------------|
| sidebar esquerda integrada   | `modules/bar` + `modules/sidebar` |
| drawers                      | `modules/drawers`                 |
| launcher                     | `modules/launcher`                |
| dashboard                    | `modules/dashboard`               |
| controles laterais escondidos| `modules/controlcenter`, `osd`    |
| moldura/borda viva           | `modules/background` + drawers    |
| translúcido/arredondado      | `appearance.transparency`, `rounding` no `shell.json` |

Conclusão: **tudo que validamos no protótipo já existe no caelestia**, maduro e
muito mais completo. O trabalho passa a ser de **tematização e ajuste**, não de
construção.

---

## 2. O que uma instalação alteraria

### Dependências necessárias (ainda NÃO instaladas)

- **`quickshell-git`** — o README exige a versão **git**, não a tagged.
  ⚠️ O sistema tem `quickshell` **0.3.0 (pacote Arch)**, não o git. Risco real
  de incompatibilidade de API/QML no build ou em runtime.
- **`caelestia-cli`** — **ausente**. Necessária para troca de tema
  (`caelestia scheme set`), wallpaper e IPC. Sem ela o shell abre mas com
  funções degradadas (inclusive a troca de tema rosé/ink que queremos).
- Runtime: `ddcutil`, `brightnessctl`, `app2unit`, `libcava`, `aubio`,
  `libpipewire`, `networkmanager`, `lm-sensors`, `fish`, `libqalculate`,
  `swappy`, `material-symbols`, `caskaydia-cove-nerd`, `qt6-base/declarative`.
- Build: `cmake`, `ninja` (presentes), e um compilador C++ (gcc presente).

### Onde o `cmake --install` escreve (instalação manual padrão)

Lendo `CMakeLists.txt`:

- QML + assets do shell → **`/etc/xdg/quickshell/caelestia`** (`INSTALL_QSCONFDIR`)
- plugin C++ compilado → **`/usr/lib/qt6/qml`** (`INSTALL_QMLDIR`) — system-wide
- libs nativas (beat detector, `version`) → **`/usr/lib/caelestia`** (`INSTALL_LIBDIR`)
- Tudo isso exige **sudo**.

A AUR (`caelestia-shell`) instala nas mesmas localizações de sistema.

### O que NÃO é tocado pela instalação

- ❌ **NÃO** escreve em `~/.config/hypr`, `~/.config/hyde`, `~/.config/waybar`.
- ❌ **NÃO** modifica o PAM do sistema (`/etc/pam.d`). O módulo de lock usa uma
  config PAM **própria e embutida** em `assets/pam.d` (via
  `PamContext.configDirectory = shellDir + "/assets/pam.d"`). Mesmo assim, há um
  `Lock {}` ativo no `shell.qml` — fica ocioso até ser acionado, mas existe.
- ❌ **NÃO** cria serviço systemd nem autostart por si só. O autostart só
  acontece se *você* adicionar um `exec-once` no Hyprland (não faremos isso).
- ❌ Não mexe em SDDM, boot, Windows, Secure Boot.

### O que o shell lê/escreve em runtime (config do usuário)

- Lê config em **`~/.config/caelestia/shell.json`** (você cria; hoje **ausente**).
- Usa dirs XDG próprios: `~/.local/share/caelestia`, `~/.local/state/caelestia`,
  `~/.cache/caelestia`.
- PFP do dashboard: `~/.face`. Wallpapers: `~/Pictures/Wallpapers`.

### Estado atual do sistema (verificado)

- `~/.config/quickshell` → **ausente** (nada a sobrescrever)
- `~/.config/caelestia` → **ausente**
- `~/.config/hypr`, `~/.config/hyde`, `~/.config/waybar` → **existem** (intocáveis)

---

## 3. Modo seguro de rodar sem instalar

**Importante:** o shell **não roda** com um simples `qs -p shell.qml`, porque
quase todo arquivo faz `import Caelestia` / `Caelestia.Config` (o plugin C++).
É preciso **compilar o plugin** primeiro. O `.envrc` mostra exatamente o
workflow de dev seguro (não toca em `/usr`, não usa sudo):

```sh
cd ~/Projetos/referencias/caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDISTRIBUTOR=local
cmake --build build
export CAELESTIA_LIB_DIR="$PWD/build/lib"
export QML2_IMPORT_PATH="$PWD/build/qml:${QML2_IMPORT_PATH:-}"
qs -p shell.qml         # roda da árvore local, sem instalar nada
```

- Sem `sudo`, sem escrita em `/usr` ou `/etc`.
- Coexiste com a Waybar/HyDE atual (são layer-shell sobrepostos), como já fazia
  o protótipo.
- Fechar: `Ctrl+C` no terminal ou `qs kill`.
- ⚠️ Pré-condição: o build precisa de `quickshell-git` + libs (`aubio`, `cava`,
  `libqalculate`, `pipewire`) instaladas, senão o `cmake --build` falha.

---

## 4. Plano de backup (antes de qualquer escrita)

Mesmo no caminho local não há o que sobrescrever, mas como rede de segurança
antes de **qualquer** passo que escreva em config:

```sh
mkdir -p ~/Backups/shell-migracao/$(date +%F)
cd ~/Backups/shell-migracao/$(date +%F)
for d in quickshell caelestia hypr hyde waybar; do
  [ -e ~/.config/$d ] && cp -a ~/.config/$d ./$d.bak
done
# snapshot da lista de pacotes, para rollback de dependências
pacman -Qqe > pkgs-explicit.txt
```

- **O que salvar:** `~/.config/{quickshell,caelestia,hypr,hyde,waybar}` (os que
  existirem) + lista de pacotes explícitos.
- **Onde:** `~/Backups/shell-migracao/<data>/`.
- **Restaurar:** `cp -a ~/Backups/.../<d>.bak ~/.config/<d>` (após remover o
  diretório atual).

---

## 5. Plano de rollback

- **Rodando local (Opção A):** nada a desfazer — basta `qs kill` e apagar a
  pasta `build/`. Zero pegada no sistema.
- **Instalação manual (`sudo cmake --install`):** desinstalar removendo os
  arquivos copiados para `/etc/xdg/quickshell/caelestia`, `/usr/lib/caelestia`
  e o módulo em `/usr/lib/qt6/qml/Caelestia*`. (CMake não gera `uninstall`
  automático — guardar a lista `build/install_manifest.txt` para apagar
  exatamente o que foi instalado.)
- **AUR:** `yay -R caelestia-shell` (e dependências órfãs com `-Rns` se desejado).
- **Config do usuário:** apagar `~/.config/caelestia` e os dirs
  `~/.local/share|state/.cache/caelestia`. Restaurar backups da seção 4.
- **Hyprland:** como **não** adicionaremos `exec-once`, não há autostart a
  remover.

---

## 6. Comparação com o protótipo

### O que o caelestia já tem (e é melhor)

- Conjunto completo e maduro: bar, sidebar, drawers, launcher, dashboard,
  control center, notificações, OSD, lock, area picker, recorder, weather,
  mpris/lyrics, network/bluetooth/vpn.
- Sistema de cores Material 3 reativo ao wallpaper (`services/Colours.qml`),
  com modo claro/escuro e schemes via CLI.
- Configuração externa em `shell.json` (transparência, rounding, spacing,
  fontes, padding) — dá pra ajustar muito **sem editar QML**.
- Plugin C++ para coisas que QML puro não faz (cálculo, análise de imagem,
  beat detection, app db).

### O que o protótipo tem que queremos preservar

- **Linguagem visual validada** (em `config/Theme.qml`): tema claro
  **rosé/ink**, acento terracota `#b0604a`, superfícies creme translúcidas,
  cantos arredondados (radius 18), **moldura viva fina** (`frameLine: 2`),
  barra esquerda estreita (`barW: 46`), grip central, timings de animação.
- O conceito de **hover-reveal nas bordas** (compacto em repouso, expande no
  hover).
- Os componentes de referência (`Card`, `Pill`, `RingMeter`, `SliderPill`,
  `ScreenFrame`) como guia de *look & feel*.

### Customizações necessárias no caelestia

1. **Tema rosé/ink claro:** criar/ajustar um *scheme* claro com a paleta do
   protótipo (mapear os tokens do `Theme.qml` para as cores M3 que o
   `Colours.qml` consome). Provável via `caelestia scheme` + arquivo de scheme.
2. **Transparência/rounding:** ativar `appearance.transparency` e subir
   `rounding`/`spacing` no `shell.json` para o visual orgânico/translúcido.
3. **Moldura viva fina:** ajustar `modules/background` / drawers para a borda
   contínua fina (estilo `ScreenFrame` do protótipo).
4. **Sidebar/bar:** estreitar a bar e integrar à moldura; controles laterais
   ocultos em repouso (já há base em `controlcenter`/`osd`).
5. **Fontes:** o caelestia usa Rubik + CaskaydiaCove NF; o protótipo usa
   JetBrainsMono NF. Decidir e setar em `appearance.font`.

---

## 7. Plano recomendado (3 opções)

### Opção A — Rodar localmente sem instalar  ✅ recomendada para começar

- Compilar o plugin na árvore (`build/`), exportar `CAELESTIA_LIB_DIR` +
  `QML2_IMPORT_PATH`, rodar `qs -p shell.qml`.
- **Riscos:** baixos. Precisa de `quickshell-git` + libs de build; pode falhar
  no build (não quebra o sistema). Zero escrita em `/usr`, `/etc` ou configs.
- **Pegada:** só a pasta `build/` dentro do repo de referência.

### Opção C — Fork/cópia custom em `~/Projetos/` apontando o Quickshell pra ela  ✅ recomendada para customizar

- Copiar o repo para `~/Projetos/caelestia-custom/` (preservando o original em
  `referencias/` como espelho upstream intocado), versionar como fork, compilar
  o plugin localmente e rodar via `qs -p`. Customizações ficam isoladas e
  versionadas, fáceis de comparar com upstream (`git diff`).
- **Riscos:** baixos, iguais à Opção A, mais a disciplina de manter o fork.
- É a evolução natural da Opção A quando começarmos a editar QML.

### Opção B — Instalar em `/usr` + `~/.config/quickshell/caelestia`

- Instalação "de verdade" (manual via cmake, ou AUR). Plugin vai para `/usr`,
  config editável em `~/.config/quickshell/caelestia`.
- **Riscos:** médios. Usa **sudo**, escreve em `/etc` e `/usr`; depende de
  `quickshell-git` (conflito potencial com o `quickshell` 0.3.0 atual do Arch).
  Rollback mais trabalhoso (manifesto de instalação / remoção de pacote).
- **Recomendação:** só depois de A/C estarem estáveis e o tema pronto.

**Caminho mais seguro:** começar na **Opção A** (validar que builda e roda com a
stack atual), e migrar para a **Opção C** assim que formos editar/tematizar.
Deixar a Opção B (ou AUR) para o final, como "promoção" do resultado.

---

## 8. Comandos que pretendo executar DEPOIS (NÃO executar ainda)

> Aguardando aprovação explícita. Listados aqui só para revisão.

```sh
# (0) Backup preventivo
mkdir -p ~/Backups/shell-migracao/$(date +%F) && cd $_
for d in quickshell caelestia hypr hyde waybar; do [ -e ~/.config/$d ] && cp -a ~/.config/$d ./$d.bak; done
pacman -Qqe > pkgs-explicit.txt

# (1) Conferir/instalar dependências (precisa decisão sobre quickshell-git vs 0.3.0)
#     -> via yay: quickshell-git caelestia-cli aubio libqalculate ddcutil
#        brightnessctl app2unit cava lm_sensors swappy app2unit ...
#     (NÃO rodar sem revisar conflito com o pacote 'quickshell' atual)

# (2) Build local do plugin (Opção A) — sem sudo, sem tocar /usr
cd ~/Projetos/referencias/caelestia-shell
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo -DDISTRIBUTOR=local
cmake --build build

# (3) Rodar da árvore local
export CAELESTIA_LIB_DIR="$PWD/build/lib"
export QML2_IMPORT_PATH="$PWD/build/qml:${QML2_IMPORT_PATH:-}"
qs -p shell.qml          # fechar com Ctrl+C ou `qs kill`

# (4) Quando for customizar (Opção C): fork local
cp -a ~/Projetos/referencias/caelestia-shell ~/Projetos/caelestia-custom
# ... versionar e editar lá, repetir (2)/(3) dentro do fork
```

---

## 9. Pendências / decisões para o usuário

1. **quickshell-git vs quickshell 0.3.0:** o README exige a versão git. Trocar
   pode afetar outras coisas que dependem do `quickshell` atual? (decisão sua)
2. **caelestia-cli:** instalar? Sem ela, troca de tema/wallpaper/IPC ficam
   limitadas.
3. Confirmar **Opção A** como primeiro passo (só build local + rodar), antes de
   qualquer instalação em `/usr`.
4. Confirmar a paleta rosé/ink final (herdar de `config/Theme.qml` do protótipo).
