pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool available: false
    property bool checking: false
    property int count: 0
    
    readonly property bool updateAdvised: false
    readonly property bool updateStronglyAdvised: false

    function load() {}
    function refresh() {}
}
