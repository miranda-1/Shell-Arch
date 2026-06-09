pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

// Serviço Bluetooth via Quickshell.Bluetooth (BlueZ, API typed — sem comando
// externo). Lê adapter/dispositivos e, na fase de controles funcionais
// (autorizada), liga/desliga o adapter e conecta/desconecta dispositivos JÁ
// PAREADOS. Não pareia nem esquece dispositivos pela shell.
Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: !!root.adapter
    readonly property bool enabled: root.available && root.adapter.enabled

    // dispositivos pareados, conectados primeiro, depois por nome
    readonly property var pairedDevices: {
        if (!root.adapter || !root.adapter.devices)
            return [];

        const list = root.adapter.devices.values.slice().filter(function(d) {
            return d && (d.paired || d.bonded);
        });

        list.sort(function(a, b) {
            const ca = a.connected ? 1 : 0;
            const cb = b.connected ? 1 : 0;
            if (ca !== cb)
                return cb - ca;

            return (a.name || "").localeCompare(b.name || "");
        });
        return list;
    }

    readonly property int connectedCount: {
        let n = 0;
        for (let i = 0; i < root.pairedDevices.length; i++) {
            if (root.pairedDevices[i].connected)
                n++;
        }
        return n;
    }

    readonly property string statusText: {
        if (!root.available)
            return "Sem adaptador";
        if (!root.enabled)
            return "Desligado";
        if (root.connectedCount === 1)
            return "1 dispositivo conectado";
        if (root.connectedCount > 1)
            return root.connectedCount + " dispositivos conectados";
        return "Ligado, nada conectado";
    }

    function setEnabled(on) {
        if (!root.available)
            return false;

        root.adapter.enabled = !!on;
        return true;
    }

    function toggleDevice(device) {
        if (!device || !(device.paired || device.bonded))
            return false;

        if (device.connected)
            device.disconnect();
        else
            device.connect();
        return true;
    }
}
