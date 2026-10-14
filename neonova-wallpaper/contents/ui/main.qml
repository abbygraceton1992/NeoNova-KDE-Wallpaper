/*
 * plasmashell loads this QML as the logged-in user. The executable
 * data engine (plasma5support) is what turns a QML call into a process.
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as P5Support

WallpaperItem {
    id: root

    property string statusText: "starting animations…"
    property string scriptPath: Qt.resolvedUrl("../code/wallpaper_animation.sh").toString().replace(/^file:\/\//, "")

    property color orbColor: "#66d9ff"

    function updateOrbColor() {
        let raw = null
        if (root.configuration && root.configuration.OrbColor)
            raw = root.configuration.OrbColor
        else if (wallpaper && wallpaper.configuration && wallpaper.configuration.OrbColor)
            raw = wallpaper.configuration.OrbColor

        if (raw) {
            const newColor = Qt.color(String(raw))
            if (newColor !== root.orbColor)
                root.orbColor = newColor
        }
    }

    Component.onCompleted: {
        updateOrbColor()
        runOnceTimer.start()
    }

    Connections {
        target: root.configuration
        function onValueChanged(key, value) {
            if (key === "OrbColor")
                root.updateOrbColor()
        }
    }

    Connections {
        target: wallpaper ? wallpaper.configuration : null
        function onValueChanged(key, value) {
            if (key === "OrbColor")
                root.updateOrbColor()
        }
    }

    property real t: 0
    NumberAnimation on t {
        from: 0
        to: 1
        duration: 120000
        loops: Animation.Infinite
        running: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#050a12"

        Rectangle {
            id: wash
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.18 + 0.12 * pulse, 0.38, 1) }
                GradientStop { position: 0.5; color: Qt.rgba(0.03, 0.10, 0.22, 1) }
                GradientStop { position: 1.0; color: Qt.rgba(0.01, 0.04, 0.10, 1) }
            }
            property real pulse: 0
            SequentialAnimation on pulse {
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 1; duration: 8000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1; to: 0; duration: 8000; easing.type: Easing.InOutSine }
            }
        }

        Item {
            id: field
            anchors.fill: parent

            Repeater {
                model: 5
                delegate: Rectangle {
                    property real seed: index * 1.7
                    property real baseX: (index * 0.19 + 0.1) * field.width
                    property real baseY: (index * 0.23 + 0.15) * field.height
                    property real drift: 80 + index * 30

                    width: 180 + index * 40
                    height: width
                    radius: width / 2
                    color: Qt.rgba(root.orbColor.r, root.orbColor.g, root.orbColor.b, 0.06)
                    x: baseX + Math.sin(root.t * 6.28 + seed) * drift - width / 2
                    y: baseY + Math.cos(root.t * 6.28 * 0.7 + seed * 1.3) * drift * 0.6 - height / 2
                }
            }

            Repeater {
                model: 52
                delegate: Rectangle {
                    property real seed: index * 0.6180339887
                    property real baseX: (seed * 13.7 % 1.0) * field.width
                    property real baseY: (seed * 17.3 % 1.0) * field.height
                    property real vx: ((index % 9) - 4) * 0.35
                    property real vy: ((index % 7) - 3) * 0.28
                    property real twinklePhase: index * 0.4

                    width: 1.5 + (index % 5) * 0.8
                    height: width
                    radius: width / 2
                    color: Qt.rgba(
                        root.orbColor.r,
                        root.orbColor.g,
                        root.orbColor.b,
                        0.25 + 0.45 * (0.5 + 0.5 * Math.sin(root.t * 12 + twinklePhase))
                    )

                    x: ((baseX + root.t * 800 * vx) % field.width + field.width) % field.width - width / 2
                    y: ((baseY + root.t * 600 * vy) % field.height + field.height) % field.height - height / 2
                }
            }
        }
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            var stdout = (data["stdout"] || "").trim()
            var stderr = (data["stderr"] || "").trim()
            var code = data["exit code"]
            root.statusText = "exit " + code + "\n" + (stdout || stderr || "(no output)")
            console.log("wallpaper_animation stdout:", stdout)
            disconnectSource(sourceName)
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }

    Timer {
        id: runOnceTimer
        interval: 200
        repeat: false
        onTriggered: root.runWPAnimations()
    }

    function runWPAnimations() {
        var cmd = "/bin/sh \"" + scriptPath + "\""
        statusText = "running: " + cmd
        console.log("wallpaper_animation wallpaper exec:", cmd)
        executable.exec(cmd)
    }
}
