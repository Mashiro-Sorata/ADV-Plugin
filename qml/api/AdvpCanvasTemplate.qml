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
    signal completed()
    signal versionUpdated(string old)

    readonly property var configs: widget.settings[widget.settings.current_style] ?? defaultValues

    function updateObject(target, source) {
        return Common.updateObject(Common.deepClone(target), Common.deepClone(source));
    }

    function updateConfiguration() {
        delete widget.settings[widget.settings.current_style]["Version"];
        widget.settings[widget.settings.current_style] = updateObject(defaultValues, widget.settings[widget.settings.current_style]);
    }

    onConfigsChanged: {
        if (context) {
            configsUpdated();
        }
    }

    onContextChanged: {
        if (context) {
            configsUpdated();
            let _data = new Array(129);
            for (let i = 0; i < 128; i++) {
                _data[i] = 0;
            }
            _data[128] = 1;
            audioDataUpdeted(_data);
        }
    }

    Connections {
        enabled: Boolean(context)
        target: Common
        onAudioDataUpdated: audioDataUpdeted(audioData)
    }

    Component.onCompleted: {
        if (!widget.settings[widget.settings.current_style]) {
            widget.settings[widget.settings.current_style] = defaultValues;
        }else if(widget.settings[widget.settings.current_style]["Version"] !== defaultValues["Version"]) {
            versionUpdated(widget.settings[widget.settings.current_style]["Version"]);
        }
        completed();
    }
}
