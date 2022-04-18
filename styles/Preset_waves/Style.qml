import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: AdvpCanvasTemplate {
        readonly property var audioData: new Array(128)

        readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
        readonly property real amplitude: configs["Data Settings"]["Amplitude"] / 400.0

        readonly property int uDataLen: Math.pow(2, configs["Data Length"]);
        readonly property int dataLength: 64/uDataLen
        readonly property int unitStyle: configs["Data Settings"]["Unit Style"]

        readonly property int total: dataLength*2

        readonly property real ux: width/(total+1)
        readonly property real halfHeight: height/2

        onConfigsUpdated: {
            //尽量不要使用绑定configs的属性以免造成竞争，若一定要使用推荐使用Qt.callLater(()=>{})
            context.lineWidth = configs["Line Width"];
            context.strokeStyle = configs["Line Color"];
        }

        onAudioDataUpdeted: {
            data[128] *= 2;
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
                    for(let i=dataLength; i<total; i++) {
                        audioData[i] = 0;
                        for(let j=0; j<uDataLen; j++) {
                            audioData[i] += Math.max(0, 0.4 * (Math.log10(data[64+(i-dataLength)*uDataLen+j]/data[128])) + 1.0);
                        }
                        audioData[i] /= uDataLen;
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
                    for(let i=dataLength; i<total; i++) {
                        audioData[i] = 0;
                        for(let j=0; j<uDataLen; j++) {
                            audioData[i] += data[64+(i-dataLength)*uDataLen+j];
                        }
                        audioData[i] /= (uDataLen * data[128]);
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
                    for(let i=dataLength; i<total; i++) {
                        audioData[i] = 0;
                        for(let j=0; j<uDataLen; j++) {
                            audioData[i] += Math.max(0, 0.35 * (Math.log10(data[64+(i-dataLength)*uDataLen+j])+logAmplitude) + 1.0);
                        }
                        audioData[i] /= uDataLen;
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
                    for(let i=dataLength; i<total; i++) {
                        audioData[i] = 0;
                        for(let j=0; j<uDataLen; j++) {
                            audioData[i] += data[64+(i-dataLength)*uDataLen+j];
                        }
                        audioData[i] /= (uDataLen/amplitude);
                    }
                }
            }

            context.clearRect(0, 0, width+32, height+32);

            context.beginPath();
            context.moveTo(0, halfHeight);

            for (let i=0; i<dataLength*2; i+=2) {
                context.lineTo(ux*i, halfHeight*(1+audioData[i]));
                context.lineTo(ux*(i+1), halfHeight*(1-audioData[i+1]));
            }

            context.lineTo(width, halfHeight);
            context.stroke();

            requestPaint();
        }

        Component.onCompleted: {
            for (let i = 0; i < 128; i++) {
                audioData[i] = 0;
            }
        }
    }

    defaultValues: {
        "Version": "1.1.0",
        "Line Width": 1,
        "Line Color": "#ff4500",
        "Data Length": 0,
        "Data Settings": {
            "Auto Normalizing": true,
            "Amplitude": 10,
            "Unit Style": 0
        }
    }

    preference: AdvpPreference {
        version: defaultValues["Version"]
        cfg_height: 400

        P.SliderPreference {
            name: "Line Width"
            label: qsTr("Spectrum Line Width")
            from: 0.1
            to: 4
            stepSize: 0.1
            defaultValue: defaultValues["Line Width"]
            displayValue: value.toFixed(1) + "px"
        }

        P.ColorPreference {
            name: "Line Color"
            label: qsTr("Spectrum Line Color")
            defaultValue: defaultValues["Line Color"]
        }

        P.Separator {}

        P.SelectPreference {
            name: "Data Length"
            label: qsTr("Spectrum Length")
            defaultValue: defaultValues["Data Length"]
            model: [64, 32, 16, 8]
        }

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
