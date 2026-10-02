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
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                
                model: ScriptModel {
                    values: ScriptRunnerService.scripts
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
            }
        }
    }
}
