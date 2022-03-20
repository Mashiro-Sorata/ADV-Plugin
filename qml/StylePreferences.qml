import QtQuick 2.12

import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NERvGear 1.0 as NVG
import NERvGear.Preferences 1.0 as P

import "."


NVG.Window {
    id: window
    title: qsTr("ADV-Plugin: Settings")
    visible: false
    minimumWidth: 480
    minimumHeight: 580
    maximumWidth: minimumWidth
    maximumHeight: minimumHeight
    width: minimumWidth
    height: minimumHeight

    Behavior on minimumHeight {
        PropertyAnimation {
            duration: 500
            easing.type: Easing.InOutBack
        }
    }

    property var configuration
    property var old_style_cfg

    ColumnLayout {
        id: root
        anchors.fill: parent
        anchors.margins: 16
        anchors.topMargin: 0

        Row {
            spacing: 350

            ToolButton {
                text: qsTr("Save")
                onClicked: {
                    configuration = rootPreference.save();
                    let index = configuration["index"];
                    widget.settings[Common.stylesURL[index]] = configuration[Common.stylesURL[index]];
                    delete configuration[Common.stylesURL[index]];
                    widget.settings.styles = configuration;
                    widget.settings.current_style = Common.stylesURL[index];
                    styleDialog.active = false;
                }
            }

            ToolButton {
                text: qsTr("Reset")
                onClicked: {
                    styleLoader.load();
                    let cfg = rootPreference.save();
                    let index = cfg["index"];
                    widget.settings[Common.stylesURL[index]] = cfg[Common.stylesURL[index]];
                    widget.setStyleURL("");
                    widget.setStyleURL(Qt.resolvedUrl(Common.stylesURL[widget.settings.styles["index"]]));
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("Settings")
            font.pixelSize: 24
        }

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

                    label: qsTr("Configuration")

                    onPreferenceEdited: {
                        let cfg = rootPreference.save();
                //        console.log(JSON.stringify(cfg, null, 2));
                        let index = cfg["index"];
                        if (widget.settings.styles["index"] !== index) {
                            widget.setStyleURL("");
                            widget.settings[Common.stylesURL[widget.settings.styles["index"]]] = old_style_cfg;
                            old_style_cfg = widget.settings[Common.stylesURL[index]];
                        }

                        widget.settings[Common.stylesURL[index]] = cfg[Common.stylesURL[index]];
                        delete cfg[Common.stylesURL[index]];
                        widget.settings.styles = cfg;
                        widget.setStyleURL(Qt.resolvedUrl(Common.stylesURL[index]));
                    }

                    P.SelectPreference {
                        id: styleList
                        name: "index"
                        label: qsTr("Styles")
                        icon.name: "solid:\uf1fc"
                        defaultValue: 0
                        model: Common.styles
                    }

                    P.Separator {}

                    P.PreferenceLoader {
                        id: styleLoader
                        name: Common.stylesURL[styleList.value]
                        source: Qt.resolvedUrl(Common.stylesCFG[styleList.value])
                        onLoaded: {
                            let cfg = save();
                            if (!widget.settings[Common.stylesURL[styleList.value]]) {
                                widget.settings[Common.stylesURL[styleList.value]] = cfg;
                            } else if(widget.settings[Common.stylesURL[styleList.value]]["__version"] === cfg["__version"]) {
                                load(widget.settings[Common.stylesURL[styleList.value]]);
                            } else {
                                widget.settings[Common.stylesURL[styleList.value]] = cfg;
                            }
                            window.minimumHeight = cfg["__cfg_height"];
                        }

                        onContentItemChanged: {
                            if(contentItem) {
                                contentItem.label = Common.styles[styleList.value];
                            }
                        }
                    }

                    P.Separator {}

                    Component.onCompleted: {
                        if(!widget.settings.styles) {
                            configuration = rootPreference.save();
                            let index = configuration["index"];
                            widget.settings[Common.stylesURL[index]] = configuration[Common.stylesURL[index]];
                            old_style_cfg = configuration[Common.stylesURL[index]];
                            delete configuration[Common.stylesURL[index]];
                            widget.settings.current_style = Common.stylesURL[index];
                            widget.settings.styles = configuration;
                        }

                        let index = Common.stylesURL.indexOf(widget.settings.current_style);
                        if (index === -1) {
                            index = 0;
                            widget.settings.current_style = Common.stylesURL[index];
                        }

                        widget.settings.styles["index"] = index;
                        widget.setStyleURL(Qt.resolvedUrl(Common.stylesURL[widget.settings.styles["index"]]));

                        rootPreference.load(widget.settings.styles);
                        configuration = widget.settings.styles;
                        old_style_cfg = widget.settings[Common.stylesURL[index]];

                        styleLoader.load(widget.settings[Common.stylesURL[index]]);
                    }
                }
            }
        }
    }

    onClosing: {
        widget.setStyleURL("");
        widget.settings[Common.stylesURL[widget.settings.styles["index"]]] = old_style_cfg;
        widget.settings.styles = configuration;
        widget.setStyleURL(Qt.resolvedUrl(Common.stylesURL[widget.settings.styles["index"]]));
        styleDialog.active = false;
    }
}
