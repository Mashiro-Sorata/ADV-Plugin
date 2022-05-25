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

    property Component style
    property Component preference
    property var defaultValues

    Loader {
        id: styleDialog
        active: false
        sourceComponent: StylePreferences {
            transientParent: widget.NVG.View.window
        }
    }

    Loader {
        id: styleObjectLoader
        active: widget.NVG.View.exposed
        enabled: true
        source: Qt.resolvedUrl(widget.settings.current_style)

        onLoaded: {
            preference = item.preference;
            defaultValues = item.defaultValues;
            style = item.style;
            if (!widget.settings[widget.settings.current_style]) {
                widget.settings[widget.settings.current_style] = defaultValues;
            }else if(widget.settings[widget.settings.current_style]["Version"] !== defaultValues["Version"]) {
                delete widget.settings[widget.settings.current_style]["Version"];
                widget.settings[widget.settings.current_style] = Common.updateObject(Common.deepClone(defaultValues), widget.settings[widget.settings.current_style]);
            }
        }
    }

    Loader {
        id: styleLoader
        active: widget.NVG.View.exposed
        enabled: true
        sourceComponent: style
    }

    menu: Menu {
        Action {
            text: qsTr("Style Settings") + "..."
            onTriggered: {
                Common.updateStyleList();
                styleDialog.active = true;
            }
        }

        Action {
            text: qsTr("Server Settings") + "..."
            onTriggered: {
                Common.serverPreferencesOpen();
            }
        }
    }

    Component.onCompleted: {
        Common.widgetsNum++;
        if ((!widget.settings.current_style) || (Common.stylesURL.indexOf(widget.settings.current_style) === -1)) {
            widget.settings.current_style = Common.stylesURL[0];
        }
    }

    Component.onDestruction: {
        styleDialog.active = false;
        Common.widgetsNum--;
    }
}
