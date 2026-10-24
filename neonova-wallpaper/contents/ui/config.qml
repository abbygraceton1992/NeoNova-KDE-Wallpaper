import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
    id: root
    
    property alias cfg_OrbColor: colorButton.color
    property alias cfg_BackgroundColor: bgColorButton.color
    property alias cfg_OrbAlpha: alphaSlider.value
    property string cfg_BackgroundType: "color"
    property string cfg_BackgroundImage: ""
    
    ComboBox {
        id: bgTypeCombo
        Kirigami.FormData.label: "Background type:"
        model: [
            { text: "Solid color", value: "color" },
            { text: "Image", value: "image" }
        ]
        textRole: "text"
        valueRole: "value"
        currentIndex: root.cfg_BackgroundType === "image" ? 1 : 0
        onActivated: {
            root.cfg_BackgroundType = model[currentIndex].value
        }
    }
    
    KQuickControls.ColorButton {
        id: bgColorButton
        Kirigami.FormData.label: "Background color:"
        dialogTitle: "Choose background color"
        showAlphaChannel: false
        visible: root.cfg_BackgroundType !== "image"
    }
    
    Button {
        Kirigami.FormData.label: "Background image:"
        text: "Choose image…"
        visible: root.cfg_BackgroundType === "image"
        onClicked: fileDialog.open()
    }
    
    Label {
        Kirigami.FormData.label: "Selected image:"
        text: root.cfg_BackgroundImage ? root.cfg_BackgroundImage : "(none)"
        visible: root.cfg_BackgroundType === "image"
        wrapMode: Text.Wrap
        elide: Text.ElideMiddle
    }
    
    KQuickControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: "Orb color:"
        dialogTitle: "Choose orb color"
        showAlphaChannel: false
    }
    
    Slider {
        id: alphaSlider
        Kirigami.FormData.label: "Base orb opacity:"
        from: 0.05
        to: 0.6
        value: 0.22
        stepSize: 0.01
        live: true
    }
    
    FileDialog {
        id: fileDialog
        title: "Choose background image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.webp *.bmp *.gif)", "All files (*)"]
        onAccepted: {
            root.cfg_BackgroundImage = selectedFile.toString().replace(/^file:\/\//, "")
        }
    }
}
