import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"      //导入CfgAPI.qml

CfgAPI {
    version: "1.0.0"
    cfg_height: 710

    P.ColorPreference {
        name: "Bass Color"
        label: qsTr("Bass Line Color")
        defaultValue: "#DC143C"
    }

    P.ColorPreference {
        name: "Alto Color"
        label: qsTr("Alto Line Color")
        defaultValue: "#F8F8FF"
    }

    P.ColorPreference {
        name: "Treble Color"
        label: qsTr("Treble Line Color")
        defaultValue: "#4169E1"
    }

    P.Separator {}

    P.SliderPreference {
        name: "Bass AM"
        label: qsTr("Bass Amplitude")
        from: 10
        to: 300
        stepSize: 5
        defaultValue: 100
        displayValue: value + "%"
    }

    P.SliderPreference {
        name: "Alto AM"
        label: qsTr("Alto Amplitude")
        from: 10
        to: 300
        stepSize: 5
        defaultValue: 150
        displayValue: value + "%"
    }

    P.SliderPreference {
        name: "Treble AM"
        label: qsTr("Treble Amplitude")
        from: 10
        to: 300
        stepSize: 5
        defaultValue: 200
        displayValue: value + "%"
    }

    P.Separator {}

    P.SliderPreference {
        name: "Static AM"
        label: qsTr("Static Amplitude")
        from: 5
        to: 100
        stepSize: 1
        defaultValue: 15
        displayValue: value + "%"
    }

    P.Separator {}

    P.SliderPreference {
        name: "Speed"
        label: qsTr("Wave Speed")
        from: 1
        to: 100
        stepSize: 1
        defaultValue: 20
        displayValue: value + "%"
    }

    P.Separator {}

    P.DialogPreference {
        name: "Data Settings"
        label: qsTr("Data Settings")
        live: true
        icon.name: "regular:\uf1de"

        P.SwitchPreference {
            id: _cfg_preset_osui_dataSettings_autoNormalizing
            name: "Auto Normalizing"
            label: qsTr("Auto Normalizing")
            defaultValue: true
        }

        P.SpinPreference {
            name: "Amplitude"
            label: qsTr("Amplitude Ratio")
            enabled: !_cfg_preset_osui_dataSettings_autoNormalizing.value
            message: "1 to 100"
            display: P.TextFieldPreference.ExpandLabel
            editable: true
            from: 1
            to: 100
            defaultValue: 10
        }
    }
}
