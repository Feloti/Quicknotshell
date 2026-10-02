import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth

    PanelWindow {
        id: panelWindow
        visible: GlobalStates.scriptRunnerOpen

        function hide() {
            GlobalStates.scriptRunnerOpen = false;
        }

        exclusiveZone: 0
        implicitWidth: sidebarWidth
        WlrLayershell.namespace: "quickshell:scriptRunner"
        WlrLayershell.keyboardFocus: GlobalStates.scriptRunnerOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
        }

        onVisibleChanged: {
            if (visible) {
                GlobalFocusGrab.addDismissable(panelWindow);
                ScriptRunnerService.refresh();
            } else {
                GlobalFocusGrab.removeDismissable(panelWindow);
            }
        }

        Connections {
            target: GlobalFocusGrab
            function onDismissed() {
                panelWindow.hide();
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.scriptRunnerOpen
            sourceComponent: ScriptRunnerContent {}
            
            width: root.sidebarWidth - Appearance.sizes.hyprlandGapsOut - Appearance.sizes.elevationMargin
            height: parent.height - (Appearance.sizes.hyprlandGapsOut * 2)
            y: Appearance.sizes.hyprlandGapsOut

            focus: GlobalStates.scriptRunnerOpen
            
            anchors.right: parent.right
            anchors.rightMargin: Appearance.sizes.hyprlandGapsOut

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    panelWindow.hide();
                }
            }
        }
    }

    IpcHandler {
        target: "scriptRunner"

        function toggle(): void {
            GlobalStates.scriptRunnerOpen = !GlobalStates.scriptRunnerOpen;
        }
        function close(): void {
            GlobalStates.scriptRunnerOpen = false;
        }
        function open(): void {
            GlobalStates.scriptRunnerOpen = true;
        }
    }

    GlobalShortcut {
        name: "scriptRunnerToggle"
        description: "Toggles the script runner sidebar on press"
        onPressed: {
            GlobalStates.scriptRunnerOpen = !GlobalStates.scriptRunnerOpen;
        }
    }
}
