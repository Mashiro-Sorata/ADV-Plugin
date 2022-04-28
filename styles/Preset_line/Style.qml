import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: AdvpCanvasTemplate {
        readonly property var audioData: new Array(128)

        readonly property bool centerLineFlag: configs["Center Line"]
        readonly property string center_color: configs["Center Color"]
        readonly property string line_color: configs["Line Color"]
        readonly property int linePosition: configs["Line Position"]
        readonly property int uDataLen: Math.pow(2, configs["Data Length"]);
        readonly property int dataLength: 64/uDataLen
        readonly property int channel: configs["Channel"]
        readonly property bool centerRotateFlag: configs["Rotate Settings"]["Center Enable"]
        readonly property real centerRotateAngle: configs["Rotate Settings"]["Center Angle"]*Math.PI/180
        readonly property bool lineRotateFlag: configs["Rotate Settings"]["Line Enable"]
        readonly property real lineRotateAngle: configs["Rotate Settings"]["Line Angle"]*Math.PI/180
        readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
        readonly property real amplitude: 400.0/configs["Data Settings"]["Amplitude"]
        readonly property int unitStyle: configs["Data Settings"]["Unit Style"]

        property real halfWidth: width/2
        property real halfHeight: height/2

        readonly property int l_start: (channel===1)*dataLength
        readonly property int r_stop: dataLength+dataLength*(channel!==0)
        readonly property int total: r_stop-l_start
        readonly property real _y_dy: centerRotateFlag*Math.tan(centerRotateAngle)*halfWidth
        readonly property real _ux: width/(r_stop-l_start)
        readonly property real _dx: Math.round(_ux/2)

        onAudioDataUpdeted: {
            let normalizing_ratio = autoNormalizing ? data[128] : amplitude;
            if (unitStyle) {
                //对数化显示
                for(let i=l_start; i<dataLength; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += Math.max(0, 0.4 * (Math.log10(data[63-i*uDataLen-j]/normalizing_ratio)) + 1.0);
                    }
                    audioData[i] /= uDataLen;
                }
                for(let i=dataLength; i<r_stop; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += Math.max(0, 0.4 * (Math.log10(data[i*uDataLen+j]/normalizing_ratio)) + 1.0);
                    }
                    audioData[i] /= uDataLen;
                }
            } else {
                //线性化显示
                for(let i=l_start; i<dataLength; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += data[63-i*uDataLen-j];
                    }
                    audioData[i] /= (uDataLen * normalizing_ratio);
                }
                for(let i=dataLength; i<r_stop; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += data[i*uDataLen+j];
                    }
                    audioData[i] /= (uDataLen * normalizing_ratio);
                }
            }

            context.clearRect(0, 0, width+32, height+32);

            let _y;
            let _dy;
            //绘制频谱
            if(lineRotateFlag || centerRotateFlag) {
                context.transform(1, Math.sin(centerRotateFlag*centerRotateAngle), -Math.sin(lineRotateFlag*lineRotateAngle), 1, Math.sin(lineRotateFlag*lineRotateAngle)*(halfHeight-_y_dy), 0);
                context.fillStyle = line_color;
                for (let i=l_start; i<r_stop; i++) {
                    _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                    _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                    context.fillRect(_ux * (i-l_start), _y, _dx, _dy);
                }
                if (centerLineFlag) {
                    context.fillStyle = center_color;
                    context.fillRect(0, halfHeight-_y_dy, width, 2);
                }
                context.resetTransform();
            } else if (linePosition) {
                let _flag = 1-2*(linePosition===1);
                _y = halfHeight + halfHeight*(3-2*linePosition)*Boolean(linePosition);
                context.fillStyle = line_color;
                for (let i=l_start; i<r_stop; i++) {
                    _dy = height*audioData[i]*_flag;
                    context.fillRect(_ux * (i-l_start), _y, _dx, _dy);
                }
                if (centerLineFlag) {
                    context.fillStyle = center_color;
                    context.fillRect(0, _y-(2-linePosition)*2, width, 2);
                }
            } else {
                context.fillStyle = line_color;
                for (let i=l_start; i<r_stop; i++) {
                    _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                    _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                    context.fillRect(_ux * (i-l_start), _y, _dx, _dy);
                }
                if (centerLineFlag) {
                    context.fillStyle = center_color;
                    context.fillRect(0, halfHeight-_y_dy, width, 2);
                }
            }

            context.fill();
            requestPaint();
        }

        Component.onCompleted: {
            for (let i = 0; i < 128; i++) {
                audioData[i] = 0;
            }
        }
    }

    defaultValues: {
        "Version": "1.2.0",
        "Center Line": true,
        "Center Color": "#ff4500",
        "Line Color": "#ff4500",
        "Line Position": 0,
        "Data Length": 0,
        "Channel": 2,
        "Rotate Settings": {
            "Center Enable": false,
            "Center Angle": 10,
            "Line Enable": false,
            "Line Angle": 10
        },
        "Data Settings": {
            "Auto Normalizing": true,
            "Amplitude": 10,
            "Unit Style": 0
        }
    }

    preference: AdvpPreference {
        version: defaultValues["Version"]

        P.SwitchPreference {
            id: _cfg_preset_line_Center_Line
            name: "Center Line"
            label: qsTr("Show Center Line")
            defaultValue: defaultValues["Center Line"]
        }

        P.ColorPreference {
            name: "Center Color"
            label: qsTr("Center Line Color")
            enabled: _cfg_preset_line_Center_Line.value
            defaultValue: defaultValues["Center Color"]
        }

        P.Separator {}

        P.ColorPreference {
            name: "Line Color"
            label: qsTr("Spectrum Line Color")
            defaultValue: defaultValues["Line Color"]
        }

        P.SelectPreference {
            name: "Line Position"
            label: qsTr("Spectrum Line Position")
            defaultValue: defaultValues["Line Position"]
            model: [qsTr("Both"), qsTr("Up"), qsTr("Down")]
        }

        P.SelectPreference {
            name: "Data Length"
            label: qsTr("Spectrum Length")
            defaultValue: defaultValues["Data Length"]
            model: [64, 32, 16, 8]
        }

        P.SelectPreference {
            name: "Channel"
            label: qsTr("Channel")
            defaultValue: defaultValues["Channel"]
            model: [qsTr("Left Channel"), qsTr("Right Channel"), qsTr("Stereo")]
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
                defaultValue: defaultValues["Rotate Settings"]["Center Enable"]
            }

            P.SliderPreference {
                name: "Center Angle"
                label: qsTr("Angle of Center Line")
                enabled: _cfg_preset_line_Rotate_Center_Enable.value
                from: -45
                to: 45
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["Center Angle"]
                displayValue: value + "°"
            }

            P.Separator {}

            P.SwitchPreference {
                id: _cfg_preset_line_Rotate_Line_Enable
                name: "Line Enable"
                label: qsTr("Rotate Spectrum Line")
                defaultValue: defaultValues["Rotate Settings"]["Line Enable"]
            }

            P.SliderPreference {
                name: "Line Angle"
                label: qsTr("Angle of Spectrum Line")
                enabled: _cfg_preset_line_Rotate_Line_Enable.value
                from: -75
                to: 75
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["Line Angle"]
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
                defaultValue: defaultValues["Data Settings"]["Auto Normalizing"]
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
                defaultValue: defaultValues["Data Settings"]["Amplitude"]
            }

            P.Separator {}

            P.SelectPreference {
                name: "Unit Style"
                label: qsTr("Display Style")
                defaultValue: defaultValues["Data Settings"]["Unit Style"]
                model: [qsTr("Linear"), qsTr("Decibel")]
            }
        }
    }
}
