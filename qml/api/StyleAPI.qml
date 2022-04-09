import QtQuick 2.12

import ".."      //显式导入单例Common.qml

Canvas {
    width: widget.width
    height: widget.height
    contextType: "2d"
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Cooperative

    signal audioDataUpdeted(var data)
    signal configsUpdated()
    property var configs: widget.settings[Common.stylesURL[widget.settings.styles["index"]]]

    onConfigsChanged: {
        if (context) {
            configsUpdated();
        }
    }

    onContextChanged: {
        if (context) {
            configsUpdated();
        }
    }

    Connections {
        enabled: Boolean(context)
        target: Common
        onAudioDataUpdated: audioDataUpdeted(audioData)
    }
}
