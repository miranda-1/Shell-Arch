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

    // ---- Fase de controles funcionais (autorizada): ações via API typed ----
    // Mutações restritas ao que o Quickshell.Networking expõe de forma
    // segura: ligar/desligar Wi-Fi, escanear e conectar em rede JÁ SALVA no
    // NetworkManager. Nada de senha/secret passa pela shell.

    readonly property bool hasWifiDevice: !!root._wifiDevice

    // redes visíveis ordenadas: conectada > salvas > maior sinal
    readonly property var wifiNetworks: {
        const d = root._wifiDevice;
        if (!d || !d.networks)
            return [];

        const nets = d.networks.values.slice();
        nets.sort(function(a, b) {
            const ca = a && a.connected ? 1 : 0;
            const cb = b && b.connected ? 1 : 0;
            if (ca !== cb)
                return cb - ca;

            const ka = a && a.known ? 1 : 0;
            const kb = b && b.known ? 1 : 0;
            if (ka !== kb)
                return kb - ka;

            return ((b && b.signalStrength) || 0) - ((a && a.signalStrength) || 0);
        });
        return nets;
    }

    function setWifiEnabled(on) {
        if (!root.available)
            return false;

        Networking.wifiEnabled = !!on;
        return true;
    }

    // liga o scan só enquanto a UI de redes está visível
    function setScanning(on) {
        const d = root._wifiDevice;
        if (d)
            d.scannerEnabled = !!on;
    }

    function isSecured(net) {
        return !!net && net.security !== WifiSecurityType.None;
    }

    // conectar apenas em rede salva (o NetworkManager já tem as credenciais)
    function canConnect(net) {
        return !!(net && net.known && !net.connected && net.network);
    }

    function connectToNetwork(net) {
        if (!root.canConnect(net))
            return false;

        net.network.connect();
        return true;
    }
}
