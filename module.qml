import NERvGear 1.0 as NVG
import NERvGear.Private 1.0 as NVGP

import QtQuick 2.12
import QtQuick.Controls 2.12

import "./qml"

NVG.Module {
    initialize: function () {
        console.log("Initializing ADV-Plugin.");
        Common.execute(Common.serverEXE, "-reboot");
        return true;
    }

    ready: function () {
        console.log("ADV-Plugin is ready.");
    }

    cleanup: function () {
        console.log("Cleaning up ADV-Plugin.");
        Common.setWsocket(false);
        Common.execute(Common.serverEXE, "-close");
   }

    Connections {
        target: Common
        onServerPreferencesOpen: {
            serverDialog.active = true;
            serverDialog.item.visible = true;
        }
    }

   Loader {
       id: serverDialog
       active: false
       sourceComponent: ServerPreferences { }
   }
}
