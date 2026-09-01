import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Commons

Item {
  id: root

  required property int workspaceId
  property var workspace: null
  property var bar: null
  property bool focused: false
  property bool active: false
  property int revision: 0

  readonly property int headerHeight: Style.space(34)
  readonly property int canvasPadding: Style.space(7)
  readonly property var windows: windowSnapshot(revision)
  readonly property var bounds: geometryBounds(windows)

  function safeNumber(value, fallback) {
    var number = Number(value)
    return isFinite(number) ? number : fallback
  }

  function ipcArray(value, fallbackA, fallbackB) {
    if (value && value.length >= 2)
      return [safeNumber(value[0], fallbackA), safeNumber(value[1], fallbackB)]
    return [fallbackA, fallbackB]
  }

  function windowSnapshot(refreshToken) {
    // refreshToken intentionally makes the periodic refresh part of this binding.
    var ignored = refreshToken
    var result = []
    if (!root.workspace) return result

    var values = root.workspace.toplevels.values || []
    for (var i = 0; i < values.length; i++) {
      var toplevel = values[i]
      var ipc = toplevel.lastIpcObject || ({})
      var at = ipcArray(ipc.at, 0, 0)
      var size = ipcArray(ipc.size, 800, 600)
      var appClass = String(ipc.class || ipc.initialClass || "Application")
      var title = String(toplevel.title || ipc.title || appClass)

      result.push({
        address: String(toplevel.address || i),
        toplevel: toplevel,
        x: at[0],
        y: at[1],
        width: Math.max(80, size[0]),
        height: Math.max(60, size[1]),
        appClass: appClass,
        title: title,
        urgent: Boolean(toplevel.urgent),
        activated: Boolean(toplevel.activated)
      })
    }
    return result
  }

  function geometryBounds(items) {
    if (!items || items.length === 0) return { x: 0, y: 0, width: 1920, height: 1080 }
    var minX = items[0].x
    var minY = items[0].y
    var maxX = items[0].x + items[0].width
    var maxY = items[0].y + items[0].height
    for (var i = 1; i < items.length; i++) {
      minX = Math.min(minX, items[i].x)
      minY = Math.min(minY, items[i].y)
      maxX = Math.max(maxX, items[i].x + items[i].width)
      maxY = Math.max(maxY, items[i].y + items[i].height)
    }
    return { x: minX, y: minY, width: Math.max(1, maxX - minX), height: Math.max(1, maxY - minY) }
  }

  function shortClass(value) {
    var text = String(value || "Application")
    var parts = text.split(".")
    text = parts[parts.length - 1]
    return text.charAt(0).toUpperCase() + text.slice(1)
  }

  Timer {
    interval: 750
    repeat: true
    running: root.active
    triggeredOnStart: true
    onTriggered: root.revision++
  }

  Row {
    id: heading
    height: root.headerHeight
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    spacing: Style.space(7)

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: "Workspace " + (root.workspaceId === 10 ? "0" : root.workspaceId)
      color: Color.popups.text
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.heading
      font.weight: Font.DemiBold
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.windows.length === 0 ? "Empty" : root.windows.length + (root.windows.length === 1 ? " window" : " windows")
      color: Color.muted
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
    }
  }

  Rectangle {
    id: desktop
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: heading.bottom
    anchors.bottom: parent.bottom
    radius: Style.space(6)
    color: Util.alpha(Color.background, 0.72)
    border.width: Math.max(1, Style.space(1))
    border.color: Util.alpha(root.focused ? Color.accent : Color.popups.text, root.focused ? 0.75 : 0.18)
    clip: true

    Text {
      anchors.centerIn: parent
      visible: root.windows.length === 0
      text: "No open windows"
      color: Color.muted
      font.family: root.bar ? root.bar.fontFamily : Style.font.family
      font.pixelSize: Style.font.body
    }

    Repeater {
      model: root.windows

      Rectangle {
        required property var modelData

        readonly property real usableWidth: desktop.width - root.canvasPadding * 2
        readonly property real usableHeight: desktop.height - root.canvasPadding * 2
        readonly property real scaleFactor: Math.min(usableWidth / root.bounds.width, usableHeight / root.bounds.height)
        readonly property real renderedWidth: root.bounds.width * scaleFactor
        readonly property real renderedHeight: root.bounds.height * scaleFactor
        readonly property real offsetX: root.canvasPadding + (usableWidth - renderedWidth) / 2
        readonly property real offsetY: root.canvasPadding + (usableHeight - renderedHeight) / 2

        x: offsetX + (modelData.x - root.bounds.x) * scaleFactor
        y: offsetY + (modelData.y - root.bounds.y) * scaleFactor
        width: Math.max(Style.space(54), modelData.width * scaleFactor)
        height: Math.max(Style.space(34), modelData.height * scaleFactor)
        radius: Style.space(4)
        color: Util.alpha(modelData.activated ? Color.accent : Color.foreground, modelData.activated ? 0.22 : 0.10)
        border.width: Math.max(1, Style.space(1))
        border.color: modelData.urgent ? Color.urgent : Util.alpha(modelData.activated ? Color.accent : Color.foreground, 0.55)
        clip: true

        ScreencopyView {
          id: windowCapture
          anchors.fill: parent
          captureSource: modelData.toplevel && modelData.toplevel.wayland ? modelData.toplevel.wayland : null
          paintCursor: false
          live: root.active
          constraintSize: Qt.size(Math.max(1, width), Math.max(1, height))
        }

        Rectangle {
          anchors.fill: parent
          visible: !windowCapture.hasContent
          color: Util.alpha(modelData.activated ? Color.accent : Color.foreground, modelData.activated ? 0.22 : 0.10)
        }

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          height: Math.min(parent.height, Style.space(25))
          visible: windowCapture.hasContent && parent.height >= Style.space(42)
          color: Util.alpha(Color.background, 0.72)
        }

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(6)
          spacing: Style.space(2)

          Text {
            width: parent.width
            text: root.shortClass(modelData.appClass)
            color: Color.popups.text
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.body
            font.weight: Font.DemiBold
            elide: Text.ElideRight
          }

          Text {
            width: parent.width
            visible: !windowCapture.hasContent && parent.parent.height >= Style.space(48)
            text: modelData.title
            color: Color.muted
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Math.max(9, Style.font.body - 2)
            elide: Text.ElideRight
          }
        }
      }
    }
  }
}
