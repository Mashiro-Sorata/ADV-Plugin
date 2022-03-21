import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../qml/api"

StyleAPI {
    readonly property var audioData: new Array(128)

    readonly property real lineWidth: configs["Line Width"]
    readonly property string line_color: configs["Line Color"]
    readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
    readonly property real amplitude: configs["Data Settings"]["Amplitude"] / 400.0

    readonly property real ux: width/129
    readonly property real halfHeight: height/2

    onConfigsUpdated: {
        context.lineWidth = lineWidth;
        context.strokeStyle = line_color;
    }

    onAudioDataUpdeted: {
        data[128] *= 2;
        if(autoNormalizing) {
            //线性化显示
            for(let i=0; i<64; i++) {
                audioData[i] = data[64-i-1] / data[128];
            }
            for(let i=64; i<128; i++) {
                audioData[i] = data[i] / data[128];
            }
        } else {
            //线性化显示
            for(let i=0; i<64; i++) {
                audioData[i] = data[64-i-1] * amplitude;
            }
            for(let i=64; i<128; i++) {
                audioData[i] = data[i] * amplitude;
            }
        }

        context.clearRect(0, 0, width+32, height+32);

        context.beginPath();
        context.moveTo(0, halfHeight);
        for(let i=0; i<128; i+=2) {
            context.lineTo(ux*i, halfHeight*(1+audioData[i]));
            context.lineTo(ux*(i+1), halfHeight*(1-audioData[i+1]));
        }
        context.lineTo(width, halfHeight);
//        context.closePath();
        context.stroke();

        requestPaint();
    }

    Component.onCompleted: {
        for (let i = 0; i < 128; i++) {
            audioData[i] = 0;
        }
    }
}
