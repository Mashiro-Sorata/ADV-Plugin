import QtWebSockets 1.1

import "."


WebSocket {
    url: "ws://" + Common.wsIp + ":" + Common.wsPort
    active: true

    onStatusChanged: {
        if(status === WebSocket.Closed || status === WebSocket.Error) {
            Common.rebootFlag = true;
        }
    }

    onBinaryMessageReceived: {
        let arrayBuffer = new Float32Array(message);
        Common.audioDataUpdated(arrayBuffer.slice());
    }
}
