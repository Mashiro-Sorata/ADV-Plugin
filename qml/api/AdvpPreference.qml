import QtQuick 2.12
import QtQuick.Controls 2.12
import NERvGear.Preferences 1.0 as P

P.PreferenceGroup {
    property string version: ""

    P.TextFieldPreference {
        name: "Version"
        visible: false
        enabled: false
        defaultValue: version
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

    P.Separator {visible: version}
}
