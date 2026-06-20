import "../../../components"
import "../../../config"
import "../../../services"
import QtQuick

// "Sistema ao vivo": três anéis (CPU / GPU / RAM). No centro de cada anel o uso
// em %, abaixo a temperatura, e uma linha menor com o detalhe do componente
// (frequência da CPU, VRAM da GPU, GB de RAM). GPU vem do nvidia-smi (Stats).
Item {
    id: root

    implicitHeight: content.implicitHeight

    readonly property int ringSize: Math.max(108, Math.min(132, (root.width - Theme.pad * 2 - Theme.gap * 2) / 3))

    Column {
        id: content
        width: root.width
        spacing: Theme.pad

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.gap

            Repeater {
                // descritores estáticos (sem valores ao vivo → delegates estáveis;
                // os números entram por binding direto no Stats dentro do delegate)
                model: [
                    { kind: "cpu", label: "CPU" },
                    { kind: "gpu", label: "GPU" },
                    { kind: "ram", label: "RAM" }
                ]

                delegate: Column {
                    id: cell
                    required property var modelData

                    readonly property real fraction: modelData.kind === "cpu" ? Stats.cpuPercent / 100
                        : modelData.kind === "gpu" ? Stats.gpuPercent / 100
                        : Stats.memPercent / 100
                    readonly property string usageText: modelData.kind === "cpu" ? Stats.cpuText
                        : modelData.kind === "gpu" ? Stats.gpuText
                        : Stats.memText
                    readonly property string tempText: modelData.kind === "cpu" ? Stats.tempText
                        : modelData.kind === "gpu" ? Stats.gpuTempText
                        : Stats.ramTempText
                    readonly property string detailText: modelData.kind === "cpu" ? Stats.cpuFreqText
                        : modelData.kind === "gpu" ? Stats.vramText
                        : Stats.memGbText

                    spacing: 6

                    RingMeter {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: root.ringSize
                        height: root.ringSize
                        value: Math.max(0, Math.min(1, cell.fraction))
                        big: cell.usageText
                        sub: cell.modelData.label

                        Behavior on value { NumberAnimation { duration: Theme.tBase; easing.type: Easing.OutCubic } }
                    }

                    // temperatura (destaque)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cell.tempText
                        font.pixelSize: Theme.fsLabel
                        font.bold: true
                        color: Theme.text
                    }

                    // detalhe do componente (freq / VRAM / GB)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: cell.detailText
                        font.pixelSize: Theme.fsCaption
                        color: Theme.textDim
                    }
                }
            }
        }

        Text {
            visible: !Stats.gpuAvailable
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "GPU sem dados (nvidia-smi indisponível nesta sessão)."
            font.pixelSize: Theme.fsCaption
            color: Theme.textFaint
            wrapMode: Text.Wrap
        }
    }
}
