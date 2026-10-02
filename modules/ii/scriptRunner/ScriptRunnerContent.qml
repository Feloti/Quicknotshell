import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    
    property string searchQuery: ""
    
    StyledRectangularShadow {
        target: background
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                MaterialSymbol {
                    text: "terminal"
                    iconSize: Appearance.font.pixelSize.huge
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: Translation.tr("Scripts")
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colOnLayer0
                    Layout.fillWidth: true
                }
                RippleButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.full
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "refresh"
                        iconSize: 18
                        color: Appearance.colors.colOnLayer0
                    }
                    onClicked: ScriptRunnerService.refresh()
                }
            }

            StyledListView {
                id: scriptListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                
                model: ScriptModel {
                    values: {
                        let allScripts = ScriptRunnerService.scripts;
                        if (root.searchQuery.trim().length === 0) return allScripts;
                        let q = root.searchQuery.toLowerCase();
                        return allScripts.filter(s => s.name.toLowerCase().includes(q) || (s.description && s.description.toLowerCase().includes(q)));
                    }
                }
                
                delegate: RippleButton {
                    required property var modelData
                    width: ListView.view.width
                    implicitHeight: col.implicitHeight + 20
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colLayer1
                    colBackgroundHover: Appearance.colors.colLayer1Hover
                    colRipple: Appearance.colors.colLayer1Active
                    
                    onClicked: {
                        ScriptRunnerService.execute(modelData.path);
                        GlobalStates.scriptRunnerOpen = false;
                    }
                    
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12
                        
                        MaterialSymbol {
                            text: "code"
                            iconSize: 24
                            color: Appearance.colors.colPrimary
                            Layout.alignment: Qt.AlignVCenter
                        }
                        
                        ColumnLayout {
                            id: col
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2
                            
                            StyledText {
                                text: modelData.name
                                font.weight: Font.Medium
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer1
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            StyledText {
                                text: modelData.description || Translation.tr("No description provided.")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: Appearance.colors.colSubtext
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        
                        MaterialSymbol {
                            text: "play_arrow"
                            iconSize: 32
                            color: Appearance.colors.colSubtext
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                PagePlaceholder {
                    shown: ScriptRunnerService.scripts.length === 0
                    icon: "code_off"
                    title: Translation.tr("No Scripts Found")
                    description: Translation.tr("Place your .sh files in ~/Code/Bash/\nAdd '# Description: ...' inside to see it here.")
                    shape: MaterialShape.Shape.Ghostish
                    triggerAnimationOn: GlobalStates.scriptRunnerOpen
                }
                
                PagePlaceholder {
                    shown: ScriptRunnerService.scripts.length > 0 && scriptListView.count === 0
                    icon: "search_off"
                    title: Translation.tr("No Matches")
                    description: Translation.tr("No scripts match your search.")
                    shape: MaterialShape.Shape.Ghostish
                    triggerAnimationOn: GlobalStates.scriptRunnerOpen
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: searchField.implicitHeight
                color: Appearance.colors.colLayer1
                radius: Appearance.rounding.full
                border.width: 1
                border.color: searchField.activeFocus ? Appearance.colors.colPrimary : "transparent"

                Behavior on border.color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    spacing: 0
                    
                    MaterialSymbol {
                        text: "search"
                        iconSize: Appearance.font.pixelSize.larger
                        color: searchField.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                    }
                    
                    ToolbarTextField {
                        id: searchField
                        Layout.fillWidth: true
                        colBackground: "transparent"
                        placeholderText: Translation.tr("Search scripts...")
                        onTextChanged: root.searchQuery = text
                        
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape && text.length > 0) {
                                text = "";
                                event.accepted = true;
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (scriptListView.count > 0) {
                                    let allScripts = ScriptRunnerService.scripts;
                                    let q = root.searchQuery.toLowerCase();
                                    let filtered = allScripts.filter(s => s.name.toLowerCase().includes(q) || (s.description && s.description.toLowerCase().includes(q)));
                                    if (filtered.length > 0) {
                                        ScriptRunnerService.execute(filtered[0].path);
                                        GlobalStates.scriptRunnerOpen = false;
                                    }
                                }
                                event.accepted = true;
                            }
                        }
                    }
                }
            }
        }
    }
    
    Connections {
        target: GlobalStates
        function onScriptRunnerOpenChanged() {
            if (!GlobalStates.scriptRunnerOpen) {
                searchField.text = "";
                root.searchQuery = "";
            } else {
                searchField.forceActiveFocus();
            }
        }
    }
}
