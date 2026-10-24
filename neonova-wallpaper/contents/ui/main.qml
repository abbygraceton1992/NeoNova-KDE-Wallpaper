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
    property color bgColor: "#050a12"
    property real orbAlpha: 0.22
    property string backgroundType: "color"
    property string backgroundImage: ""
    
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
    
    function updateBgColor() {
        let raw = null
        if (root.configuration && root.configuration.BackgroundColor)
            raw = root.configuration.BackgroundColor
        else if (wallpaper && wallpaper.configuration && wallpaper.configuration.BackgroundColor)
            raw = wallpaper.configuration.BackgroundColor
                
        if (raw) {
            const newColor = Qt.color(String(raw))
            if (newColor !== root.bgColor)
                root.bgColor = newColor
        }
    }
    
    function updateOrbAlpha() {
        let raw = null
        if (root.configuration && root.configuration.OrbAlpha !== undefined)
            raw = root.configuration.OrbAlpha
        else if (wallpaper && wallpaper.configuration && wallpaper.configuration.OrbAlpha !== undefined)
            raw = wallpaper.configuration.OrbAlpha
                
        if (raw !== null && raw !== undefined) {
            const newAlpha = Number(raw)
            if (!isNaN(newAlpha) && newAlpha !== root.orbAlpha)
                root.orbAlpha = Math.max(0.05, Math.min(0.6, newAlpha))
        }
    }
    
    function updateBackgroundType() {
        let raw = null
        if (root.configuration && root.configuration.BackgroundType)
            raw = root.configuration.BackgroundType
        else if (wallpaper && wallpaper.configuration && wallpaper.configuration.BackgroundType)
            raw = wallpaper.configuration.BackgroundType
                
        if (raw) {
            const newType = String(raw)
            if (newType !== root.backgroundType)
                root.backgroundType = newType
        }
    }
    
    function updateBackgroundImage() {
        let raw = null
        if (root.configuration && root.configuration.BackgroundImage !== undefined)
            raw = root.configuration.BackgroundImage
        else if (wallpaper && wallpaper.configuration && wallpaper.configuration.BackgroundImage !== undefined)
            raw = wallpaper.configuration.BackgroundImage
                
        if (raw !== null && raw !== undefined) {
            const newPath = String(raw)
            if (newPath !== root.backgroundImage)
                root.backgroundImage = newPath
        }
    }
    
    Component.onCompleted: {
        updateOrbColor()
        updateBgColor()
        updateOrbAlpha()
        updateBackgroundType()
        updateBackgroundImage()
        runOnceTimer.start()
    }
    
    Connections {
        target: root.configuration
        function onValueChanged(key, value) {
            if (key === "OrbColor")
                root.updateOrbColor()
            if (key === "BackgroundColor")
                root.updateBgColor()
            if (key === "OrbAlpha")
                root.updateOrbAlpha()
            if (key === "BackgroundType")
                root.updateBackgroundType()
            if (key === "BackgroundImage")
                root.updateBackgroundImage()
        }
    }
    
    Connections {
        target: wallpaper ? wallpaper.configuration : null
        function onValueChanged(key, value) {
            if (key === "OrbColor")
                root.updateOrbColor()
            if (key === "BackgroundColor")
                root.updateBgColor()
            if (key === "OrbAlpha")
                root.updateOrbAlpha()
            if (key === "BackgroundType")
                root.updateBackgroundType()
            if (key === "BackgroundImage")
                root.updateBackgroundImage()
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
    
    Item {
        anchors.fill: parent
        
        // Solid color background (with wash)
        Rectangle {
            anchors.fill: parent
            color: root.bgColor
            visible: root.backgroundType !== "image" || root.backgroundImage === ""
            
            Rectangle {
                id: wash
                anchors.fill: parent
                gradient: Gradient {
                    // Reduced contrast so orbs remain visible against the wash
                    GradientStop { position: 0.0; color: Qt.lighter(root.bgColor, 1.12 + 0.12 * pulse) }
                    GradientStop { position: 0.5; color: Qt.lighter(root.bgColor, 1.04) }
                    GradientStop { position: 1.0; color: Qt.darker(root.bgColor, 1.18) }
                }
                property real pulse: 0
                SequentialAnimation on pulse {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0; to: 1; duration: 8000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1; to: 0; duration: 8000; easing.type: Easing.InOutSine }
                }
            }
        }
        
        // Image background
        Image {
            anchors.fill: parent
            source: root.backgroundImage ? ("file://" + root.backgroundImage) : ""
            fillMode: Image.PreserveAspectCrop
            visible: root.backgroundType === "image" && root.backgroundImage !== ""
            asynchronous: true
            cache: true
            smooth: true
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
                    property real pulseFactor: 0.5 + 0.5 * Math.sin(root.t * 6.28 * 0.4 + seed)

                    width: 180 + index * 40
                    height: width
                    radius: width / 2
                    color: Qt.rgba(
                        root.orbColor.r,
                        root.orbColor.g,
                        root.orbColor.b,
                        root.orbAlpha * (0.8 + 0.2 * pulseFactor)
                    )
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
