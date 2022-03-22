import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"     //导入CfgAPI.qml

CfgAPI {
    version: "1.0.0"
    cfg_height: 580

    P.SwitchPreference {
        id: _cfg_preset_line_Center_Line
        name: "Center Line"
        label: qsTr("Show Center Line")
        defaultValue: true
    }

    P.ColorPreference {
        name: "Center Color"
        label: qsTr("Center Line Color")
        enabled: _cfg_preset_line_Center_Line.value
        defaultValue: "#FF4500"
    }

    P.Separator {}

    P.ColorPreference {
        name: "Line Color"
        label: qsTr("Spectrum Line Color")
        defaultValue: "#FF4500"
    }

    P.SelectPreference {
        name: "Line Position"
        label: qsTr("Spectrum Line Position")
        defaultValue: 0
        model: [qsTr("Both"), qsTr("Up"), qsTr("Down")]
    }

    P.SelectPreference {
        name: "Data Length"
        label: qsTr("Spectrum Length")
        defaultValue: 0
        model: [64, 32, 16, 8]
    }

    P.Separator {}

    P.SpinPreference {
        id: _cfg_preset_line_Channel
        name: "Channel"
        label: qsTr("Channel")
        message: "1 to 2"
        display: P.TextFieldPreference.ExpandLabel
        editable: false
        from: 1
        to: 2
        defaultValue: 2
    }

    P.SwitchPreference {
        name: "Reverse"
        label: qsTr("Reverse Spectrum")
        enabled: _cfg_preset_line_Channel.value === 1
        defaultValue: false
    }

    P.Separator {}

    P.DialogPreference {
        name: "Rotate Settings"
        label: qsTr("Rotate Settings")
        live: true
        icon.name: "regular:\uf1de"

        P.SwitchPreference {
            id: _cfg_preset_line_Rotate_Center_Enable
            name: "Center Enable"
            label: qsTr("Rotate Center Line")
            defaultValue: false
        }

        P.SliderPreference {
            name: "Center Angle"
            label: qsTr("Angle of Center Line")
            enabled: _cfg_preset_line_Rotate_Center_Enable.value
            from: -45
            to: 45
            stepSize: 1
            defaultValue: 10
            displayValue: value + "°"
        }

        P.Separator {}

        P.SwitchPreference {
            id: _cfg_preset_line_Rotate_Line_Enable
            name: "Line Enable"
            label: qsTr("Rotate Spectrum Line")
            defaultValue: false
        }

        P.SliderPreference {
            name: "Line Angle"
            label: qsTr("Angle of Spectrum Line")
            enabled: _cfg_preset_line_Rotate_Line_Enable.value
            from: -75
            to: 75
            stepSize: 1
            defaultValue: 10
            displayValue: value + "°"
        }
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

        P.Separator {}

        P.SelectPreference {
            name: "Unit Style"
            label: qsTr("Display Style")
            defaultValue: 0
            model: [qsTr("Linear"), qsTr("Decibel")]
        }
    }
}
