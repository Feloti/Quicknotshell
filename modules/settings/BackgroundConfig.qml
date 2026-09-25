import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ContentPage {
    id: page
    readonly property int index: 3
    property bool register: parent.register ?? false
    forceWidth: true
    
    property bool allowHeavyLoads: false
    Component.onCompleted: Qt.callLater(() => page.allowHeavyLoads = true)

    ContentSection {
        icon: "sync_alt"
        title: Translation.tr("Parallax")

        ConfigSwitch {
            buttonIcon: "unfold_more_double"
            text: Translation.tr("Vertical")
            checked: Config.options.background.parallax.vertical
            onCheckedChanged: {
                HyprlandSettings.changeAnimation("workspaces", checked ? "slidevert" : "slide");
                Config.options.background.parallax.vertical = checked;
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "counter_1"
                text: Translation.tr("Depends on workspace")
                checked: Config.options.background.parallax.enableWorkspace
                onCheckedChanged: {
                    Config.options.background.parallax.enableWorkspace = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "side_navigation"
                text: Translation.tr("Depends on sidebars")
                checked: Config.options.background.parallax.enableSidebar
                onCheckedChanged: {
                    Config.options.background.parallax.enableSidebar = checked;
                }
            }
        }
        ConfigSpinBox {
            icon: "loupe"
            text: Translation.tr("Preferred wallpaper zoom (%)")
            value: Config.options.background.parallax.workspaceZoom * 100
            from: 10
            to: 200
            stepSize: 1
            onValueChanged: {
                Config.options.background.parallax.workspaceZoom = value / 100;
            }
        }
        ConfigSwitch {
            buttonIcon: "masked_transitions"
            text: Translation.tr("Animate wallpaper changes")
            checked: Config.options.background.animateWallpaperChanges
            onCheckedChanged: {
                Config.options.background.animateWallpaperChanges = checked;
            }
        }
        
        ContentSubsection {
            visible: Config.options.background.animateWallpaperChanges
            title: Translation.tr("Wallpaper transition style")
            
            StyledComboBox {
                Layout.fillWidth: true
                buttonIcon: "masked_transitions"
                textRole: "displayName"
                model: [
                    {
                        displayName: Translation.tr("Radial Wipe"),
                        icon: "circle",
                        value: "radial"
                    },
                    {
                        displayName: Translation.tr("Crossfade"),
                        icon: "blur_on",
                        value: "crossfade"
                    },
                    {
                        displayName: Translation.tr("Linear Wipe"),
                        icon: "swap_horiz",
                        value: "wipe"
                    },
                    {
                        displayName: Translation.tr("Diamond Wipe"),
                        icon: "diamond",
                        value: "diamond"
                    },
                    {
                        displayName: Translation.tr("Slash Wipe"),
                        icon: "timeline",
                        value: "slash"
                    },
                    {
                        displayName: Translation.tr("Outer Wipe"),
                        icon: "radio_button_unchecked",
                        value: "outer"
                    },
                    {
                        displayName: Translation.tr("Wave Wipe"),
                        icon: "water",
                        value: "wave"
                    }
                ]
                currentIndex: {
                    const index = model.findIndex(item => item.value === Config.options.background.transitionType);
                    return index !== -1 ? index : 0;
                }
                onActivated: index => {
                    Config.options.background.transitionType = model[index].value;
                }
            }

            ConfigSpinBox {
                visible: Config.options.background.transitionType === "wipe" || Config.options.background.transitionType === "wave"
                Layout.fillWidth: true
                icon: "rotate_right"
                text: Translation.tr("Wipe Angle (0° starts from left side)")
                value: Config.options.background.wipeAngle
                from: 0
                to: 359
                stepSize: 1
                onValueChanged: {
                    Config.options.background.wipeAngle = value;
                }
            }
        }
    }

    ContentSection {
        icon: "music_note"
        title: Translation.tr("Media mode")
        tooltip: Translation.tr("Toggle the mode with a keybind that executes 'quickshell:mediaModeToggle'\nExample: bindd = Super, Z, Toggle media mode, global, quickshell:mediaModeToggle")

        ConfigRow {

            ConfigSwitch {
                Layout.fillWidth: true
                buttonIcon: "monitor"
                text: Translation.tr("Toggle per monitor")
                checked: Config.options.background.mediaMode.togglePerMonitor
                onCheckedChanged: {
                    Config.options.background.mediaMode.togglePerMonitor = checked;
                }
            }

            RippleButtonWithShape {
                Layout.fillWidth: false

                shapeString: Config.options.background.mediaMode.backgroundShape
                implicitWidth: 60
                extraIcon: "edit"

                onClicked: {
                    mediaModeBackgroundShapeLoader.active = !mediaModeBackgroundShapeLoader.active;
                }
                StyledToolTip {
                    text: Translation.tr("Edit the material shape")
                }
            }
        }
        

        Loader { 
            id: mediaModeBackgroundShapeLoader
            active: false
            visible: active
            Layout.fillWidth: true
            sourceComponent: ContentSubsection {
                title: Translation.tr("Background shape")
                
                ConfigSelectionArray {
                    currentValue: Config.options.background.mediaMode.backgroundShape
                    onSelected: newValue => {
                        Config.options.background.mediaMode.backgroundShape = newValue;
                    }
                    options: ([ 
                        "Circle", "Square", "Slanted", "Arch", "Arrow", "SemiCircle", "Oval", "Pill", "Triangle",
                        "Diamond", "ClamShell", "Pentagon", "Gem", "Sunny", "VerySunny", "Cookie4Sided", "Cookie6Sided", 
                        "Cookie7Sided", "Cookie9Sided", "Cookie12Sided", "Ghostish", "Clover4Leaf", "Clover8Leaf", "Burst", 
                        "SoftBurst", "Flower", "Puffy", "PuffyDiamond", "PixelCircle", "Bun", "Heart" 
                    ]).map(icon => { 
                        return { 
                            displayName: "", 
                            shape: icon, 
                            value: icon 
                        } 
                    })
                }
            }
        }

        ConfigRow {
            ConfigSwitch {
                Layout.fillWidth: false
                buttonIcon: "animation"
                text: Translation.tr("Enable background animation")
                checked: Config.options.background.mediaMode.backgroundAnimation.enable
                onCheckedChanged: {
                    Config.options.background.mediaMode.backgroundAnimation.enable = checked;
                }
            }

            ConfigSpinBox {
                enabled: Config.options.background.mediaMode.backgroundAnimation.enable
                Layout.fillWidth: true
                icon: "speed"
                text: Translation.tr("Speed scale")
                value: Config.options.background.mediaMode.backgroundAnimation.speedScale
                from: 0
                to: 100
                stepSize: 5
                onValueChanged: {
                    Config.options.background.mediaMode.backgroundAnimation.speedScale = value;
                }

                MouseArea {
                    z: -1
                    id: spinBoxMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                StyledToolTip {
                    extraVisibleCondition: spinBoxMouseArea.containsMouse
                    text: Translation.tr("1: very slow | 10: default | 20: 2x speed...")
                }
            }
        }
        
        ConfigSwitch {
            buttonIcon: "format_color_fill"
            text: Translation.tr("Change shell color to match album art")
            checked: Config.options.background.mediaMode.changeShellColor
            onCheckedChanged: {
                Config.options.background.mediaMode.changeShellColor = checked;
            }
        }

        ConfigSpinBox {
            Layout.fillWidth: true
            icon: "opacity"
            text: Translation.tr("Background album art opacity (%)")
            value: Config.options.background.mediaMode.backgroundOpacity
            from: 0
            to: 100
            stepSize: 10
            onValueChanged: {
                Config.options.background.mediaMode.backgroundOpacity = value;
            }
        }


        ContentSubsection {
            title: Translation.tr("Text highlight style")
            ConfigSelectionArray {
                currentValue: Config.options.background.mediaMode.syllable.textHighlightStyle
                onSelected: newValue => {
                    Config.options.background.mediaMode.syllable.textHighlightStyle = newValue;
                }
                options: [
                    {   
                        displayName: Translation.tr("Vertical"),
                        icon: "vertical_distribute",
                        value: 0
                    },
                    {
                        displayName: Translation.tr("Horizontal"),
                        icon: "horizontal_distribute",
                        value: 1
                    }
                ]
            }
        }
        
    }

    ContentSection {
        icon: "music_cast"
        title: Translation.tr("Widget: Media")
        tooltip: Translation.tr("You can reset the media player by middle-clicking on the widget in case of media source errors")

        ConfigRow {
            Layout.fillWidth: true

            ConfigSwitch {
                Layout.fillWidth: false
                buttonIcon: "check"
                text: Translation.tr("Enable")
                checked: Config.options.background.widgets.media.enable
                onCheckedChanged: {
                    Config.options.background.widgets.media.enable = checked;
                }
            }
            
            RippleButtonWithShape {
                shapeString: Config.options.background.widgets.media.backgroundShape
                implicitWidth: 60
                extraIcon: "edit"

                onClicked: {
                    mediaBackgroundShapeLoader.active = !mediaBackgroundShapeLoader.active;
                }
                StyledToolTip {
                    text: Translation.tr("Edit the material shape")
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ConfigSelectionArray {
                Layout.fillWidth: false
                currentValue: Config.options.background.widgets.media.placementStrategy
                onSelected: newValue => {
                    Config.options.background.widgets.media.placementStrategy = newValue;
                }
                options: [
                    {
                        displayName: Translation.tr("Draggable"),
                        icon: "drag_pan",
                        value: "free"
                    },
                    {
                        displayName: Translation.tr("Least busy"),
                        icon: "category",
                        value: "leastBusy"
                    },
                    {
                        displayName: Translation.tr("Most busy"),
                        icon: "shapes",
                        value: "mostBusy"
                    }
                ]
            }
        }


        Loader { 
            id: mediaBackgroundShapeLoader
            active: false
            visible: active
            Layout.fillWidth: true
            sourceComponent: ContentSubsection {
                title: Translation.tr("Background shape")
                
                ConfigSelectionArray {
                    currentValue: Config.options.background.widgets.media.backgroundShape
                    onSelected: newValue => {
                        Config.options.background.widgets.media.backgroundShape = newValue;
                    }
                    options: ([ 
                        "Circle", "Square", "Slanted", "Arch", "Arrow", "SemiCircle", "Oval", "Pill", "Triangle",
                        "Diamond", "ClamShell", "Pentagon", "Gem", "Sunny", "VerySunny", "Cookie4Sided", "Cookie6Sided", 
                        "Cookie7Sided", "Cookie9Sided", "Cookie12Sided", "Ghostish", "Clover4Leaf", "Clover8Leaf", "Burst", 
                        "SoftBurst", "Flower", "Puffy", "PuffyDiamond", "PixelCircle", "Bun", "Heart" 
                    ]).map(icon => { 
                        return { 
                            displayName: "", 
                            shape: icon, 
                            value: icon 
                        } 
                    })
                }
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "opacity"
                text: Translation.tr("Use album colors")
                checked: Config.options.background.widgets.media.useAlbumColors
                onCheckedChanged: {
                    Config.options.background.widgets.media.useAlbumColors = checked;
                }
            }
            ConfigSwitch {
                buttonIcon: "colors"
                text: Translation.tr("Tint art cover")
                checked: Config.options.background.widgets.media.tintArtCover
                onCheckedChanged: {
                    Config.options.background.widgets.media.tintArtCover = checked;
                }
            }
        }

        ConfigRow {
            uniform: true
            ConfigSwitch {
                buttonIcon: "block"
                text: Translation.tr("Hide all controls")
                checked: Config.options.background.widgets.media.hideAllButtons
                onCheckedChanged: {
                    Config.options.background.widgets.media.hideAllButtons = checked;
                }
                StyledToolTip {
                    text: Translation.tr("Buttons will only be visible on hover")
                }
            }
            ConfigSwitch {
                buttonIcon: "skip_previous"
                text: Translation.tr("Show previous toggle")
                checked: Config.options.background.widgets.media.showPreviousToggle
                onCheckedChanged: {
                    Config.options.background.widgets.media.showPreviousToggle = checked;
                }
            }
        }
        ContentSubsection {
            title: Translation.tr("Glow effect")
            ConfigRow {
                uniform: true
                ConfigSwitch {
                    buttonIcon: "backlight_high"
                    text: Translation.tr("Enable")
                    checked: Config.options.background.widgets.media.glow.enable
                    onCheckedChanged: {
                        Config.options.background.widgets.media.glow.enable = checked;
                    }
                }
                ConfigSpinBox {
                    from: 5
                    to: 100
                    stepSize: 5
                    icon: "brightness_5"
                    text: Translation.tr("Brightness (%)")
                    value: Config.options.background.widgets.media.glow.brightness
                    onValueChanged: {
                        Config.options.background.widgets.media.glow.brightness = value;
                    }
                }
            }
        }
        ContentSubsection {
            title: Translation.tr("Visualizer")

            ConfigRow {
                uniform: true

                ConfigSwitch {
                    buttonIcon: "bar_chart"
                    text: Translation.tr("Enable")
                    checked: Config.options.background.widgets.media.visualizer.enable
                    onCheckedChanged: {
                        Config.options.background.widgets.media.visualizer.enable = checked;
                    }
                }
                
                ConfigSpinBox {
                    from: 0
                    to: 100
                    stepSize: 5
                    icon: "opacity"
                    text: Translation.tr("Opacity (%)")
                    value: Config.options.background.widgets.media.visualizer.opacity * 100
                    onValueChanged: {
                        Config.options.background.widgets.media.visualizer.opacity = value / 100;
                    }
                }
            }
            
            ConfigRow {
                uniform: true
                
                ConfigSpinBox {
                    from: 0
                    to: 5
                    stepSize: 1
                    icon: "rounded_corner"
                    text: Translation.tr("Smoothing")
                    value: Config.options.background.widgets.media.visualizer.smoothing
                    onValueChanged: {
                        Config.options.background.widgets.media.visualizer.smoothing = value;
                    }
                }

                ConfigSpinBox {
                    from: 0
                    to: 10
                    stepSize: 1
                    icon: "blur_on"
                    text: Translation.tr("Blur")
                    value: Config.options.background.widgets.media.visualizer.blur
                    onValueChanged: {
                        Config.options.background.widgets.media.visualizer.blur = value;
                    }
                }
            }

        }
    }
}
