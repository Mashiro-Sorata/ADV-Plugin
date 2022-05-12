pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import NERvGear 1.0 as NVG



Item {
    readonly property var styles: []
    readonly property var stylesURL: []
    readonly property var defaultServerCFG: {
        "server": {
            "port": 5050,
            "maxclient": 5,
            "logger": true
        },
        "fft": {
            "attack": 5,
            "decay": 5,
            "norspeed": 1,
            "peakthr": 10,
            "fps": 35,
            "changespeed": 20
        }
    }
    readonly property string iniFile: "../bin/advConfig.ini"
    readonly property string serverEXE: "../bin/ADVServer.exe"

    property var serverCFG: defaultServerCFG
    property string wsIp: "localhost"
    property int wsPort: serverCFG.server.port

    property int widgetsNum: 0
    property bool debug: false
    property bool rebootFlag: false

    signal audioDataUpdated(var audioData)
    signal serverPreferencesOpen()

    function execute(path, args) {
        path = NVG.Url.toLocalFile(Qt.resolvedUrl(path));
        NVG.SystemCall.execute(path, args);
    }

    function readFile(fileUrl) {
        let request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        let data = request.responseText;
        request = null;
        return data;
    }

    function writeFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    function parseINIString(data) {
      let regex = {
        section: /\[\s*([^]*)\s*\]\s*$/,
        param: /^\s*([\w\.\-\_]+)\s*=\s*(.*?)\s*$/,
        comment: /^\s*;.*$/
      };
      let value = {};
      let lines = data.split(/\r\n|\r|\n/);
      let section = null;
      let match;
      lines.forEach(function(line){
            if (regex.comment.test(line)) {
                return;
            } else if (regex.param.test(line)) {
                match = line.match(regex.param);
                if (["true", "false"].indexOf(match[2]) > -1) {
                    match[2] = Boolean(1 - ["true", "false"].indexOf(match[2]));
                } else if (/^\d+$/.test(match[2])) {
                    match[2] = Number(match[2]);
                }
                if (section) {
                    value[section][match[1]] = match[2];
                } else {
                    value[match[1]] = match[2];
                }
            } else if (regex.section.test(line)) {
                match = line.match(regex.section);
                value[match[1]] = {};
                section = match[1];
            } else if(line.length === 0 && section) {
                section = null;
            };
      });
      return value;
    }

    function convertINIString(data) {
        let value = "";
        for (let section in data) {
            value += "[" + section + "]\n";
            for (let key in data[section]) {
                value += key + " = " + String(data[section][key]) + "\n";
            }
            value += "\n";
        }
        return value;
    }

    function deepClone(obj) {
        let objClone = Array.isArray(obj) ? [] : {};
        if (obj && typeof obj === "object" && obj != null) {
            for (var key in obj) {
                if (obj.hasOwnProperty(key)) {
                    if (obj[key] && typeof obj[key] === "object") {
                        objClone[key] = deepClone(obj[key]);
                    } else {
                        objClone[key] = obj[key];
                    }
                }
            }
        }
        return objClone;
    }

    function isObjectValueEqual(a, b) {
        if (a === b)
            return true;
        let aProps = Object.getOwnPropertyNames(a);
        let bProps = Object.getOwnPropertyNames(b);
        if (aProps.length !== bProps.length)
            return false;
        for (let prop in a) {
            if (b.hasOwnProperty(prop)) {
                if (typeof a[prop] === 'object') {
                    if (!isObjectValueEqual(a[prop], b[prop]))
                        return false;
                } else if (a[prop] !== b[prop]) {
                    return false;
                }
            } else {
                return false;
            }
        }
        return true;
    }

    Loader {
        id: wsocket
        sourceComponent: WSocket {}
        active: false
    }

    onWidgetsNumChanged: {
        wsocket.active = widgetsNum>0;
    }

    function setWsocket(status) {
        wsocket.active = status;
    }

    function rebootServer(force) {
        if (force || !debug && wsocket.active && rebootFlag) {
            console.log("Try to reboot ADVServer...");
            execute(serverEXE, "-reboot");
            wsocket.active = false;
            wsocket.active = true;
            rebootFlag = false;
        }
    }

    onDebugChanged: {
        rebootServer();
    }

    onRebootFlagChanged: {
        rebootServer();
    }

    function parse_resource(resource_list, sort) {
        if (sort)
            resource_list.sort(function (x, y) {
                let preset_order = ["/advp-style-preset/line", "/advp-style-preset/gradient_line", "/advp-style-preset/waves", "/advp-style-preset/circle", "/advp-style-preset/solidcircle", "/advp-style-preset/ordinal_scale_ui_bottom"];
                if (preset_order.indexOf(x.location) < preset_order.indexOf(y.location))
                    return -1;
                else if(preset_order.indexOf(x.location) > preset_order.indexOf(y.location))
                    return 1;
                else
                    return 0;
            });
        resource_list.forEach(function (resource) {
            if (resource.url && stylesURL.indexOf(resource.url.toString()) === -1) {
                styles.push(resource.title);
                stylesURL.push(resource.url.toString());
            }
        });
    }

    function updateStyleList() {
        styles.length = 0;
        stylesURL.length = 0;
        const preset_list = NVG.Resources.filter(/advp.widget.mashiros.top/, /top.mashiros.advp-style/);
        parse_resource(preset_list, true);
        const third_list = NVG.Resources.filter(/.*/, /top.mashiros.advp-style/);
        parse_resource(third_list, false);
    }

    Component.onCompleted: {
        updateStyleList();
        let ini_data = readFile(iniFile);
        if (ini_data) {
            ini_data = ini_data.toLowerCase();
            let cfg = parseINIString(ini_data);
            serverCFG = Object.assign(defaultServerCFG, cfg);
        } else {
            let ini_text = convertINIString(defaultServerCFG);
            writeFile(iniFile, ini_text);
        }
    }
}
