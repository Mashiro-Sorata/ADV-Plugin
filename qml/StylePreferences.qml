import QtQuick 2.12

import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NERvGear 1.0 as NVG
import NERvGear.Preferences 1.0 as P
import NERvGear.Controls 1.0

import "."


NVG.Window {
    id: window
    title: qsTr("ADV Widget")
    visible: true
    minimumWidth: 480
    minimumHeight: 600
    width: minimumWidth
    height: minimumHeight

    property var old_style_cfg
    property int last_style_index

    Page {
        id: cfg_page
        anchors.fill: parent

        header: TitleBar {
            text: qsTr("ADV Widget")
            standardButtons: Dialog.Save | Dialog.Reset

            onAccepted: {
                let cfg = rootPreference.save();
                widget.settings[widget.settings.current_style] = cfg[widget.settings.current_style];
                styleDialog.active = false;
            }

            onReset: {
                stylePreferenceLoader.load();
                let cfg = rootPreference.save();
                widget.settings[widget.settings.current_style] = cfg[widget.settings.current_style];
            }
        }

        ColumnLayout {
            id: root
            anchors.fill: parent
            anchors.margins: 16
            anchors.topMargin: 16

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true
                contentWidth: preferenceLayout.implicitWidth
                contentHeight: preferenceLayout.implicitHeight

                ColumnLayout {
                    id: preferenceLayout
                    width: root.width

                    P.PreferenceGroup {
                        id: rootPreference
                        Layout.fillWidth: true

                        onPreferenceEdited: {
                            if (widget.settings.current_style !== Common.stylesURL[styleList.value]) {
                                widget.settings[widget.settings.current_style] = old_style_cfg;
                                widget.settings.current_style = Common.stylesURL[styleList.value];
                                old_style_cfg = widget.settings[widget.settings.current_style];
                            }
                            let cfg = rootPreference.save();
                            widget.settings[widget.settings.current_style] = cfg[widget.settings.current_style];
                        }

                        P.SelectPreference {
                            id: styleList
                            name: "index"
                            label: qsTr("Styles")
                            icon.name: "solid:\uf1fc"
                            defaultValue: 0
                            model: Common.styles
                        }

                        Heading {
                            id: heading
                            visible: Boolean(preference)
                            text: Common.styles[styleList.value] + " " + qsTr("Configuration")
                        }

                        P.PreferenceLoader {
                            id: stylePreferenceLoader
                            name: widget.settings.current_style
                            sourceComponent: preference
                            onLoaded: {
                                let cfg = save();
                                load(widget.settings[widget.settings.current_style]);
                            }
                        }

                        Component.onCompleted: {
                            last_style_index = Common.stylesURL.indexOf(widget.settings.current_style);
                            if (last_style_index === -1) {
                                last_style_index = 0;
                                widget.settings.current_style = Common.stylesURL[0];
                            }
                            rootPreference.load({"index": last_style_index});
                            old_style_cfg = widget.settings[widget.settings.current_style];
                            stylePreferenceLoader.load(widget.settings[widget.settings.current_style]);
                        }
                    }
                }
            }
        }
    }

    onClosing: {
        widget.settings[widget.settings.current_style] = old_style_cfg;
        widget.settings.current_style = Common.stylesURL[last_style_index]
        styleDialog.active = false;
    }
}
