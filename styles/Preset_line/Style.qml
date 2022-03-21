import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../qml/api"

StyleAPI {
    readonly property var audioData: new Array(128)

    readonly property bool centerLineFlag: configs["Center Line"]
    readonly property string center_color: configs["Center Color"]
    readonly property string line_color: configs["Line Color"]
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
            context.fillStyle = center_color;
            context.fillRect(0, _y, width, 2);
        }



        context.fillStyle = line_color;

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
