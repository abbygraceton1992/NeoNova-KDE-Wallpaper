import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.FormLayout {
    id: root

    property alias cfg_OrbColor: colorButton.color

    KQuickControls.ColorButton {
        id: colorButton
        Kirigami.FormData.label: "Orb color:"
        dialogTitle: "Choose orb color"
        showAlphaChannel: false
    }
}
