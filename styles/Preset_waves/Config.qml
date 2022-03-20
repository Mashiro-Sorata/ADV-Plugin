import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"     //导入CfgAPI.qml

CfgAPI {
    version: "1.0.0"
    cfg_height: 580

    P.SliderPreference {
        name: "Line Width"
        label: qsTr("Spectrum Line Width")
        from: 0.1
        to: 4
        stepSize: 0.1
        defaultValue: 1
        displayValue: value.toFixed(1) + "px"
    }

    P.ColorPreference {
        name: "Line Color"
        label: qsTr("Spectrum Line Color")
        defaultValue: "#FF4500"
    }

    P.Separator {}

    P.DialogPreference {
        name: "Data Settings"
        label: qsTr("Data Settings")
        live: true
        icon.name: "regular:\uf1de"

        P.SwitchPreference {
            id: _cfg_preset_line_dataSettings_autoNormalizing
            name: "Auto Normalizing"
            label: qsTr("Auto Normalizing")
            defaultValue: true
        }

        P.SpinPreference {
            name: "Amplitude"
            label: qsTr("Amplitude Ratio")
            enabled: !_cfg_preset_line_dataSettings_autoNormalizing.value
            message: "1 to 100"
            display: P.TextFieldPreference.ExpandLabel
            editable: true
            from: 1
            to: 100
            defaultValue: 10
        }
    }
}
