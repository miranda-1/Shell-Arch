pragma Singleton

import Quickshell
import Quickshell.Networking
import QtQuick

// Serviço read-only de rede (Fase 5). Fonte: Quickshell.Networking (backend
// NetworkManager, nativo/evented). Apenas LEITURA — não liga/desliga Wi-Fi,
// não conecta/desconecta, não altera nada. Expõe o SSID da rede Wi-Fi
// conectada e um rótulo de status seguro para a tooltip da EdgeLeft.
//
// Observação: este módulo é mais novo que UPower/MPRIS; por isso os acessos
// são todos guardados (null-checks) e nunca assumem que há device/rede.
Singleton {
    id: root

    readonly property bool available: Networking.backend === NetworkBackendType.NetworkManager
    readonly property bool wifiEnabled: Networking.wifiEnabled

    readonly property var _devices: Networking.devices ? Networking.devices.values : []

    // primeiro dispositivo Wi-Fi (se existir)
    readonly property var _wifiDevice: {
        for (let i = 0; i < root._devices.length; i++) {
            const d = root._devices[i];
            if (d && d.type === DeviceType.Wifi)
                return d;
        }
        return null;
    }

    // rede Wi-Fi atualmente conectada dentro desse dispositivo (se houver)
    readonly property var _activeWifi: {
        const d = root._wifiDevice;
        if (!d || !d.networks)
            return null;
        const nets = d.networks.values;
        for (let i = 0; i < nets.length; i++) {
            if (nets[i] && nets[i].connected)
                return nets[i];
        }
        return null;
    }

    // algum dispositivo cabeado conectado?
    readonly property bool _wiredConnected: {
        for (let i = 0; i < root._devices.length; i++) {
            const d = root._devices[i];
            if (d && d.type === DeviceType.Wired && d.connected)
                return true;
        }
        return false;
    }

    // SSID da rede Wi-Fi conectada (vazio se nenhuma)
    readonly property string ssid: root._activeWifi && root._activeWifi.name ? root._activeWifi.name : ""

    // conectado por Wi-Fi ou cabo
    readonly property bool connected: root.ssid.length > 0 || root._wiredConnected

    // rótulo seguro e auto-descritivo para a UI
    readonly property string statusText: {
        if (!root.available)
            return "Indisponível";
        if (root.ssid.length > 0)
            return root.ssid;
        if (root._wiredConnected)
            return "Conectado (cabo)";
        if (!root.wifiEnabled)
            return "Wi-Fi desligado";
        return "Sem rede";
    }

    // glyph Nerd Font (BMP) — exposto para uso futuro; a EdgeLeft mantém o
    // glyph atual para não alterar o visual nesta leva.
    readonly property string glyph: ""   // wifi
}
