import QtWebSockets 1.1

import "."


WebSocket {
    property string wsIp: "localhost"
    property int wsPort: 5050

    url: "ws://" + wsIp + ":" + wsPort
    active: true

    onStatusChanged: {
        if(status === WebSocket.Closed || status === WebSocket.Error) {
            Common.wsocketClosed();
        }
    }

    onBinaryMessageReceived: {
        let arrayBuffer = new Float32Array(message);
//        Common.audioData = arrayBuffer.slice();
        Common.audioDataUpdated(arrayBuffer.slice());
//        arrayBuffer = null;
    }
}
