import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../qml/api"

StyleAPI {
    readonly property var audioData: new Array(128)

    //configs
    readonly property string color: configs["Main Color"]
    readonly property int linePosition: configs["Line Position"]
    readonly property real lineWidth: configs["Line Width"]
    readonly property real maxRange: configs["Max Range"] / 100
    readonly property int uDataLen: Math.pow(2, configs["Data Length"])
    readonly property int dataLength: 64/uDataLen
    readonly property int channel: configs["Channel"]
    readonly property bool reverse: configs["Reverse"]
    readonly property bool rotateFlag: configs["Rotate"]
    readonly property real rSpeed: configs["Ratate Speed"] / 100
    readonly property real angle: configs["Angle"]
    readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
    readonly property real amplitude: configs["Data Settings"]["Amplitude"] / 400
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
    readonly property real logAmplitude: Math.log10(amplitude)


    onConfigsUpdated: {
        context.lineWidth = lineWidth;
        context.strokeStyle = color;
    }

    function getPos(r, deg) {
        return [halfWidth+Math.cos(deg)*r,halfHeight+Math.sin(deg)*r];
    }

    function createPoint() {
        outerPos = [];
        innerPos = [];
        let deg, deltaR, r1, r2, _rhmLen;
        _rhmLen = mainRatio*halfMinLength;

        for (let j=0; j < channel; j++) {
            for (let i=0; i < dataLength; i++) {
                deg = degUnit*((i+j*dataLength)*dotGap + offsetAngle);
                deltaR = audioData[reverse*(dataLength-i-1)+(!reverse)*(i+j*dataLength)] * ratio;
                r1 = _rhmLen+1+deltaR*(linePosition!==2);
                r2 = _rhmLen-1-deltaR*(linePosition!==1);
                outerPos.push(getPos(r1, deg));
                innerPos.push(getPos(r2, deg));
            }
        }
        offsetAngle = rotateFlag ? ((offsetAngle + rSpeed) % 360) : angle;
    }

    onAudioDataUpdeted: {
        if(autoNormalizing) {
            if (unitStyle) {
                //对数化显示
                let logPeak = Math.log10(data[128]);
                for(let i=0; i<total; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += Math.max(0, 0.4 * (Math.log10(data[i*uDataLen+j])-logPeak) + 1.0);
                    }
                    audioData[i] /= uDataLen;
                }
            } else {
                //线性化显示
                for(let i=0; i<total; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += data[i*uDataLen+j] / data[128];
                    }
                    audioData[i] /= uDataLen;
                }
            }
        } else {
            if (unitStyle) {
                //对数化显示
                for(let i=0; i<total; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += Math.max(0, 0.35 * (Math.log10(data[i*uDataLen+j])+logAmplitude) + 1.0);
                    }
                    audioData[i] /= uDataLen;
                }
            } else {
                //线性化显示
                for(let i=0; i<total; i++) {
                    audioData[i] = 0;
                    for(let j=0; j<uDataLen; j++) {
                        audioData[i] += data[i*uDataLen+j] * amplitude;
                    }
                    audioData[i] /= uDataLen;
                }
            }
        }

        context.clearRect(0, 0, width, height);
        createPoint();

        context.beginPath();
        context.moveTo(outerPos[0][0], outerPos[0][1]);
        for(let i=0; i<total; i++) {
            context.lineTo(outerPos[i][0], outerPos[i][1]);
        }
        context.closePath();
        context.stroke();

        context.beginPath();
        context.moveTo(innerPos[0][0], innerPos[0][1]);
        for(let i=0; i<total; i++) {
            context.lineTo(innerPos[i][0], innerPos[i][1]);
        }
        context.closePath();
        context.stroke();

        context.beginPath();
        for(let i=0; i<total; i++) {
            context.moveTo(outerPos[i][0], outerPos[i][1]);
            context.lineTo(innerPos[i][0], innerPos[i][1]);
        }
        context.stroke();
        requestPaint();
    }

    Component.onCompleted: {
        for (let i = 0; i < 128; i++) {
            audioData[i] = 0;
        }
    }
}
