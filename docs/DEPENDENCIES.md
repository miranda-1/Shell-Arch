# Dependências

## Já instaladas (confirmado neste sistema)

- `quickshell` 0.3.0 — runtime da shell (binário `qs`)
- `qt6-declarative` — QML/Qt Quick
- `qt6-wayland` — integração Wayland
- `hyprland` 0.55.2 — compositor (layer-shell, IPC)

Nenhuma dependência nova é necessária para a Fase 0/POC.

## Por fase (quando chegarmos lá)

- **Serviços de estado (Fase 3)** — Quickshell já expõe módulos nativos:
  `Quickshell.Services.*` (Mpris/mídia, Pipewire/áudio, UPower/bateria),
  `Quickshell.Hyprland` (workspaces). Verificar disponibilidade por módulo.
- **Rede/Bluetooth** — via `NetworkManager`/`bluez` (já presentes no sistema) ou
  CLI (`nmcli`, `bluetoothctl`) atrás de um serviço.
- **Brilho** — `brightnessctl` (checar se instalado antes de usar).
- **Ícones/fontes** — Nerd Font para os glyphs dos ícones (o HyDE já costuma ter
  uma; confirmar família antes de fixar no Theme).
- **Paleta do wallpaper (Fase 4)** — ler o esquema de cor já gerado pelo HyDE
  (só-leitura) ou `matugen`. Decidir na hora; sem instalar nada às cegas.

## Referência de leitura (NÃO instalar por cima)

- `~/Projetos/referencias/caelestia-shell` — projeto Quickshell real, usado como
  fonte de padrões (drawers/popouts, controlcenter, launcher). Apenas leitura.
