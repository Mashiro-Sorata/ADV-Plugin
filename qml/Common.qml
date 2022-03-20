pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import NERvGear 1.0 as NVG



Item {
    readonly property var styles: []
    readonly property var stylesURL: []
    readonly property var stylesCFG: []

    signal audioDataUpdated(var audioData)
    signal wsocketClosed()

    function execute(path, args) {
        path = NVG.Url.toLocalFile(Qt.resolvedUrl(path));
        NVG.SystemCall.execute(path, args);
    }

    function openFile(fileUrl) {
        let request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        let data = request.responseText;
        request = null;
        return data;
    }

    function parseINIString(data){
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
        if(regex.comment.test(line)){
          return;
        }else if(regex.param.test(line)){
          match = line.match(regex.param);
          if(section){
            value[section][match[1]] = match[2];
          }else{
            value[match[1]] = match[2];
          }
        }else if(regex.section.test(line)){
          match = line.match(regex.section);
          value[match[1]] = {};
          section = match[1];
        }else if(line.length === 0 && section){
          section = null;
        };
      });
      return value;
    }

    Loader {
        id: wsocket
        sourceComponent: WSocket {
            Component.onCompleted: {
                let ini_data = openFile("../bin/advConfig.ini");
                ini_data = ini_data.toLowerCase();
                let cfg = parseINIString(ini_data);
                if(cfg["server"]["ip"].toLowerCase() === "local") {
                    wsIp = "localhost";
                } else {
                    wsIp = cfg["server"]["ip"];
                }
                wsPort = cfg["server"]["port"];
            }}
        active: false
    }

    function setWsocket(status) {
        wsocket.active = status;
    }

    onWsocketClosed: {
        if (wsocket.active) {
            console.log("Try to reboot ADVServer...");
            execute("../bin/ADVServer.exe", "-reboot");
            wsocket.active = false;
            wsocket.active = true;
        }
    }

    function parse_resource(resource_list, sort) {
        if (sort)
            resource_list.sort(function (x, y) {
                let preset_order = ["Preset Line", "Preset Waves", "Preset Circle", "Preset Solid-circle", "Preset Ordinal Scale UI bottom"];
                if (preset_order.indexOf(x.title) < preset_order.indexOf(y.title))
                    return -1;
                else if(preset_order.indexOf(x.title) > preset_order.indexOf(y.title))
                    return 1;
                else
                    return 0;
            });
        resource_list.forEach(function (resource) {
            let name = resource.title;
            let styleURL = "";
            let styleCFG = "";
            resource.files().forEach(function (file) {
                if (file.entry === "Style.qml") {
                    styleURL = String(file.url);
                } else if (file.entry === "Config.qml") {
                    styleCFG = String(file.url);
                }
            });
            if (styleURL && stylesURL.indexOf(styleURL) === -1) {
                styles.push(name);
                stylesURL.push(styleURL);
                stylesCFG.push(styleCFG);

            }
//            console.log(JSON.stringify(Object.keys(resource), null, 2));
//            console.log(JSON.stringify(resource.files(), null, 2));
        });
    }

    Component.onCompleted: {
        const preset_list = NVG.Resources.filter(/advp.widget.mashiros.top/, /top.mashiros.advp-style/);
        parse_resource(preset_list, true);
        const third_list = NVG.Resources.filter(/.*/, /top.mashiros.advp-style/);
        parse_resource(third_list, false);
//        console.log(JSON.stringify(styles, null, 2));
//        console.log(JSON.stringify(stylesURL, null, 2));
    }
}
