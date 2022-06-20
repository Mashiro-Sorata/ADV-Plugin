import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Shapes 1.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: Shape {
        width: widget.width
        height: widget.height

        property int gradientStyle

        LinearGradient {
            id: linearGradient
            GradientStop { id: p_start; color: "transparent"; position: 0.0 }
            GradientStop { id: p_middle; color: "transparent"; position: 0.5 }
            GradientStop { id: p_end; color: "transparent"; position: 1.0 }
        }

        LinearGradient {
            id: pureGradient
            GradientStop { color: main_color}
        }

        RadialGradient {
            id: radialGradient
            centerX: widget.width/2*(1+radialGradient_xOffset/100)
            centerY: widget.height/2*(1+radialGradient_yOffset/100)
            focalX: centerX
            focalY: centerY
            centerRadius: Math.max(width, height)/2
            GradientStop {id: radialGradient_pstart; color: "transparent"}
            GradientStop {id: radialGradient_pmiddle; color: "transparent"}
            GradientStop {id: radialGradient_pend; color: "transparent"}
        }

        ShapePath {
            id: main
            fillGradient: [pureGradient, linearGradient, radialGradient][gradientStyle]
            startX: -1
            startY: -1
            PathLine { x: widget.width+1; y: -1 }
            PathLine { x: widget.width+1; y: widget.height+1 }
            PathLine { x: -1; y: widget.height+1 }
        }

        property bool centerLineFlag
        property string center_color
        property real center_width
        property int linePosition
        property string main_color: "transparent"
        property bool vertical_flag
        property real _y_dy
        property real radialGradient_xOffset
        property real radialGradient_yOffset

        Canvas {
            id: centerLine
            anchors.fill: parent
            contextType: "2d"
            renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Cooperative
            visible: centerLineFlag && !gradientStyle
            onPaint: {
                context.clearRect(0, 0, width+32, height+32);
                context.fillStyle = center_color;
                if (vertical_flag) {
                    if (linePosition) {
                        let _y = width/2 + width/2*(3-2*linePosition)*Boolean(linePosition);
                        context.fillRect(_y+(linePosition-2)*center_width, 0, center_width, height);
                    } else {
                        context.fillRect(width/2-_y_dy-center_width/2, 0, center_width, width);
                    }
                } else {
                    if (linePosition) {
                        let _y = height/2 + height/2*(3-2*linePosition)*Boolean(linePosition);
                        context.fillRect(0, _y+(linePosition-2)*center_width, width, center_width);
                    } else {
                        context.fillRect(0, height/2-_y_dy-center_width/2, width, center_width);
                    }
                }
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource: AdvpCanvasTemplate {
                readonly property var audioData: new Array(128)

                readonly property string line_color: configs["Line Color"]
                readonly property int uDataLen: Math.pow(2, configs["Data Length"]);
                readonly property int dataLength: 64/uDataLen
                readonly property int channel: configs["Channel"]
                readonly property bool centerRotateFlag: configs["Rotate Settings"]["Center Enable"]
                readonly property real centerRotateAngleTangent: centerRotateFlag*Math.tan(configs["Rotate Settings"]["Center Angle"]*Math.PI/180)
                readonly property bool lineRotateFlag: configs["Rotate Settings"]["Line Enable"]
                readonly property real lineRotateAngleTangent: lineRotateFlag*Math.tan(configs["Rotate Settings"]["Line Angle"]*Math.PI/180)
                readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
                readonly property real amplitude: 400.0/configs["Data Settings"]["Amplitude"]
                readonly property int unitStyle: configs["Data Settings"]["Unit Style"]

                readonly property real xOffset: configs["Rotate Settings"]["X Offset"]/100
                readonly property real yOffset: configs["Rotate Settings"]["Y Offset"]/100
                readonly property real xScale: configs["Rotate Settings"]["X Scale"]/100
                readonly property real yScale: configs["Rotate Settings"]["Y Scale"]/100

                readonly property real halfWidth: vertical_flag ? height/2 : width/2
                readonly property real halfHeight: vertical_flag ? width/2 : height/2

                readonly property int l_start: (channel===1)*dataLength
                readonly property int r_stop: dataLength+dataLength*(channel!==0)
                readonly property int total: r_stop-l_start
                readonly property real _ux: halfWidth*2/(r_stop-l_start)
                readonly property real _dx: Math.round(_ux/2)

                onWidthChanged: {
                    if (gradientStyle === 1) {
                        linearGradient.x2 = width*(configs["Linear Gradient Settings"]["Gradient Direction"]!==1);
                        linearGradient.y2 = height*(configs["Linear Gradient Settings"]["Gradient Direction"]%2);
                    }
                    centerLine.requestPaint();
                }

                onHeightChanged: {
                    if (gradientStyle === 1) {
                        linearGradient.x1 = 0;
                        linearGradient.y1 = height*(configs["Linear Gradient Settings"]["Gradient Direction"]===2);
                        linearGradient.x2 = width*(configs["Linear Gradient Settings"]["Gradient Direction"]!==1);
                        linearGradient.y2 = height*(configs["Linear Gradient Settings"]["Gradient Direction"]%2);
                    }
                    centerLine.requestPaint();
                }

                onConfigsUpdated: {
                    //尽量不要使用绑定configs的属性以免造成竞争，若一定要使用推荐使用Qt.callLater(()=>{})
                    centerLineFlag = configs["Center Line"];
                    center_color = configs["Center Color"];
                    center_width = configs["Center Width"]/10;
                    linePosition = configs["Line Position"];
                    vertical_flag = configs["Direction"];
                    gradientStyle = configs["Gradient Style"];
                    context.lineWidth = configs["Line Width"];
                    main_color = configs["Line Color"];
                    _y_dy = configs["Rotate Settings"]["Center Enable"]*Math.tan(configs["Rotate Settings"]["Center Angle"]*Math.PI/180)*(vertical_flag ? height/2 : width/2);
                    if (gradientStyle === 1) {
                        linearGradient.x1 = 0;
                        linearGradient.y1 = height*(configs["Linear Gradient Settings"]["Gradient Direction"]===2);
                        linearGradient.x2 = width*(configs["Linear Gradient Settings"]["Gradient Direction"]!==1);
                        linearGradient.y2 = height*(configs["Linear Gradient Settings"]["Gradient Direction"]%2);
                        p_start.color = configs["Linear Gradient Settings"]["Start Position Color"];
                        p_middle.color = configs["Linear Gradient Settings"]["Middle Position Color"];
                        p_end.color = configs["Linear Gradient Settings"]["End Position Color"];
                    } else if (gradientStyle === 2) {
                        radialGradient_pstart.color = configs["Radial Gradient Settings"]["Inside Position Color"];
                        radialGradient_pstart.position = configs["Radial Gradient Settings"]["Inside Position"]/100;
                        radialGradient_pmiddle.color = configs["Radial Gradient Settings"]["Middle Position Color"];
                        radialGradient_pmiddle.position = configs["Radial Gradient Settings"]["Middle Position"]/100;
                        radialGradient_pend.color = configs["Radial Gradient Settings"]["Outside Position Color"];
                        radialGradient_pend.position = configs["Radial Gradient Settings"]["Outside Position"]/100;
                        radialGradient_xOffset = configs["Radial Gradient Settings"]["Center X Offset"];
                        radialGradient_yOffset = configs["Radial Gradient Settings"]["Center Y Offset"];
                    }
                    centerLine.requestPaint();
                }

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
                    if (vertical_flag) {
                        if(lineRotateFlag || centerRotateFlag) {
                            context.transform(yScale, lineRotateAngleTangent, -centerRotateAngleTangent, xScale, 2*_y_dy+yOffset*height, xOffset*width-lineRotateAngleTangent*(halfHeight-_y_dy));
                            context.fillStyle = line_color;
                            for (let i=l_start; i<r_stop; i++) {
                                _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                                _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                                context.fillRect(_y, _ux * (i-l_start), _dy, _dx);
                            }
                            if (centerLineFlag) {
                                context.fillRect(halfHeight-_y_dy-center_width/2, 0, center_width, height);
                            }
                            context.resetTransform();
                        } else if (linePosition) {
                            let _flag = 1-2*(linePosition===1);
                            _y = halfHeight + halfHeight*(3-2*linePosition)*Boolean(linePosition);
                            context.fillStyle = line_color;
                            for (let i=l_start; i<r_stop; i++) {
                                _dy = width*audioData[i]*_flag;
                                context.fillRect(_y, _ux * (i-l_start), _dy, _dx);
                            }
                            if (centerLineFlag) {
                                context.fillRect(_y+(linePosition-2)*center_width, 0, center_width, height);
                            }
                        } else {
                            context.fillStyle = line_color;
                            for (let i=l_start; i<r_stop; i++) {
                                _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                                _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                                context.fillRect(_y, _ux * (i-l_start), _dy, _dx);
                            }
                            if (centerLineFlag) {
                                context.fillRect(halfHeight-_y_dy-center_width/2, 0, center_width, height);
                            }
                        }
                    } else {
                        //绘制频谱
                        if(lineRotateFlag || centerRotateFlag) {
                            context.transform(xScale, centerRotateAngleTangent, -lineRotateAngleTangent, yScale, xOffset*width+lineRotateAngleTangent*(halfHeight-_y_dy), yOffset*height);
                            context.fillStyle = line_color;
                            for (let i=l_start; i<r_stop; i++) {
                                _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                                _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                                context.fillRect(_ux * (i-l_start), _y, _dx, _dy);
                            }
                            if (centerLineFlag) {
                                context.fillRect(0, halfHeight-_y_dy-center_width/2, width, center_width);
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
                                context.fillRect(0, _y+(linePosition-2)*center_width, width, center_width);
                            }
                        } else {
                            context.fillStyle = line_color;
                            for (let i=l_start; i<r_stop; i++) {
                                _y = halfHeight*(1-(linePosition!==2)*audioData[i])-_y_dy;
                                _dy = (halfHeight + (!linePosition)*halfHeight)*audioData[i];
                                context.fillRect(_ux * (i-l_start), _y, _dx, _dy);
                            }
                            if (centerLineFlag) {
                                context.fillRect(0, halfHeight-_y_dy-center_width/2, width, center_width);
                            }
                        }
                    }
                    context.fill();
                    requestPaint();
                }

                onCompleted: {
                    for (let i = 0; i < 128; i++) {
                        audioData[i] = 0;
                    }
                }

                onVersionUpdated: {
                    //1.2.0 -> 1.3.0
                    if (widget.settings.current_style === "nvg://advp.widget.mashiros.top/advp-style-preset/gradient_line") {
                        widget.settings.current_style = "nvg://advp.widget.mashiros.top/advp-style-preset/line";
                        widget.settings[widget.settings.current_style] = updateObject(widget.settings["nvg://advp.widget.mashiros.top/advp-style-preset/gradient_line"], widget.settings[widget.settings.current_style]);
                        widget.settings[widget.settings.current_style]["Enable Gradient"] = 1;
                    }
                    //1.3.0 -> 1.3.2
                    if(widget.settings[widget.settings.current_style]["Gradient Style"] === undefined) {
                        if (widget.settings[widget.settings.current_style]["Enable Gradient"] === undefined) {
                            widget.settings[widget.settings.current_style]["Gradient Style"] = 0;
                        } else {
                            widget.settings[widget.settings.current_style]["Gradient Style"] = widget.settings[widget.settings.current_style]["Enable Gradient"]+0;
                        }
                        widget.settings[widget.settings.current_style]["Linear Gradient Settings"] = {
                            "Gradient Direction": widget.settings[widget.settings.current_style]["Gradient Direction"],
                            "Start Position Color": widget.settings[widget.settings.current_style]["Start Position Color"],
                            "Middle Position Color": widget.settings[widget.settings.current_style]["Middle Position Color"],
                            "End Position Color": widget.settings[widget.settings.current_style]["End Position Color"]
                        };
                    }
                    updateConfiguration();
                }
            }
        }
    }

    defaultValues: {
        "Version": "1.3.2",
        "Gradient Style": 0,
        "Linear Gradient Settings": {
            "Gradient Direction": 0,
            "Start Position Color": "#f44336",
            "Middle Position Color": "#4caf50",
            "End Position Color": "#03a9f4"
        },
        "Radial Gradient Settings": {
            "Inside Position Color": "#f44336",
            "Middle Position Color": "#4caf50",
            "Outside Position Color": "#03a9f4",
            "Inside Position": 0,
            "Middle Position": 50,
            "Outside Position": 100,
            "Center X Offset": 0,
            "Center Y Offset": 0
        },
        "Center Line": true,
        "Center Color": "#ff4500",
        "Center Width": 20,
        "Line Color": "#ff4500",
        "Line Position": 0,
        "Data Length": 0,
        "Channel": 2,
        "Direction": 0,
        "Rotate Settings": {
            "Center Enable": false,
            "Center Angle": 10,
            "Line Enable": false,
            "Line Angle": 10,
            "X Scale": 100,
            "Y Scale": 100,
            "X Offset": 0,
            "Y Offset": 0
        },
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
            model: [qsTr("None"), qsTr("Linear Gradient"), qsTr("Radial Gradient")]
        }

        P.DialogPreference {
            name: "Linear Gradient Settings"
            label: qsTr("Linear Gradient Settings")
            live: true
            visible: _cfg_gradient_style.value===1

            P.SelectPreference {
                name: "Gradient Direction"
                label: qsTr("Gradient Direction")
                defaultValue: defaultValues["Linear Gradient Settings"]["Gradient Direction"]
                model: [qsTr("Horizontal"), qsTr("Vertical"), qsTr("Oblique Upward"), qsTr("Oblique downward")]
            }

            P.ColorPreference {
                name: "Start Position Color"
                label: qsTr("Start Position Color")
                defaultValue: defaultValues["Linear Gradient Settings"]["Start Position Color"]
            }

            P.ColorPreference {
                name: "Middle Position Color"
                label: qsTr("Middle Position Color")
                defaultValue: defaultValues["Linear Gradient Settings"]["Middle Position Color"]
            }

            P.ColorPreference {
                name: "End Position Color"
                label: qsTr("End Position Color")
                defaultValue: defaultValues["Linear Gradient Settings"]["End Position Color"]
            }
        }

        P.DialogPreference {
            name: "Radial Gradient Settings"
            label: qsTr("Radial Gradient Settings")
            live: true
            visible: _cfg_gradient_style.value===2

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

            P.SliderPreference {
                name: "Center X Offset"
                label: qsTr("X Offset")
                from: -100
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Radial Gradient Settings"]["Center X Offset"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                name: "Center Y Offset"
                label: qsTr("Y Offset")
                from: -100
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Radial Gradient Settings"]["Center Y Offset"]
                displayValue: value + "%"
            }
        }

        P.Separator {}

        P.SwitchPreference {
            id: _cfg_preset_line_Center_Line
            name: "Center Line"
            label: qsTr("Show Center Line")
            defaultValue: defaultValues["Center Line"]
        }

        P.ColorPreference {
            name: "Center Color"
            label: qsTr("Center Line Color")
            visible: !_cfg_gradient_style.value && _cfg_preset_line_Center_Line.value
            defaultValue: defaultValues["Center Color"]
        }

        P.SliderPreference {
            name: "Center Width"
            label: qsTr("Center Line Width")
            visible: _cfg_preset_line_Center_Line.value
            from: 1
            to: 100
            stepSize: 1
            defaultValue: defaultValues["Center Width"]
            displayValue: value + "%"
        }

        P.Separator {}

        P.SelectPreference {
            id: _cfg_direction
            name: "Direction"
            label: qsTr("Direction")
            defaultValue: defaultValues["Direction"]
            model: [qsTr("Horizontal"), qsTr("Vertical")]
        }

        P.ColorPreference {
            name: "Line Color"
            label: qsTr("Spectrum Line Color")
            visible: !_cfg_gradient_style.value
            defaultValue: defaultValues["Line Color"]
        }

        P.SelectPreference {
            name: "Line Position"
            label: qsTr("Spectrum Line Position")
            defaultValue: defaultValues["Line Position"]
            model: [qsTr("Both"), [qsTr("Up"), qsTr("Left")][_cfg_direction.value], [qsTr("Down"), qsTr("Right")][_cfg_direction.value]]
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
                from: -45
                to: 45
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["Line Angle"]
                displayValue: value + "°"
            }

            P.Separator {}

            P.SliderPreference {
                name: "X Scale"
                label: qsTr("Scale of Center Line Direction")
                enabled: _cfg_preset_line_Rotate_Line_Enable.value || _cfg_preset_line_Rotate_Center_Enable.value
                from: 1
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["X Scale"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                name: "Y Scale"
                label: qsTr("Scale of Spectrum Line Direction")
                enabled: _cfg_preset_line_Rotate_Line_Enable.value || _cfg_preset_line_Rotate_Center_Enable.value
                from: 1
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["Y Scale"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                name: "X Offset"
                label: qsTr("Offset of Center Line Direction")
                enabled: _cfg_preset_line_Rotate_Line_Enable.value || _cfg_preset_line_Rotate_Center_Enable.value
                from: -100
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["X Offset"]
                displayValue: value + "%"
            }

            P.SliderPreference {
                name: "Y Offset"
                label: qsTr("Offset of Spectrum Line Direction")
                enabled: _cfg_preset_line_Rotate_Line_Enable.value || _cfg_preset_line_Rotate_Center_Enable.value
                from: -100
                to: 100
                stepSize: 1
                defaultValue: defaultValues["Rotate Settings"]["Y Offset"]
                displayValue: value + "%"
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
