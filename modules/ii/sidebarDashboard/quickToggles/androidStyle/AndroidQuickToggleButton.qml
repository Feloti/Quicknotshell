import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.functions
import qs.modules.common.widgets

GroupButton {
    id: root
    
    // Info to be passed to by repeater
    required property int buttonIndex
    required property var buttonData
    required property bool expandedSize
    required property real baseCellWidth
    required property real baseCellHeight
    required property real cellSpacing
    required property int cellSize

    // Signals
    signal openMenu()

    // Declared in specific toggles
    property QuickToggleModel toggleModel
    property string name: toggleModel?.name ?? ""
    property string statusText: (toggleModel?.hasStatusText) ? (toggleModel?.statusText || (toggled ? Translation.tr("Active") : Translation.tr("Inactive"))) : ""
    property string tooltipText: toggleModel?.tooltipText ?? ""
    property string buttonIcon: toggleModel?.icon ?? "close"
    property bool available: toggleModel?.available ?? true
    toggled: toggleModel?.toggled ?? false
    property var mainAction: toggleModel?.mainAction ?? null
    altAction: toggleModel?.hasMenu ? (() => root.openMenu()) : (toggleModel?.altAction ?? null)

    // Edit mode state
    property bool editMode: false

    // Sizing shenanigans
    baseWidth: root.baseCellWidth * cellSize + cellSpacing * (cellSize - 1)
    baseHeight: root.baseCellHeight
    enableImplicitWidthAnimation: !editMode && root.mouseArea.containsMouse
    enableImplicitHeightAnimation: !editMode && root.mouseArea.containsMouse
    Behavior on baseWidth {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    Behavior on baseHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }
    opacity: 0
    Component.onCompleted: {
        opacity = 1
    }
    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    enabled: available || editMode
    padding: 6
    horizontalPadding: padding
    verticalPadding: padding

    colBackground: Appearance.colors.colLayer2
    colBackgroundToggled: (altAction && expandedSize) ? Appearance.colors.colLayer2 : Appearance.colors.colPrimary
    colBackgroundToggledHover: (altAction && expandedSize) ? Appearance.colors.colLayer2Hover : Appearance.colors.colPrimaryHover
    colBackgroundToggledActive: (altAction && expandedSize) ? Appearance.colors.colLayer2Active : Appearance.colors.colPrimaryActive
    readonly property int fullRadius: Config.options.appearance.sharpMode ? Appearance.rounding.full : height / 2
    buttonRadius: toggled ? Appearance.rounding.large : fullRadius
    buttonRadiusPressed: Appearance.rounding.normal
    property color colText: (toggled && !(altAction && expandedSize) && enabled) ? Appearance.colors.colOnPrimary : ColorUtils.transparentize(Appearance.colors.colOnLayer2, enabled ? 0 : 0.7)
    property color colIcon: expandedSize ? ((root.toggled) ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer3) : colText

    onClicked: {
        if (root.expandedSize && root.altAction) root.altAction();
        else root.mainAction();
    }

    contentItem: RowLayout {
        id: contentItem
        spacing: 4
        anchors {
            centerIn: root.expandedSize ? undefined : parent
            fill: root.expandedSize ? parent : undefined
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
        }

        // Icon
        MouseArea {
            id: iconMouseArea
            hoverEnabled: true
            acceptedButtons: (root.expandedSize && root.altAction) ? Qt.LeftButton : Qt.NoButton
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: true
            Layout.topMargin: root.verticalPadding
            Layout.bottomMargin: root.verticalPadding
            implicitHeight: iconBackground.implicitHeight
            implicitWidth: iconBackground.implicitWidth
            cursorShape: Qt.PointingHandCursor

            onClicked: root.mainAction()

            Rectangle {
                id: iconBackground
                anchors.fill: parent
                implicitWidth: height
                radius: root.radius - root.verticalPadding
                color: {
                    const baseColor = root.toggled ? Appearance.colors.colPrimary : Appearance.colors.colLayer3
                    const transparentizeAmount = (root.altAction && root.expandedSize) ? 0 : 1
                    return ColorUtils.transparentize(baseColor, transparentizeAmount)
                }

                Behavior on radius {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    fill: root.toggled ? 1 : 0
                    iconSize: root.expandedSize ? 22 : 24
                    color: root.colIcon
                    text: root.buttonIcon
                }

                // State layer
                Loader {
                    anchors.fill: parent
                    active: (root.expandedSize && root.altAction)
                    sourceComponent: Rectangle {
                        radius: iconBackground.radius
                        color: ColorUtils.transparentize(root.colIcon, iconMouseArea.containsPress ? 0.88 : iconMouseArea.containsMouse ? 0.95 : 1)
                        Behavior on color {
                            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                        }
                    }
                }
            }
        }

        // Text column for expanded size
        Loader {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            visible: root.expandedSize
            active: visible
            sourceComponent: Column {
                spacing: -2

                StyledText {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    font.weight: 600
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.name
                }

                StyledText {
                    visible: root.statusText
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    font {
                        pixelSize: Appearance.font.pixelSize.smaller
                        weight: 100
                    }
                    color: root.colText
                    elide: Text.ElideRight
                    text: root.statusText
                }
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        enabled: root.editMode
        keys: ["androidQuickToggle"]
        
        onDropped: (drop) => {
            const fromType = drop.source.buttonType;
            const toType = root.buttonData.type;
            
            if (fromType === toType) return;
            
            let toggleList = Array.from(Config.options.sidebar.quickToggles.android.toggles);
            let fi = toggleList.findIndex(t => t.type === fromType);
            let ti = toggleList.findIndex(t => t.type === toType);
            
            if (fi !== -1 && ti !== -1) {
                // Dragging an active toggle onto another active toggle (Reorder)
                let itemToMove = toggleList.splice(fi, 1)[0];
                ti = toggleList.findIndex(t => t.type === toType); // Recalculate target index
                toggleList.splice(ti, 0, itemToMove);
                Config.options.sidebar.quickToggles.android.toggles = toggleList;
            } else if (fi === -1 && ti !== -1) {
                // Dragging from unused to active (Add)
                let itemToMove = { type: fromType, size: 1 };
                toggleList.splice(ti, 0, itemToMove);
                Config.options.sidebar.quickToggles.android.toggles = toggleList;
            } else if (fi !== -1 && ti === -1) {
                // Dragging from active to unused (Remove)
                toggleList.splice(fi, 1);
                Config.options.sidebar.quickToggles.android.toggles = toggleList;
            }
        }
    }

    Rectangle {
        id: dropHighlight
        anchors.fill: parent
        radius: root.buttonRadius
        color: Appearance.colors.colPrimary
        opacity: dropArea.containsDrag ? 0.3 : 0
        visible: opacity > 0
        z: 10
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
    }

    MouseArea { // Blocking MouseArea for edit interactions
        id: editModeInteraction
        visible: root.editMode
        anchors.fill: parent
        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        drag.target: ghostRect
        drag.threshold: 5

        function toggleEnabled() {
            let toggleList = Array.from(Config.options.sidebar.quickToggles.android.toggles);
            const buttonType = root.buttonData.type;
            const isEnabled = toggleList.some(toggle => toggle.type === buttonType);

            if (!isEnabled) {
                toggleList.push({ type: buttonType, size: 1 });
            } else {
                toggleList = toggleList.filter(toggle => toggle.type !== buttonType);
            }
            Config.options.sidebar.quickToggles.android.toggles = toggleList;
        }

        function toggleSize() {
            let toggleList = Array.from(Config.options.sidebar.quickToggles.android.toggles);
            const buttonType = root.buttonData.type;
            let found = false;
            for (let i = 0; i < toggleList.length; i++) {
                if (toggleList[i].type === buttonType) {
                    let toggledObj = Object.assign({}, toggleList[i]);
                    toggledObj.size = 3 - toggledObj.size; // Alternate between 1 and 2
                    toggleList[i] = toggledObj;
                    found = true;
                }
            }
            if (found) {
                Config.options.sidebar.quickToggles.android.toggles = toggleList;
            }
        }

        function movePositionBy(offset) {
            let toggleList = Array.from(Config.options.sidebar.quickToggles.android.toggles);
            const buttonType = root.buttonData.type;
            const index = toggleList.findIndex(toggle => toggle.type === buttonType);
            if (index === -1) return;
            const targetIndex = index + offset;
            if (targetIndex < 0 || targetIndex >= toggleList.length) return;
            const temp = toggleList[index];
            toggleList[index] = toggleList[targetIndex];
            toggleList[targetIndex] = temp;
            Config.options.sidebar.quickToggles.android.toggles = toggleList;
        }

        onReleased: (event) => {
            if (drag.active) {
                ghostRect.Drag.drop();
                // Snap ghost back instantly
                ghostRect.x = 0;
                ghostRect.y = 0;
            } else if (event.button === Qt.LeftButton) {
                toggleEnabled();
            }
        }
        onPressed: (event) => {
            if (event.button === Qt.RightButton) toggleSize();
        }
        onWheel: (event) => {
            if (event.angleDelta.y < 0) { // Move to right
                movePositionBy(1);
            } else if (event.angleDelta.y > 0) { // Move to left
                movePositionBy(-1);
            }
            event.accepted = true;
        }
    }

    Rectangle { // Visual element that follows cursor while dragging
        id: ghostRect
        width: root.width
        height: root.height
        radius: root.buttonRadius
        color: root.colBackground
        border.color: Appearance.colors.colPrimary
        border.width: 2
        opacity: editModeInteraction.drag.active ? 0.8 : 0
        visible: opacity > 0
        z: 999

        Drag.active: editModeInteraction.drag.active
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
        Drag.keys: ["androidQuickToggle"]
        Drag.source: ghostRect

        property string buttonType: root.buttonData.type

        RowLayout {
            anchors.centerIn: parent
            spacing: 4
            MaterialSymbol { 
                iconSize: root.expandedSize ? 22 : 24
                text: root.buttonIcon
                color: root.colIcon
            }
            Column {
                visible: root.expandedSize
                spacing: -2
                StyledText {
                    text: root.name
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    font.weight: 600
                    color: root.colText
                }
            }
        }
    }

    StyledToolTip {
        extraVisibleCondition: root.tooltipText !== ""
        text: root.tooltipText
    }
}
