import NERvGear 1.0 as NVG
import NERvGear.Private 1.0 as NVGP

import "./qml"

NVG.Module {
    initialize: function () {
        console.log("Initializing ADV-Plugin.");
        Common.execute("../bin/ADVServer.exe", "-reboot");
        Common.setWsocket(true);
        return true;
    }

    ready: function () {
        console.log("ADV-Plugin is ready.");
    }

    cleanup: function () {
        console.log("Cleaning up ADV-Plugin.");
        Common.setWsocket(false);
        Common.execute("../bin/ADVServer.exe", "-close");
   }
}
