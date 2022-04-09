import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T

import "."


T.Widget {
    id: widget
    solid: true
    title: qsTr("ADV Widget")
    resizable: true

    editing: styleDialog.active

    property bool initial: true

    function setStyleURL(url) {
        styleLoader.source = url;
    }

    Loader {
        id: styleDialog
        active: false
        visible: false
        sourceComponent: StylePreferences {
            transientParent: widget.NVG.View.window
        }

        onLoaded: {
            if(initial) {
                styleDialog.active = false;
                styleDialog.visible = true;
                initial = false;
            } else {
                item.visible = true;
            }
        }
    }

    Loader {
        id: styleLoader
        active: widget.NVG.View.exposed
        enabled: true
        source: ""
    }

    menu: Menu {
        Action {
            text: qsTr("Settings") + "..."
            enabled: !styleDialog.active
            onTriggered: {
                Common.updateStyleList();
                styleDialog.active = true
            }
        }
    }

    Component.onCompleted: {
        styleDialog.active = true;
        Common.widgetsNum++;
    }

    Component.onDestruction: {
        styleDialog.active = false;
        Common.widgetsNum--;
    }
}
