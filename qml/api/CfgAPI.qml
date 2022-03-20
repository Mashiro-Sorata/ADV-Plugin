import QtQuick 2.12
import QtQuick.Controls 2.12
import NERvGear.Preferences 1.0 as P

P.DialogPreference {
    icon.name: "solid:\uf085"
    live: true
    property string version: ""
    property int cfg_height: 580

    P.TextFieldPreference {
        name: "__version"
        visible: false
        enabled: false
        defaultValue: version
    }

    P.SpinPreference {
        name: "__cfg_height"
        enabled: false
        visible: false
        editable: false
        from: cfg_height
        to: cfg_height
        defaultValue: cfg_height
    }

    ItemDelegate {
        text: qsTr("Version")
        visible: version

        Label {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter

            text: version
            font.weight: Font.DemiBold
        }
    }
}
