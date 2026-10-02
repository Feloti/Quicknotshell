pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common.functions

Singleton {
    id: root
    
    property list<var> scripts: []
    
    function refresh() {
        fetchProc.running = true;
    }
    
    function execute(path) {
        Quickshell.execDetached(["bash", "-c", path]);
    }
    
    Process {
        id: fetchProc
        command: [
            "bash", "-c",
            "DIR=\"$HOME/Code/Bash\"\n" +
            "mkdir -p \"$DIR\"\n" +
            "echo '['\n" +
            "first=1\n" +
            "for f in \"$DIR\"/*.sh; do\n" +
            "    [ -e \"$f\" ] || continue\n" +
            "    [ $first -eq 0 ] && echo ','\n" +
            "    first=0\n" +
            "    name=$(basename \"$f\")\n" +
            "    desc=$(grep -m 1 -iE '^# *(description|desc):' \"$f\" | sed -E 's/^# *(description|desc): *//I' | tr -d '\\n\\r\"\\047')\n" +
            "    if [ -z \"$desc\" ]; then\n" +
            "        desc=$(sed -n '2p' \"$f\" | grep '^#' | sed -E 's/^# *//' | tr -d '\\n\\r\"\\047')\n" +
            "    fi\n" +
            "    jq -n --arg name \"$name\" --arg path \"$f\" --arg desc \"$desc\" '{name: $name, path: $path, description: $desc}'\n" +
            "done\n" +
            "echo ']'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length === 0) {
                    root.scripts = [];
                    return;
                }
                
                try {
                    root.scripts = JSON.parse(this.text);
                } catch (e) {
                    console.error("[ScriptRunnerService] Failed to parse scripts:", e, "\nOutput was:", this.text);
                    root.scripts = [];
                }
            }
        }
    }
    
    Component.onCompleted: refresh()
}
