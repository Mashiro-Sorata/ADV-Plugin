import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"      //导入CfgAPI.qml

CfgAPI {
    version: "1.0.0"
    cfg_height: 740

    P.ColorPreference {
        name: "Main Color"
        label: qsTr("Spectrum Line Color")
        defaultValue: "#FF4500"
    }

    P.SelectPreference {
        name: "Line Position"
        label: qsTr("Spectrum Line Position")
        defaultValue: 0
        model: [qsTr("Both"), qsTr("Outside"), qsTr("Inside")]
    }

    P.SliderPreference {
        name: "Line Width"
        label: qsTr("Spectrum Line Width")
        from: 0.1
        to: 4
        stepSize: 0.1
        defaultValue: 1
        displayValue: value.toFixed(1) + "px"
    }

    P.SliderPreference {
        name: "Max Range"
        label: qsTr("Max Amplitude")
        from: 0
        to: 100
        stepSize: 1
        defaultValue: 50
        displayValue: value + "%"
    }

    P.SelectPreference {
        name: "Data Length"
        label: qsTr("Spectrum Length")
        defaultValue: 0
        model: [64, 32, 16, 8]
    }

    P.Separator {}

    P.SpinPreference {
        name: "Channel"
        label: qsTr("Channel")
        message: "1 to 2"
        display: P.TextFieldPreference.ExpandLabel
        editable: false
        from: 1
        to: 2
        defaultValue: 2
    }

    P.Separator {}

    P.SwitchPreference {
        name: "Reverse"
        label: qsTr("Reverse Spectrum")
        defaultValue: false
    }

    P.Separator {}

    P.SwitchPreference {
        id: _cfg_preset_line_rotate
        name: "Rotate"
        label: qsTr("Auto Rotate")
        defaultValue: false
    }

    P.SliderPreference {
        name: "Ratate Speed"
        label: qsTr("Ratate Speed")
        enabled: _cfg_preset_line_rotate.value
        from: 1
        to: 100
        stepSize: 1
        defaultValue: 10
        displayValue: value + "%"
    }

    P.SpinPreference {
        name: "Angle"
        label: qsTr("Initial Angle")
        message: "0 to 359"
        enabled: !_cfg_preset_line_rotate.value
        display: P.TextFieldPreference.ExpandLabel
        editable: true
        from: 0
        to: 359
        defaultValue: 0
    }

    P.Separator {}

    P.DialogPreference {
        name: "Data Settings"
        label: qsTr("Data Settings")
        live: true
        icon.name: "regular:\uf1de"

        P.SwitchPreference {
            id: _cfg_preset_solidcircle_dataSettings_autoNormalizing
            name: "Auto Normalizing"
            label: qsTr("Auto Normalizing")
            defaultValue: true
        }

        P.SpinPreference {
            name: "Amplitude"
            label: qsTr("Amplitude Ratio")
            enabled: !_cfg_preset_solidcircle_dataSettings_autoNormalizing.value
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
