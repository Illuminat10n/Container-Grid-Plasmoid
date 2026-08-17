/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.plasma.core as PlasmaCore
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

AbstractItem {
    id: plasmoidContainer

    property Item applet

    property string plasmoidId: ""

    property int visualIndex

    //required property Item dragParent

    text: applet ? applet.plasmoid.title : ""

    itemId: applet ? applet.plasmoid.id : ""
    status: applet ? applet.plasmoid.status : PlasmaCore.Types.UnknownStatus
    active: true //root.activeApplet !== applet

    Layout.fillWidth: true
    Layout.fillHeight: true

    Layout.columnSpan: 1
    Layout.rowSpan: 1

    KSvg.FrameSvgItem {
        id: backgroundFrame
            anchors {
                fill: parent
                leftMargin: -margins.left
                topMargin: -margins.top
                rightMargin: -margins.right
                bottomMargin: -margins.bottom
            }
            imagePath: "widgets/background"
            z: -10
    }

    /*PlasmaExtras.PlasmoidHeading{
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        visible: plasmoidContainer.applet && plasmoidContainer.applet.expanded

        implicitHeight: visible ? headerRow.implicitHeight : 0

        RowLayout{
            id: headerRow

            PlasmaComponents.ToolButton{
                icon.name: "delete"
                icon.height: Kirigami.Units.gridUnit
                icon.width: Kirigami.Units.gridUnit
                onClicked: {
                    applet.plasmoid.internalAction("remove").trigger();
                    for(let i = 0 ; i < appletModel.count; i++){
                        let p = appletModel.get(i);
                        if(p.plasmoidId == plasmoidContainer.plasmoidId
                                && p.instance == plasmoidContainer.itemId)
                        {
                            appletModel.remove(i, 1);
                            break;
                        }
                    }
                }
            }

            PlasmaComponents.ToolButton{
                icon.name: "open-menu-symbolic"
                icon.height: Kirigami.Units.gridUnit
                icon.width: Kirigami.Units.gridUnit
                onClicked: {
                    plasmoid.showPlasmoidMenu(applet, x, y);
                }
            }

            PlasmaComponents.ToolButton{
                icon.name: "resizecol"
                icon.height: Kirigami.Units.gridUnit
                icon.width: Kirigami.Units.gridUnit
                onClicked: {
                    //plasmoidContainer.Layout.columnSpan = plasmoidContainer.Layout.columnSpan === 1 ? 2 : 1;
                    plasmoidContainer.implicitHeight -= 10;
                }
            }

            PlasmaComponents.ToolButton{
                icon.name: "resizerow"
                icon.height: Kirigami.Units.gridUnit
                icon.width: Kirigami.Units.gridUnit
                onClicked: {
                    //plasmoidContainer.Layout.rowSpan = plasmoidContainer.Layout.rowSpan === 1 ? 2 : 1;
                    plasmoidContainer.implicitWidth -= 10;
                }
            }
        }
    }

    */
    DragHandler{
        id: titlebarGrab

        target: plasmoidContainer
        enabled: true

        onActiveChanged: {
            console.log(active)
            if (!active){
                plasmoidContainer.parent.width += 1;
                plasmoidContainer.parent.width -=1;
            }
            else {
                plasmoidContainer.Layout.columnSpan = 1;
                plasmoidContainer.Layout.rowSpan = 1;
            }
        }
        cursorShape: Qt.DragMoveCursor

        acceptedButtons: {Qt.LeftButton}
    }

    /*states: [
        State {
            when: titlebarGrab.active

            AnchorChanges {
                target: plasmoidContainer
                anchors {
                    horizontalCenter: undefined
                    verticalCenter: undefined
                }
            }
        }
    ]   */

    /*MouseArea{
        id: titlebarMouse
        enabled: fal
        anchors.fill:header

        hoverEnabled: true
        acceptedButtons: {Qt.RightButton | Qt.LeftButton }

        preventStealing: true

        onClicked: (mouse) => {
            if (applet) {
                if (mouse.button === Qt.RightButton) {
                    plasmoid.showPlasmoidMenu(applet, mouse.x, mouse.y);
                }
            }
        }


        drag.onActiveChanged: {
            console.log(drag.active);
            if(!drag.active){
                plasmoidContainer.parent.visible = false;
                plasmoidContainer.parent.visible = true;
            }
        }
    }

    */


    Layout.margins: Kirigami.Units.gridUnit

    function syncAppletAnchors() {
        if (!applet) {
            return;
        }
        applet.parent = plasmoidContainer;
        applet.anchors.topMargin = Kirigami.Units.cornerRadius
        applet.anchors.top = plasmoidContainer.top
        applet.anchors.bottom = plasmoidContainer.bottom
        applet.anchors.left = plasmoidContainer.left
        applet.anchors.right = plasmoidContainer.right
        applet.visible = true;
        //titlebarGrab.drag.target = plasmoidContainer;
        //Drag.active = Qt.binding(function() {return titlebarGrab.drag})
        Drag.active = Qt.binding(function() {return titlebarGrab.active})
        //Drag.dragType = Drag.Automatic;
    }

    onAppletChanged: Qt.callLater(syncAppletAnchors)
    Component.onCompleted: Qt.callLater(syncAppletAnchors)
}
