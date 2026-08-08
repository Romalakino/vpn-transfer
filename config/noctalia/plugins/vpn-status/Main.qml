import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    readonly property int refreshInterval: cfg.refreshInterval ?? defaults.refreshInterval ?? 2000
    readonly property bool showCountryFlag: cfg.showCountryFlag ?? defaults.showCountryFlag ?? true
    readonly property bool showServerName: cfg.showServerName ?? defaults.showServerName ?? false

    property string state: "disconnected"  // disconnected | connecting | connected
    property string serverName: ""

    readonly property string flagEmoji: {
        if (!showCountryFlag || state !== "connected") return ""
        var m = serverName.match(/[^\s\S]/)  // placeholder
        return serverName.replace(/\s.*/, "").trim()
    }

    // ─── Poll status file ───
    Process {
        id: statusProcess
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: function (code) {
            if (code === 0) {
                var raw = String(statusProcess.stdout.text || "").trim()
                if (raw === "ON") root.state = "connected"
                else if (raw === "CONNECTING") root.state = "connecting"
                else root.state = "disconnected"
            }
            if (!root.showCountryFlag && !root.showServerName) return
            nameProcess.running = true
        }
    }

    Process {
        id: nameProcess
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: function (code) {
            if (code === 0) {
                var raw = String(nameProcess.stdout.text || "").trim()
                root.serverName = raw
            }
        }
    }

    function updateStatus() {
        statusProcess.command = ["cat", "/tmp/vpn-status"]
        statusProcess.running = true
    }

    // ─── Toggle VPN ───
    Process {
        id: toggleProcess
        onExited: function (code) {
            root.updateStatus()
        }
    }

    function toggleVpn() {
        toggleProcess.command = ["vpn-toggle", "toggle"]
        toggleProcess.running = true
    }

    Timer {
        id: updateTimer
        interval: root.refreshInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateStatus()
    }
}
