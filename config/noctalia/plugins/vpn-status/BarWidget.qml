import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    readonly property string screenName: screen ? screen.name : ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    readonly property var main: pluginApi?.mainInstance
    readonly property string vpnState: main?.state ?? "disconnected"
    readonly property string serverName: main?.serverName ?? ""
    readonly property bool showFlag: main?.showCountryFlag ?? true

    readonly property string currentIcon: {
        if (vpnState === "connected") return "shield-check"
        if (vpnState === "connecting") return "loader"
        return "shield-off"
    }

    readonly property color stateColor: {
        if (vpnState === "connected") return Color.mPrimary
        if (vpnState === "connecting") return Color.mTertiary
        return Color.mOnSurfaceVariant
    }

    property real margins: Style.marginM * 2

    readonly property real contentWidth: isVertical ? Style.capsuleHeight : Math.round(layout.implicitWidth + margins)
    readonly property real contentHeight: isVertical ? Math.round(layout.implicitHeight + margins) : Style.capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    Layout.alignment: Qt.AlignVCenter

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        radius: Style.radiusM
        color: Style.capsuleColor
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Item {
            id: layout
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: iconRow.implicitWidth
            implicitHeight: iconRow.implicitHeight

            RowLayout {
                id: iconRow
                spacing: Style.marginXS

                NIcon {
                    id: vpnIcon
                    icon: root.currentIcon
                    color: root.stateColor

                    property real _spinner: 0
                    rotation: root.vpnState === "connecting" ? vpnIcon._spinner : 0

                    RotationAnimation on _spinner {
                        running: root.vpnState === "connecting"
                        from: 0
                        to: 360
                        duration: 1200
                        loops: Animation.Infinite
                    }
                }

                NText {
                    visible: root.isVertical ? false : root.showFlag && root.vpnState === "connected"
                    text: root.serverName.replace(/\s.*/, "").trim()
                    pointSize: Style.fontSizeXS
                    color: Color.mOnSurface
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: TooltipService.show(root, root._tooltipText(), BarService.getTooltipDirection(root.screen?.name))
        onExited: TooltipService.hide()

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                Process.spawn(["vpn-menu"])
            } else if (mouse.button === Qt.RightButton) {
                root.main?.toggleVpn()
            }
        }
    }

    function _tooltipText() {
        if (vpnState === "connected") return "VPN ВКЛ: " + (root.serverName || "?")
        if (vpnState === "connecting") return "VPN: подключение..."
        return "VPN ВЫКЛ"
    }
}
