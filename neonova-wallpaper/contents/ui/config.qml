import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
    id: root
    
    property alias cfg_OrbColor: colorButton.color
    property alias cfg_BackgroundColor: bgColorButton.color
    
    KQuickControls.ColorButton {
        id: bgColorButton
        Kirigami.FormData.label: "Background color:"
        dialogTitle: "Choose background color"
        showAlphaChannel: false
    }
    
    KQuickControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: "Orb color:"
        dialogTitle: "Choose orb color"
        showAlphaChannel: false
    }
}
