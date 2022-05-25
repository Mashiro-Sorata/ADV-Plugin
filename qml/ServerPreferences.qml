import QtQuick 2.12

import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import NERvGear 1.0 as NVG
import NERvGear.Preferences 1.0 as P
import NERvGear.Controls 1.0

import "."


NVG.Window {
    title: qsTr("ADV Server")
    visible: true
    minimumWidth: 480
    minimumHeight: 600
    width: minimumWidth
    height: minimumHeight

    Page {
        id: cfg_page
        anchors.fill: parent

        header: TitleBar {
            text: qsTr("ADV Server")
            standardButtons: Dialog.Save | Dialog.Reset

            onAccepted: {
                let cfg = Object.assign(Common.deepClone(Common.serverCFG), rootPreference.save());

                if (cfg.server.logger) {
                    Common.debug = _debug.value;
                } else {
                    Common.debug = false;
                }

                if (!Common.isObjectValueEqual(cfg, Common.serverCFG)) {
                    Common.setWsocket(false);
                    Common.serverCFG = cfg;

                    let ini_text = Common.convertINIString(Common.serverCFG);
                    Common.writeFile(Common.iniFile, ini_text);
                    Common.rebootServer(true);
                    Common.setWsocket(true);
                }

                serverDialog.active = false;
            }

            onReset: {
                rootPreference.load(Common.defaultServerCFG);
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

                    P.SwitchPreference {
                        id: _debug
                        Layout.fillWidth: true
                        name: "debug"
                        label: qsTr("Debug Mode")
                        message: qsTr("Logging must be enabled and saved.")
                        warning: value ? qsTr("This will disable the error recovery function!") : ""
                        enabled: Common.serverCFG.server.logger
                        defaultValue: Common.debug
                        onPreferenceEdited: {
                            Common.debug = value;
                        }
                    }

                    P.PreferenceGroup {
                        id: rootPreference
                        Layout.fillWidth: true

                        P.PreferenceGroup {
                            Layout.fillWidth: true
                            name: "server"
                            Heading { text: qsTr("General") }

                            P.SpinPreference {
                                name: "port"
                                label: qsTr("Port")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: 65535
                                value: String(value)
                                defaultValue: Common.defaultServerCFG["server"]["port"]
                            }

                            P.SpinPreference {
                                name: "maxclient"
                                label: qsTr("Max Number of Clients")
                                message: qsTr("Maximum number of server connections\n(All ADV widgets share one connection).")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: 15
                                value: String(value)
                                defaultValue: Common.defaultServerCFG["server"]["maxclient"]
                            }

                            P.SwitchPreference {
                                id: _server_logger
                                name: "logger"
                                label: qsTr("Enable Logging")
                                message: qsTr("Enable to output log file (ADV_Log.log).")
                                defaultValue: Common.defaultServerCFG["server"]["logger"]
                            }

                            P.ItemPreference {
                                label: qsTr("Open Log File")
                                Layout.fillWidth: true
                                enabled: _debug.enabled
                                select: function () {
                                    NVG.SystemCall.execute("explorer", NVG.Url.toLocalFile(Qt.resolvedUrl("../bin/ADV_Log.log")).replace(/\//g, '\\'));
                                }
                            }
                        }

                        P.PreferenceGroup {
                            Layout.fillWidth: true
                            name: "fft"
                            Heading { text: qsTr("Data") }

                            P.SpinPreference {
                                name: "attack"
                                label: qsTr("Increase Factor")
                                message: qsTr("The larger the value, the slower the data increase.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: 20000
                                defaultValue: Common.defaultServerCFG["fft"]["attack"]
                            }

                            P.SpinPreference {
                                name: "decay"
                                label: qsTr("Reduction Factor")
                                message: qsTr("The larger the value, the slower the data reduction.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: 20000
                                defaultValue: Common.defaultServerCFG["fft"]["decay"]
                            }

                            P.SpinPreference {
                                name: "peakthr"
                                label: qsTr("Peak Extra Increment")
                                message: qsTr("Extra increment of data normalization peak.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 0
                                to: 1000
                                defaultValue: Common.defaultServerCFG["fft"]["peakthr"]
                            }

                            P.SpinPreference {
                                name: "norspeed"
                                label: qsTr("Dynamic Normalization Factor")
                                message: qsTr("Convergence speed of data normalization peak.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: 100
                                defaultValue: Common.defaultServerCFG["fft"]["norspeed"]
                            }

                            P.SpinPreference {
                                id: _fps
                                name: "fps"
                                label: qsTr("Transmission Rate")
                                message: qsTr("Number of data sent per second.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 10
                                to: 60
                                defaultValue: Common.defaultServerCFG["fft"]["fps"]
                            }

                            P.SpinPreference {
                                name: "changespeed"
                                label: qsTr("Change Speed")
                                message: qsTr("Adjust the data change speed.")
                                display: P.TextFieldPreference.ExpandLabel
                                editable: true
                                from: 1
                                to: _fps.value - 1
                                defaultValue: Common.defaultServerCFG["fft"]["changespeed"]
                            }
                        }

                        Component.onCompleted: {
                            rootPreference.load(Common.serverCFG)
                        }
                    }
                }
            }
        }
    }

    onClosing: {
        serverDialog.active = false;
    }
}
