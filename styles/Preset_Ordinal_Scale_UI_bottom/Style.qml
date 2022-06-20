import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

import "../../qml/api"

AdvpStyleTemplate {
    style: AdvpCanvasTemplate {
        readonly property var audioData: new Array(128)

        //configs
        readonly property real bassAmRatio: configs["Bass AM"]/100
        readonly property real altoAmRatio: configs["Alto AM"]/100
        readonly property real trebleAmRatio: configs["Treble AM"]/100
        readonly property string bassColor: configs["Bass Color"]
        readonly property string altoColor: configs["Alto Color"]
        readonly property string trebleColor: configs["Treble Color"]
        readonly property bool autoNormalizing: configs["Data Settings"]["Auto Normalizing"]
        readonly property real amplitude: configs["Data Settings"]["Amplitude"] / 400

        readonly property real halfWidth: width/2
        readonly property real rHeight: 0.6*height

        readonly property real speed: configs["Speed"]/100
        readonly property real _MAX: (height/2)-4
        readonly property real _noise: configs["Static AM"]/100*_MAX
        readonly property real _delta: _MAX-_noise
        property real _phase: 0

        readonly property var _globalAttenuationArray: [0.0017856573042805614, 0.002090029027424354, 0.0024428709787506155, 0.0028511620549328143, 0.003322734461672416, 0.0038663486688144872, 0.004491769417010894, 0.0052098416088514335, 0.0060325646905618185, 0.006973163895798498, 0.008046156486762173, 0.009267410897150058, 0.010654196465028541, 0.012225221251394174, 0.014000655282882916, 0.016002136446407085, 0.018252756211446522, 0.0207770223741957, 0.023600796118042038, 0.026751200876932862, 0.03025650078017051, 0.034145946854542274, 0.038449589664666724, 0.04319805768336597, 0.048422301394722714, 0.054153303932507744, 0.06042175993022312, 0.06725772518564865, 0.07469024069755677, 0.08274693558633812, 0.09145361433175414, 0.10083383461611592, 0.11090848281544048, 0.12169535480100475, 0.13320875016810133, 0.14545908827055729, 0.15845255448710202, 0.1721907849641367, 0.18667059766189825, 0.20188377687903944, 0.21781691755482288, 0.23445133456773634, 0.2517630409920839, 0.26972279787490494, 0.28829623659542597, 0.3074440533134911, 0.32712227344992756, 0.3472825826188692, 0.36787271899666724, 0.38883692080749416, 0.4101164214705023, 0.43164998401902316, 0.4533744656929005, 0.4752254031360044, 0.4971376084092084, 0.5190457660525851, 0.5408850216893105, 0.562591553140178, 0.5841031156880014, 0.6053595539666616, 0.6263032739177719, 0.6468796693242911, 0.6670374985596821, 0.6867292083486696, 0.7059112024886071, 0.7245440545987721, 0.7425926650223671, 0.760026362980347, 0.7768189559498792, 0.7929487290003452, 0.8083983974579334, 0.8231550167821777, 0.8372098539242965, 0.8505582247014246, 0.8631993018695427, 0.875135898619801, 0.8863742321691508, 0.8969236719785354, 0.9067964769231723, 0.9160075254728139, 0.9245740426279158, 0.9325153270127456, 0.9398524811601155, 0.9466081476449091, 0.9528062533442774, 0.9584717637292349, 0.9636304487320935, 0.9683086613922199, 0.9725331301632185, 0.9763307654708479, 0.9797284808449854, 0.9827530287117202, 0.9854308507237252, 0.9877879423279077, 0.9898497311182406, 0.9916409683972773, 0.9931856332704053, 0.9945068485207086, 0.9956268074571305, 0.9965667108926166, 0.9973467133897048, 0.997985877906754, 0.9985021379865716, 0.9989122666488067, 0.9992318511763106, 0.9994752730222837, 0.9996556921079202, 0.9997850348281199, 0.9998739851348633, 0.999931978122665, 0.9999671955978632, 0.999986563172305, 0.9999957484820413, 0.9999991601923922, 0.9999999475120023, 1.0, 0.9999999475120023, 0.9999991601923922, 0.9999957484820413, 0.999986563172305, 0.9999671955978632, 0.999931978122665, 0.9998739851348633, 0.9997850348281199, 0.9996556921079202, 0.9994752730222837, 0.9992318511763106, 0.9989122666488067, 0.9985021379865716, 0.997985877906754, 0.9973467133897048, 0.9965667108926166, 0.9956268074571305, 0.9945068485207086, 0.9931856332704053, 0.9916409683972773, 0.9898497311182406, 0.9877879423279077, 0.9854308507237252, 0.9827530287117202, 0.9797284808449854, 0.9763307654708498, 0.9725331301632185, 0.9683086613922199, 0.9636304487320935, 0.9584717637292349, 0.9528062533442774, 0.9466081476449091, 0.9398524811601155, 0.9325153270127456, 0.9245740426279158, 0.9160075254728139, 0.9067964769231723, 0.8969236719785354, 0.8863742321691508, 0.875135898619801, 0.8631993018695436, 0.8505582247014246, 0.8372098539242965, 0.8231550167821794, 0.8083983974579334, 0.7929487290003452, 0.7768189559498792, 0.760026362980347, 0.7425926650223671, 0.7245440545987721, 0.7059112024886071, 0.6867292083486696, 0.6670374985596821, 0.6468796693242911, 0.6263032739177719, 0.6053595539666616, 0.5841031156880014, 0.562591553140178, 0.5408850216893111, 0.5190457660525862, 0.49713760840920945, 0.4752254031360049, 0.4533744656929005, 0.43164998401902366, 0.4101164214705023, 0.3888369208074946, 0.36787271899666724, 0.34728258261887, 0.3271222734499283, 0.30744405331349145, 0.28829623659542597, 0.26972279787490555, 0.2517630409920839, 0.2344513345677366, 0.21781691755482313, 0.2018837768790397, 0.18667059766189847, 0.17219078496413692, 0.15845255448710202, 0.14545908827055729, 0.13320875016810133, 0.12169535480100475, 0.11090848281544048, 0.10083383461611592, 0.09145361433175414, 0.08274693558633812, 0.07469024069755677, 0.06725772518564865, 0.060421759930223286, 0.054153303932507744, 0.048422301394722776, 0.0431980576833661, 0.038449589664666724, 0.034145946854542274, 0.0302565007801706, 0.026751200876932904, 0.023600796118042038, 0.020777022374195733, 0.018252756211446522, 0.016002136446407085, 0.014000655282882938, 0.012225221251394195, 0.010654196465028541, 0.009267410897150073, 0.008046156486762187, 0.00697316389579851, 0.006032564690561829, 0.0052098416088514335, 0.004491769417010894, 0.0038663486688144872, 0.003322734461672416, 0.0028511620549328143, 0.0024428709787506155, 0.002090029027424354, 0.0017856573042805614, 0.0015235572708080104, 0.001298240554271166, 0.001104862087804041, 0.0009391569963475799, 0.000797381501252183, 0.0006762579957286263, 0.0005729243418569506, 0.00048488735639869217, 0.0004099803857607644, 0.00034632481850304286, 0.00029229534504994666, 0.0002464887470267302, 0.00020769598120373757, 0.00017487731379413836, 0.0001471402583278278, 0.0001237200731699464, 0.00010396258176888504, 8.730908885950263e-05, 7.328317821506653e-05];

        function drawLine(ns, color, lwidth, _phase, main) {
            context.strokeStyle = color;
            context.lineWidth = lwidth || 1;

            let x, y;
            if (main) {
                context.beginPath();
                context.moveTo(0, height*0.6);
                for (let i=0; i<=0.54; i+=0.06) {
                    x = halfWidth*i;
                    y = rHeight;
                    context.transform(1, (i-2)*0.0454, 0, 1, 0, 0);
                    context.lineTo(x, y);
                    context.resetTransform();
                }
                context.stroke();
            }

            context.beginPath();
            context.transform(1, -0.066284, 0, 1, 0, 0);
            context.moveTo(width*0.27, rHeight);
            context.resetTransform();
            for (let i=0; i<=249; i+=1) {
                x = halfWidth*(0.54+i/250);
                y = rHeight + (_noise + ns) * _globalAttenuationArray[i] * Math.sin((-24.84+i*0.216)-_phase);
                context.transform(1, -0.066284+i*0.0001816, 0, 1, 0, 0);
                context.lineTo(x, y);
                context.resetTransform();
            }

            if (main) {
                for (let i=1.46; i<=2.06; i+=0.06) {
                    x = halfWidth*i;
                    y = rHeight;
                    context.transform(1, (i-2)*0.0454, 0, 1, 0, 0);
                    context.lineTo(x, y);
                    context.resetTransform();
                }
            }
            context.stroke();
        }

        onAudioDataUpdeted: {
            if(autoNormalizing) {
                for (let i = 0; i < 128; i++) {
                    audioData[i] = data[i] / data[128];
                }
            } else {
                for (let i = 0; i < 128; i++) {
                    audioData[i] = data[i] * amplitude;
                }
            }
            let trebleAm = 0;
            let altoAm = 0;
            let bassAm = 0;

            for(let i=0; i<6.4; i++) {
                bassAm += audioData[i];
            }
            for(let i=7; i<19.2; i++) {
                altoAm += audioData[i];
            }
            for(let i=20; i<64; i++) {
                trebleAm += audioData[i];
            }

            trebleAm = trebleAm / 38.4;
            altoAm = altoAm / 19.2;
            bassAm = bassAm / 6.4;

            _phase = (_phase+speed)%(Math.PI*64);

            context.clearRect(0, 0, width+32, height+32);

            drawLine(_delta*trebleAmRatio*trebleAm, trebleColor, 1.5, _phase, false);
            drawLine(_delta*bassAmRatio*bassAm, bassColor, 1.5, _phase+0.8, false);
            drawLine(_delta*altoAmRatio*altoAm, altoColor, 2, _phase+0.4, true);
            context.beginPath();
            context.stroke();
            requestPaint();
        }

        onCompleted: {
            for (let i = 0; i < 128; i++) {
                audioData[i] = 0;
            }
        }

        onVersionUpdated: {
            updateConfiguration();
        }
    }

    defaultValues: {
        "Version": "1.0.0",
        "Bass Color": "#dc143c",
        "Alto Color": "#f8f8ff",
        "Treble Color": "#4169e1",
        "Bass AM": 100,
        "Alto AM": 150,
        "Treble AM": 200,
        "Static AM": 25,
        "Speed": 20,
        "Data Settings": {
            "Auto Normalizing": true,
            "Amplitude": 10
        }
    }

    preference: AdvpPreference {
        version: defaultValues["Version"]

        P.ColorPreference {
            name: "Bass Color"
            label: qsTr("Bass Line Color")
            defaultValue: defaultValues["Bass Color"]
        }

        P.ColorPreference {
            name: "Alto Color"
            label: qsTr("Alto Line Color")
            defaultValue: defaultValues["Alto Color"]
        }

        P.ColorPreference {
            name: "Treble Color"
            label: qsTr("Treble Line Color")
            defaultValue: defaultValues["Treble Color"]
        }

        P.Separator {}

        P.SliderPreference {
            name: "Bass AM"
            label: qsTr("Bass Amplitude")
            from: 10
            to: 300
            stepSize: 5
            defaultValue: defaultValues["Bass AM"]
            displayValue: value + "%"
        }

        P.SliderPreference {
            name: "Alto AM"
            label: qsTr("Alto Amplitude")
            from: 10
            to: 300
            stepSize: 5
            defaultValue: defaultValues["Alto AM"]
            displayValue: value + "%"
        }

        P.SliderPreference {
            name: "Treble AM"
            label: qsTr("Treble Amplitude")
            from: 10
            to: 300
            stepSize: 5
            defaultValue: defaultValues["Treble AM"]
            displayValue: value + "%"
        }

        P.Separator {}

        P.SliderPreference {
            name: "Static AM"
            label: qsTr("Static Amplitude")
            from: 5
            to: 100
            stepSize: 1
            defaultValue: defaultValues["Static AM"]
            displayValue: value + "%"
        }

        P.SliderPreference {
            name: "Speed"
            label: qsTr("Wave Speed")
            from: 1
            to: 100
            stepSize: 1
            defaultValue: defaultValues["Speed"]
            displayValue: value + "%"
        }

        P.Separator {}

        P.DialogPreference {
            name: "Data Settings"
            label: qsTr("Data Settings")
            live: true
            icon.name: "regular:\uf1de"

            P.SwitchPreference {
                id: _cfg_preset_osui_dataSettings_autoNormalizing
                name: "Auto Normalizing"
                label: qsTr("Auto Normalizing")
                defaultValue: defaultValues["Data Settings"]["Auto Normalizing"]
            }

            P.SpinPreference {
                name: "Amplitude"
                label: qsTr("Amplitude Ratio")
                enabled: !_cfg_preset_osui_dataSettings_autoNormalizing.value
                message: "1 to 100"
                display: P.TextFieldPreference.ExpandLabel
                editable: true
                from: 1
                to: 100
                defaultValue: defaultValues["Data Settings"]["Amplitude"]
            }
        }
    }
}
