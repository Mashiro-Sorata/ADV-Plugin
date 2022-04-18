import QtQuick 2.12
import QtGraphicalEffects 1.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: Rectangle {
        width: widget.width;
        height: widget.height;

        LinearGradient {
            id: gradient_mask
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { id: p_start;  position: 0.0 }
                GradientStop { id: p_middle;  position: 0.5 }
                GradientStop { id: p_end; position: 1.0 }
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: AdvpCanvasTemplate {
                readonly property var audioData: new Array(128)

                readonly property bool centerLineFlag: configs["Center Line"]
                readonly property int linePosition: configs["Line Position"]
                readonly property int uDataLen: Math.pow(2, configs["Data Length"]);
                readonly property int dataLength: 64/uDataLen
                readonly property int channel: configs["Channel"]
                readonly property bool reverse: configs["Reverse"]
                readonly property bool centerRotateFlag: configs["Rotate Settings"]["Center Enable"]
                readonly property real centerRotateAngle: configs["Rotate Settings"]["Center Angle"]
                readonly property bool lineRotateFlag: configs["Rotate Settings"]["Line Enable"]
                readonly property real lineRotateAngle: configs["Rotate Settings"]["Line Angle"]
                readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
                readonly property real amplitude: configs["Data Settings"]["Amplitude"] / 400.0
                readonly property int unitStyle: configs["Data Settings"]["Unit Style"]

                property int total: channel * dataLength
                property real logAmplitude: Math.log10(amplitude)
                property real degUnit: Math.PI / 180

                property real halfWidth: width/2
                property real halfHeight: height/2

                onConfigsUpdated: {
                    context.fillStyle = "black";
                    gradient_mask.start = Qt.point(0, height*(configs["Gradient Direction"]===2))
                    gradient_mask.end = Qt.point(width*(configs["Gradient Direction"]!==1), height*(configs["Gradient Direction"]%2))
                    p_start.color = configs["Start Position Color"];
                    p_middle.color = configs["Middle Position Color"];
                    p_end.color = configs["End Position Color"];
                }

                onAudioDataUpdeted: {
                    if(autoNormalizing) {
                        if (unitStyle) {
                            //对数化显示
                            for(let i=0; i<dataLength; i++) {
                                audioData[i] = 0;
                                for(let j=0; j<uDataLen; j++) {
                                    audioData[i] += Math.max(0, 0.4 * (Math.log10(data[64-i*uDataLen-j-1]/data[128])) + 1.0);
                                }
                                audioData[i] /= uDataLen;
                            }
                            if (channel === 2) {
                                for(let i=dataLength; i<total; i++) {
                                    audioData[i] = 0;
                                    for(let j=0; j<uDataLen; j++) {
                                        audioData[i] += Math.max(0, 0.4 * (Math.log10(data[64+(i-dataLength)*uDataLen+j]/data[128])) + 1.0);
                                    }
                                    audioData[i] /= uDataLen;
                                }
                            }
                        } else {
                            //线性化显示
                            for(let i=0; i<dataLength; i++) {
                                audioData[i] = 0;
                                for(let j=0; j<uDataLen; j++) {
                                    audioData[i] += data[64-i*uDataLen-j-1];
                                }
                                audioData[i] /= (uDataLen * data[128]);
                            }
                            if (channel === 2) {
                                for(let i=dataLength; i<total; i++) {
                                    audioData[i] = 0;
                                    for(let j=0; j<uDataLen; j++) {
                                        audioData[i] += data[64+(i-dataLength)*uDataLen+j];
                                    }
                                    audioData[i] /= (uDataLen * data[128]);
                                }
                            }
                        }
                    } else {
                        if (unitStyle) {
                            //对数化显示
                            for(let i=0; i<dataLength; i++) {
                                audioData[i] = 0;
                                for(let j=0; j<uDataLen; j++) {
                                    audioData[i] += Math.max(0, 0.35 * (Math.log10(data[64-i*uDataLen-j-1])+logAmplitude) + 1.0);
                                }
                                audioData[i] /= uDataLen;
                            }
                            if (channel === 2) {
                                for(let i=dataLength; i<total; i++) {
                                    audioData[i] = 0;
                                    for(let j=0; j<uDataLen; j++) {
                                        audioData[i] += Math.max(0, 0.35 * (Math.log10(data[64+(i-dataLength)*uDataLen+j])+logAmplitude) + 1.0);
                                    }
                                    audioData[i] /= uDataLen;
                                }
                            }
                        } else {
                            //线性化显示
                            for(let i=0; i<dataLength; i++) {
                                audioData[i] = 0;
                                for(let j=0; j<uDataLen; j++) {
                                    audioData[i] += data[64-i*uDataLen-j-1];
                                }
                                audioData[i] /= (uDataLen/amplitude);
                            }
                            if (channel === 2) {
                                for(let i=dataLength; i<total; i++) {
                                    audioData[i] = 0;
                                    for(let j=0; j<uDataLen; j++) {
                                        audioData[i] += data[64+(i-dataLength)*uDataLen+j];
                                    }
                                    audioData[i] /= (uDataLen/amplitude);
                                }
                            }
                        }
                    }
                    let _dy;
                    let _y_dy = centerRotateFlag*Math.tan(centerRotateAngle*degUnit)*halfWidth;
                    let _ux = width/total;
                    let _dx = Math.round(_ux/2);
                    let _y = halfHeight-_y_dy

                    context.clearRect(0, 0, width+32, height+32);

                    if(lineRotateFlag || centerRotateFlag) {
                        context.transform(1, centerRotateFlag*centerRotateAngle * degUnit, -lineRotateFlag*lineRotateAngle * degUnit, 1, lineRotateFlag*Math.sin(1.05*lineRotateAngle*degUnit)*_y, 0);
                    }

                    if (centerLineFlag) {
                        context.fillRect(0, _y, width, 2);
                    }

                    //绘制频谱
                    if (channel === 1 && reverse) {
                        for (let i = 0; i < dataLength; i++) {
                            let index = dataLength - i - 1;
                            _y = halfHeight*(1-(linePosition!==2)*audioData[index])-_y_dy;
                            _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[index];
                            context.fillRect(_ux * i, _y, _dx, _dy);
                        }
                    } else {
                        for (let j = 0; j < channel; j++) {
                            for (let i = 0; i < dataLength; i++) {
                                let index = j ? ((total - dataLength) + i) : i;
                                _y = halfHeight*(1-(linePosition!==2)*audioData[index])-_y_dy;
                                _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[index];
                                context.fillRect(_ux * (i + j * dataLength), _y, _dx, _dy);
                            }
                        }
                    }

                    if (centerRotateFlag || lineRotateFlag)
                        context.resetTransform();

                    context.fill();

                    requestPaint();
                }

                Component.onCompleted: {
                    for (let i = 0; i < 128; i++) {
                        audioData[i] = 0;
                    }
                }
            }
        }
    }

    defaultValues: {
        "Version": "1.0.0",
        "Gradient Direction": 0,
        "Start Position Color": "#f44336",
        "Middle Position Color": "#4caf50",
        "End Position Color": "#03a9f4",
        "Center Line": true,
        "Line Position": 0,
        "Data Length": 0,
        "Channel": 2,
        "Reverse": false,
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
        cfg_height: 670

        P.SelectPreference {
            name: "Gradient Direction"
            label: qsTr("Gradient Direction")
            defaultValue: defaultValues["Gradient Direction"]
            model: [qsTr("Horizontal"), qsTr("Vertical"), qsTr("Oblique Upward"), qsTr("Oblique downward")]
        }

        P.ColorPreference {
            name: "Start Position Color"
            label: qsTr("Start Position Color")
            defaultValue: defaultValues["Start Position Color"]
        }

        P.ColorPreference {
            name: "Middle Position Color"
            label: qsTr("Middle Position Color")
            defaultValue: defaultValues["Middle Position Color"]
        }

        P.ColorPreference {
            name: "End Position Color"
            label: qsTr("End Position Color")
            defaultValue: defaultValues["End Position Color"]
        }

        P.Separator {}

        P.SwitchPreference {
            name: "Center Line"
            label: qsTr("Show Center Line")
            defaultValue: defaultValues["Center Line"]
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
            defaultValue: defaultValues["Channel"]
        }

        P.SwitchPreference {
            name: "Reverse"
            label: qsTr("Reverse Spectrum")
            enabled: _cfg_preset_line_Channel.value === 1
            defaultValue: defaultValues["Reverse"]
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
