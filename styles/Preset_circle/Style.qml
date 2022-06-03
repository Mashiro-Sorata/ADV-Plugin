import QtQuick 2.12
import QtGraphicalEffects 1.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: Rectangle {
        id: main
        width: widget.width;
        height: widget.height;

        property int gradientStyle

        RadialGradient {
            id: radialGradient
            anchors.fill: parent
            visible: gradientStyle===1
            horizontalRadius: Math.min(width, height)/2
            verticalRadius: horizontalRadius
            gradient: Gradient {
                GradientStop {id: radialGradient_pstart}
                GradientStop {id: radialGradient_pmiddle}
                GradientStop {id: radialGradient_pend}
            }
        }

        ConicalGradient {
            id: conicalGradient
            anchors.fill: parent
            visible: gradientStyle===2
            angle: -90;
            gradient: Gradient {
                GradientStop{id: conicalGradient_pstart; position: 0.0}
                GradientStop{id: conicalGradient_pquarter; position: 0.25}
                GradientStop {id: conicalGradient_phalf; position: 0.5}
                GradientStop {id: conicalGradient_p3quarter; position: 0.75}
                GradientStop{id: conicalGradient_pend; position: 1.0}
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: AdvpCanvasTemplate {
                readonly property var audioData: new Array(128)

                //configs
                readonly property int linePosition: configs["Line Position"]
                readonly property real maxRange: configs["Max Range"] / 100
                readonly property int uDataLen: Math.pow(2, configs["Data Length"])
                readonly property int dataLength: 64/uDataLen
                readonly property int channel: configs["Channel"]
                readonly property bool reverse: configs["Reverse"]
                readonly property bool rotateFlag: configs["Rotate"]
                readonly property real rSpeed: configs["Ratate Speed"] / 100
                readonly property real angle: configs["Angle"]
                readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
                readonly property real amplitude: 400/configs["Data Settings"]["Amplitude"]
                readonly property int unitStyle: configs["Data Settings"]["Unit Style"]

                readonly property int total: channel*dataLength

                readonly property real dotGap: 360/total
                property real offsetAngle: 0
                property var outerPos: []
                property var innerPos: []
                readonly property real degUnit: Math.PI/180

                readonly property real subRatio: 0.2*maxRange
                readonly property real mainRatio: 1-subRatio*2.5

                readonly property real minLength: Math.min(width, height)
                readonly property real ratio:minLength*subRatio
                readonly property real halfWidth: width/2
                readonly property real halfHeight: height/2
                readonly property real halfMinLength: minLength/2


                onConfigsUpdated: {
                    gradientStyle = configs["Gradient Style"];
                    context.lineWidth = configs["Line Width"];
                    main.color = configs["Main Color"];
                    if (gradientStyle === 1) {
                        radialGradient_pstart.color = configs["Radial Gradient Settings"]["Inside Position Color"];
                        radialGradient_pstart.position = configs["Radial Gradient Settings"]["Inside Position"]/100;
                        radialGradient_pmiddle.color = configs["Radial Gradient Settings"]["Middle Position Color"];
                        radialGradient_pmiddle.position = configs["Radial Gradient Settings"]["Middle Position"]/100;
                        radialGradient_pend.color = configs["Radial Gradient Settings"]["Outside Position Color"];
                        radialGradient_pend.position = configs["Radial Gradient Settings"]["Outside Position"]/100;
                    } else if (gradientStyle === 2) {
                        conicalGradient_pstart.color = configs["Conical Gradient Settings"]["Start Position Color"];
                        conicalGradient_pquarter.color = configs["Conical Gradient Settings"]["Quarter Position Color"];
                        conicalGradient_phalf.color = configs["Conical Gradient Settings"]["Middle Position Color"];
                        conicalGradient_p3quarter.color = configs["Conical Gradient Settings"]["End Position Color"];
                        conicalGradient_pend.color = configs["Conical Gradient Settings"]["Start Position Color"];
                    }
                }

                function createPoint() {
                    outerPos.length = 0;
                    innerPos.length = 0;
                    let deg, deltaR, r1, r2, _rhmLen;
                    _rhmLen = mainRatio*halfMinLength;

                    for (let j=0; j < channel; j++) {
                        for (let i=0; i < dataLength; i++) {
                            deg = degUnit*((i+j*dataLength)*dotGap+offsetAngle);
                            deltaR = audioData[reverse*(dataLength-i-1)+(!reverse)*(i+j*dataLength)] * ratio;
                            r1 = _rhmLen+1+deltaR*(linePosition!==2);
                            r2 = _rhmLen-1-deltaR*(linePosition!==1);
                            outerPos.push([halfWidth+Math.cos(deg)*r1,halfHeight+Math.sin(deg)*r1]);
                            innerPos.push([halfWidth+Math.cos(deg)*r2,halfHeight+Math.sin(deg)*r2]);
                        }
                    }
                    conicalGradient.rotation = offsetAngle;
                    offsetAngle = rotateFlag ? ((offsetAngle + rSpeed) % 360) : angle;
                }

                onAudioDataUpdeted: {
                    let normalizing_ratio = autoNormalizing ? data[128] : amplitude;
                    if (unitStyle) {
                        //对数化显示
                        for(let i=0; i<total; i++) {
                            audioData[i] = 0;
                            for(let j=0; j<uDataLen; j++) {
                                audioData[i] += Math.max(0, 0.4 * (Math.log10(data[i*uDataLen+j]/normalizing_ratio)) + 1.0);
                            }
                            audioData[i] /= uDataLen;
                        }
                    } else {
                        //线性化显示
                        for(let i=0; i<total; i++) {
                            audioData[i] = 0;
                            for(let j=0; j<uDataLen; j++) {
                                audioData[i] += data[i*uDataLen+j];
                            }
                            audioData[i] /= (uDataLen * normalizing_ratio);
                        }
                    }

                    context.clearRect(0, 0, width+32, height+32);
                    createPoint();

                    context.beginPath();
                    for(let i=0; i<total; i++) {
                        context.moveTo(outerPos[i][0], outerPos[i][1]);
                        context.lineTo(innerPos[i][0], innerPos[i][1]);
                    }
                    context.stroke();
                    requestPaint();
                }

                onCompleted: {
                    for (let i = 0; i < 128; i++) {
                        audioData[i] = 0;
                    }
                }
            }
        }
    }

    defaultValues: {
        "Version": "1.2.0",
        "Gradient Style": 0,
        "Radial Gradient Settings": {
            "Inside Position Color": "#f44336",
            "Middle Position Color": "#4caf50",
            "Outside Position Color": "#03a9f4",
            "Inside Position": 40,
            "Middle Position": 60,
            "Outside Position": 80
        },
        "Conical Gradient Settings": {
            "Start Position Color": "#f44336",
            "Quarter Position Color": "#4caf50",
            "Middle Position Color": "#03a9f4",
            "End Position Color": "#ffeb3b"
        },
        "Main Color": "#ff4500",
        "Line Position": 0,
        "Line Width": 1,
        "Max Range": 80,
        "Data Length": 0,
        "Channel": 2,
        "Reverse": false,
        "Rotate": false,
        "Ratate Speed": 10,
        "Angle": 0,
        "Data Settings": {
            "Auto Normalizing": true,
            "Amplitude": 10,
            "Unit Style": 0
        }
    }

    preference: AdvpPreference {
        version: defaultValues["Version"]

        P.SelectPreference {
            id: _cfg_gradient_style
            name: "Gradient Style"
            label: qsTr("Gradient Style")
            defaultValue: defaultValues["Gradient Style"]
            model: [qsTr("None"), qsTr("Radial Gradient"), qsTr("Conical Gradient")]
        }

        P.DialogPreference {
            name: "Radial Gradient Settings"
            label: qsTr("Radial Gradient Settings")
            live: true
            visible: _cfg_gradient_style.value===1

            P.ColorPreference {
                name: "Inside Position Color"
                label: qsTr("Inside Position Color")
                defaultValue: defaultValues["Radial Gradient Settings"]["Inside Position Color"]
            }

            P.ColorPreference {
                name: "Middle Position Color"
                label: qsTr("Middle Position Color")
                defaultValue: defaultValues["Radial Gradient Settings"]["Middle Position Color"]
            }

            P.ColorPreference {
                name: "Outside Position Color"
                label: qsTr("Outside Position Color")
                defaultValue: defaultValues["Radial Gradient Settings"]["Outside Position Color"]
            }

            P.SliderPreference {
                id: _cfg_gradient_settings_inside_position
                name: "Inside Position"
                label: qsTr("Inside Position")
                from: 0
                to: 75
                stepSize: 1
                defaultValue: defaultValues["Radial Gradient Settings"]["Inside Position"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                id: _cfg_gradient_settings_middle_position
                name: "Middle Position"
                label: qsTr("Middle Position")
                from: _cfg_gradient_settings_inside_position.value + 1
                to: 90
                stepSize: 1
                defaultValue: defaultValues["Radial Gradient Settings"]["Middle Position"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                name: "Outside Position"
                label: qsTr("Outside Position")
                from: _cfg_gradient_settings_middle_position.value + 1
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Radial Gradient Settings"]["Outside Position"]
                displayValue: value + "%"
            }

        }

        P.DialogPreference {
            name: "Conical Gradient Settings"
            label: qsTr("Conical Gradient Settings")
            live: true
            visible: _cfg_gradient_style.value===2

            P.ColorPreference {
                name: "Start Position Color"
                label: qsTr("Start Position Color")
                defaultValue: defaultValues["Conical Gradient Settings"]["Start Position Color"]
            }

            P.ColorPreference {
                name: "Quarter Position Color"
                label: qsTr("Quarter Position Color")
                defaultValue: defaultValues["Conical Gradient Settings"]["Quarter Position Color"]
            }

            P.ColorPreference {
                name: "Middle Position Color"
                label: qsTr("Middle Position Color")
                defaultValue: defaultValues["Conical Gradient Settings"]["Middle Position Color"]
            }

            P.ColorPreference {
                name: "End Position Color"
                label: qsTr("End Position Color")
                defaultValue: defaultValues["Conical Gradient Settings"]["End Position Color"]
            }
        }

        P.ColorPreference {
            name: "Main Color"
            label: qsTr("Spectrum Line Color")
            visible: !_cfg_gradient_style.value
            defaultValue: defaultValues["Main Color"]
        }

        P.SelectPreference {
            name: "Line Position"
            label: qsTr("Spectrum Line Position")
            defaultValue: defaultValues["Line Position"]
            model: [qsTr("Both"), qsTr("Outside"), qsTr("Inside")]
        }

        P.SliderPreference {
            name: "Line Width"
            label: qsTr("Spectrum Line Width")
            from: 0.1
            to: 10
            stepSize: 0.1
            defaultValue: defaultValues["Line Width"]
            displayValue: value.toFixed(1) + "px"
        }

        P.SliderPreference {
            name: "Max Range"
            label: qsTr("Max Amplitude")
            from: 0
            to: 100
            stepSize: 1
            defaultValue: defaultValues["Max Range"]
            displayValue: value + "%"
        }

        P.SelectPreference {
            name: "Data Length"
            label: qsTr("Spectrum Length")
            defaultValue: defaultValues["Data Length"]
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
            defaultValue: defaultValues["Channel"]
        }

        P.SwitchPreference {
            name: "Reverse"
            label: qsTr("Reverse Spectrum")
            defaultValue: defaultValues["Reverse"]
        }

        P.Separator {}

        P.SwitchPreference {
            id: _cfg_preset_line_rotate
            name: "Rotate"
            label: qsTr("Auto Rotate")
            defaultValue: defaultValues["Rotate"]
        }

        P.SliderPreference {
            name: "Ratate Speed"
            label: qsTr("Ratate Speed")
            enabled: _cfg_preset_line_rotate.value
            from: 1
            to: 100
            stepSize: 1
            defaultValue: defaultValues["Ratate Speed"]
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
            defaultValue: defaultValues["Angle"]
        }

        P.Separator {}

        P.DialogPreference {
            name: "Data Settings"
            label: qsTr("Data Settings")
            live: true
            icon.name: "regular:\uf1de"

            P.SwitchPreference {
                id: _cfg_preset_circle_dataSettings_autoNormalizing
                name: "Auto Normalizing"
                label: qsTr("Auto Normalizing")
                defaultValue: defaultValues["Data Settings"]["Auto Normalizing"]
            }

            P.SpinPreference {
                name: "Amplitude"
                label: qsTr("Amplitude Ratio")
                enabled: !_cfg_preset_circle_dataSettings_autoNormalizing.value
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
