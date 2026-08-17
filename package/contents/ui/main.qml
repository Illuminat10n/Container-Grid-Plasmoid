import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.draganddrop 2.0 as KDND

import "items" // contains PlasmoidItem.qml

ContainmentItem {
    id: root

    // be at least the same size as the system tray popup
    Layout.minimumWidth: Kirigami.Units.gridUnit * 9
    Layout.minimumHeight: Kirigami.Units.gridUnit * 9
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight * 1.5
    Layout.fillHeight: true
    Layout.fillWidth: true

    property Component plasmoidItemComponent

    /************************************************************************
     * Model
     *
     * Roles:
     *  - plasmoidId : string like "org.kde.weather"
     *  - instance   : number (0-based index among same plasmoidId)
     *  - uid        : optional unique id derived from the Containment applet (plasmoid-instance identifier)
     *  - pending    : boolean (true if appended locally before Containment confirms)
     *  - widget: plasmoid item :D
     ************************************************************************/
    ListModel {
        id: appletModel
    }

    // Helper: return the next instance number for a given plasmoidId
    function nextInstanceFor(plasmoidId) {
        var max = -1;
        for (var i = 0; i < appletModel.count; ++i) {
            var e = appletModel.get(i);
            if (e.plasmoidId == plasmoidId && typeof e.instance === "number")
                max = Math.max(max, e.instance);
        }
        return max + 1;
    }

    Containment.onAppletAdded: applet => {
        addApplet(applet)
    }

    function addApplet(applet){
        // Try to match an existing pending model row for the same plasmoidId
        var plasmoidId = (applet && applet.pluginName) ? applet.pluginName : null;

        var instance = nextInstanceFor(plasmoidId);

        const appletItem = root.itemFor(applet);
        applet.visible = true;

        appletModel.append({
                plasmoidId: plasmoidId,
                instance: instance,
                //uid: applet.id,
                pending: false,
                widget: appletItem
        });
    }

    Containment.onAppletRemoved: applet => {
                let name = applet.pluginName;
                let uid = applet.id;
                for (var j = 0; j < appletModel.count; ++j) {
                    var r = appletModel.get(j);
                    if (r.plasmoidId === name && r.uid === applet.id) {
                        appletModel.remove(j);
                        return;
                    }
                }
    }

    Component.onCompleted: {
        // initialise plasmoidItemComponent lazily (optional)
        plasmoidItemComponent = Qt.createComponent("items/PlasmoidItem.qml");
        if (plasmoidItemComponent.status === Component.Error) {
            console.warn("Could not load PlasmoidItem:", plasmoidItemComponent.errorString());
        }

        // seed model from existing containments
        var applets = Containment.applets;
        for (var i = 0; i < applets.length; ++i) {
            // call onAppletAdded to keep logic centralized
            addApplet(applets[i]);
        }
    }

    // UI
    Item {
        anchors.fill: parent

        GridLayout {
            id: mainGrid
            anchors.fill: parent

            // Each delegate must be a PlasmoidItem instance with the plasmoidId passed in.
            Repeater {
                id: rep
                model: appletModel

                PlasmoidItem {
                    id: plasmoidDelegate
                    // The PlasmoidItem.qml must expose a property 'plasmoidId' and optionally 'instance'
                    plasmoidId: model.plasmoidId
                    itemId: model.instance
                    applet: model.widget
                    visualIndex: model.index
                }
            }

            rows: 2
            columns: 2
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: columnSpacing
        }

        PlasmaComponents.Label {
            anchors.fill: mainGrid
            text: i18n("Drag applets here")
            textFormat: Text.PlainText
            visible: appletModel.count === 0
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        PlasmaComponents.TextField {
            id: typer
            text: "org.kde.plasma.calculator"
            visible: appletModel.count === 0
        }

        PlasmaComponents.Button {
            id: starterButton
            anchors.left: typer.right
            onClicked: {
                // Add local pending model entry and then ask system to create the applet
                plasmoid.newTask(typer.text);
            }
        }
    }

    DropArea {
        id: dropArea2

        //anchors.top: dropArea1.bottom
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        //implicitHeight: parent.height/2

        enabled: true

        function appletName(event) {
            if (event.mimeData.formats.indexOf("text/x-plasmoidservicename") < 0) {
                return null;
            }
            var plasmoidId = event.mimeData.getDataAsByteArray("text/x-plasmoidservicename");
            return plasmoidId;
        }

        onPositionChanged: event => {
            if(!event.source){
                return;
            }
            var drop = event.source;
            //console.log(drop);
            if(!drop){
                event.ignore();
                return;
            }
            var surface = mainGrid.childAt(event.x, event.y);

            if (surface){
                appletModel.move(drop.visualIndex, surface.visualIndex, 1)
            }
        }

        onDropped: event => {
            //console.log("Dropped");
            var plasmoidId = event.getDataAsString("text/x-plasmoidservicename");
            if (!plasmoidId) {
                event.ignore();
                return;
            }
            plasmoid.newTask(plasmoidId);
        }
    }
}
